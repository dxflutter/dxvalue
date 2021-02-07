// author: 不得闲
// email: 75492895@qq.com
// date: 2021-02-02
// MsgPack的解码

import 'dart:typed_data';
import 'package:dxvalue/dxvalue.dart';
import 'typeSystem.dart';
part 'numFormat.dart';

class MsgPackParser {
  Uint8List _dataList;
  int _offset=0;
  ByteData _byteData;
  FormatCodeValue formatCode;
  MsgPackParser([this._dataList]){
    formatCode = FormatCodeValue(msgPackFormatCode.msgPackFormatUnUsed,null);
    if(_dataList != null){
      _byteData = ByteData.view(_dataList.buffer);
    }
  }

  FormatCodeValue checkCode(bool skip){
    formatCode.reset(_dataList[_offset]);
    if(skip){
      _offset++;
    }
    return formatCode;
  }

  String _readString(){
    int strLen = 0;
    switch(formatCode.code){
      case msgPackFormatCode.msgPackFormatFixStr:
        strLen = formatCode.value;
        break;
      case msgPackFormatCode.msgPackFormatStr8:
        strLen = parseU8();
        break;
      case msgPackFormatCode.msgPackFormatStr16:
        strLen = parseU16();
        break;
      case msgPackFormatCode.msgPackFormatStr32:
        strLen = parseU32();
        break;
    }
    if(strLen > 0){
      int first = _offset;
      _offset += strLen;
      return _dataList.sublist(first,_offset).utf8toString();
    }
    return "";
  }

  void _parseTimeStamp(DxValue parent,[String key]){
    switch(formatCode.code){
      case msgPackFormatCode.msgPackFormatFixExt4:
        //4字节时间信息
        int sec = _byteData.getUint32(_offset);
        if(key != null){
          parent.setKeyDateTime(key, DateTime.fromMillisecondsSinceEpoch(sec * 1000));
        }else{
          parent.setIndexDateTime(-1, DateTime.fromMillisecondsSinceEpoch(sec * 1000));
        }
        _offset += 4;
        break;
      case msgPackFormatCode.msgPackFormatFixExt8:
        //8字节时间信息
        //64位时间格式
        int sec = _byteData.getUint64(_offset);
        int nsec = sec >> 34; //纳秒
        sec &= 0x00000003ffffffff; //秒
        DateTime dt = DateTime.fromMillisecondsSinceEpoch(sec * 1000);
        if(key != null){
          parent.setKeyDateTime(key, dt.add(Duration(microseconds: nsec ~/ 1000)));
        }else{
          parent.setIndexDateTime(-1, dt.add(Duration(microseconds: nsec ~/ 1000)));
        }
        _offset += 8;
        break;
      case msgPackFormatCode.msgPackFormatExt8:
        //12字节时间信息
        int nsec = _byteData.getUint32(_offset);
        _offset += 4;
        int sec = _byteData.getUint64(_offset);
        DateTime dt = DateTime.fromMillisecondsSinceEpoch(sec * 1000);
        if(key != null){
          parent.setKeyDateTime(key, dt.add(Duration(microseconds: nsec ~/ 1000)));
        }else{
          parent.setIndexDateTime(-1, dt.add(Duration(microseconds: nsec ~/ 1000)));
        }
        _offset += 8;
        break;
    }
  }

  void _parseExt(DxValue parent,{String key,bool shareBinary=true}){
    //先读取长度
    int extLen = 0;
    switch(formatCode.code){
      case msgPackFormatCode.msgPackFormatExt8:
        extLen = _byteData.getUint8(_offset);
        _offset++;
        break;
      case msgPackFormatCode.msgPackFormatExt16:
        extLen = _byteData.getUint16(_offset);
        _offset += 2;
        break;
      case msgPackFormatCode.msgPackFormatExt32:
        extLen = _byteData.getUint32(_offset);
        _offset += 4;
        break;
    }
    //读取extCode
    int type =  _byteData.getInt8(_offset);
    _offset++;
    if(extLen == 0){
      return;
    }
    if(type == -1 && formatCode.code == msgPackFormatCode.msgPackFormatExt8){
      //96位日期时间
      _parseTimeStamp(parent,key);
      return;
    }
    int start = _offset;
    _offset += extLen;
    ExtValue extValue;
    if(shareBinary){
      extValue = ExtValue(type, _dataList.sublist(start,_offset));
    }else{
      extValue = ExtValue(type, Uint8List.fromList(_dataList.sublist(start,_offset)));
    }
    if(key == null){
      parent.setIndexValue(-1, extValue);
    }else{
      parent.setKeyValue(key, extValue);
    }
  }

  void _parseFixExt(DxValue parent,{String key,bool shareBinary=true}){
    //读取extCode
    int type =  _byteData.getInt8(_offset);
    _offset++;
    if(type == -1 && (formatCode.code == msgPackFormatCode.msgPackFormatFixExt4 || formatCode.code == msgPackFormatCode.msgPackFormatFixExt8)){
      //日期时间
      _parseTimeStamp(parent,key);
      return;
    }
    Uint8List data;
    int start = _offset;
    ExtValue extValue;
    switch(formatCode.code){
      case msgPackFormatCode.msgPackFormatFixExt1:
        _offset++;
        break;
      case msgPackFormatCode.msgPackFormatFixExt2:
        _offset += 2;
        break;
      case msgPackFormatCode.msgPackFormatFixExt4:
        _offset += 4;
        break;
      case msgPackFormatCode.msgPackFormatFixExt8:
        _offset += 8;
        break;
      case msgPackFormatCode.msgPackFormatFixExt16:
        _offset += 16;
        break;
    }
    if(shareBinary){
      extValue = ExtValue(type, _dataList.sublist(start,_offset));
    }else{
      extValue = ExtValue(type, Uint8List.fromList(_dataList.sublist(start,_offset)));
    }
    if(key == null){
      parent.setIndexValue(-1, extValue);
    }else{
      parent.setKeyValue(key, extValue);
    }
  }

  void _parseBin(DxValue parent,{String key,bool shareBinary=true}){
    int binLen = 0;
    switch(formatCode.code){
      case msgPackFormatCode.msgPackFormatBin8:
        binLen = _byteData.getUint8(_offset);
        _offset ++;
        break;
      case msgPackFormatCode.msgPackFormatBin16:
        binLen = _byteData.getUint16(_offset);
        _offset += 2;
        break;
      case msgPackFormatCode.msgPackFormatBin32:
        binLen = _byteData.getUint32(_offset);
        _offset += 4;
        break;
    }
    if(binLen == 0){
      return;
    }
    int start = _offset;
    _offset += binLen;
    BinaryValue binaryValue = BinaryValue();

    if(shareBinary){
      binaryValue.binary = _dataList.sublist(start,_offset);
    }else{
      binaryValue.binary = Uint8List.fromList(_dataList.sublist(start,_offset));
    }
    if(key == null){
      parent.setIndexValue(-1, binaryValue);
    }else{
      parent.setKeyValue(key, binaryValue);
    }
  }

  void _parseValue(DxValue parent,{String key,bool shareBinary=true}){
    //先获取Code
    formatCode.reset(_dataList[_offset]);
    _offset++;
    if(formatCode.isString()){
      if(key != null){
        parent.setKeyString(key, _readString());
      }else{
        parent.setIndexString(-1, _readString());
      }
      return ;
    }
    if(formatCode.isInt()){
      if(key!=null){
        parent.setKeyInt(key, parseInt());
      }else{
        parent.setIndexInt(-1, parseInt());
      }
      return;
    }
    if(formatCode.code == msgPackFormatCode.msgPackFormatFalse){
      if(key != null){
        parent.setKeyBool(key, false);
      }else{
        parent.setIndexBool(-1, false);
      }
      return;
    }
    if(formatCode.code == msgPackFormatCode.msgPackFormatTrue){
      if(key != null){
        parent.setKeyBool(key, true);
      }else{
        parent.setIndexBool(-1, true);
      }
      return;
    }
    if(formatCode.code == msgPackFormatCode.msgPackFormatFloat){
      if(key != null){
        parent.setKeyFloat(key, parseFloat32());
      }else{
        parent.setIndexFloat(-1, parseFloat32());
      }
      return ;
    }
    if(formatCode.code == msgPackFormatCode.msgPackFormatDouble){
      if(key != null){
        parent.setKeyDouble(key, parseFloat64());
      }else{
        parent.setIndexDouble(-1, parseFloat64());
      }
      return ;
    }
    if(formatCode.isBin()){
      _parseBin(parent,key:key,shareBinary: shareBinary);
      return;
    }
    if(formatCode.isExt()){
      //读取extCode
      _parseExt(parent,key:key,shareBinary: shareBinary);
      return;
    }
    if(formatCode.isFixExt()){
      _parseFixExt(parent,key:key,shareBinary: shareBinary);
      return;
    }
    if(formatCode.isMap()){
      DxValue arrayValue;
      if(key != null){
        arrayValue = parent.newObject(key: key);
      }else{
        arrayValue = parent.newObject();
      }
      parseObject(arrayValue,shareBinary);
      return;
    }
    if(formatCode.isArray()){
      DxValue arrayValue;
      if(key != null){
        arrayValue = parent.newArray(key: key);
      }else{
        arrayValue = parent.newArray();
      }
      parseArray(arrayValue);
      return;
    }

    if(formatCode.code == msgPackFormatCode.msgPackFormatNil || formatCode.code == msgPackFormatCode.msgPackFormatUnUsed){
      if(key != null){
        parent.setKeyValue(key, null);
      }else{
        parent.setIndexValue(-1, null);
      }
      return;
    }
  }


  void parseArray(DxValue arrayValue,[bool shareBinary=true]){
    arrayValue.clear();
    int arrLen = formatCode.value;
    switch(formatCode.code){
      case msgPackFormatCode.msgPackFormatFixArray:
        break;
      case msgPackFormatCode.msgPackFormatArray16:
        arrLen = parseU16();
        break;
      case msgPackFormatCode.msgPackFormatArray32:
        arrLen = parseU32();
        break;
    }
    for(var i = 0;i<arrLen;i++){
      _parseValue(arrayValue,shareBinary: shareBinary);
    }
  }

  void parseObject(DxValue objValue,[bool shareBinary=true]){
    objValue.clear();
    int objLen = formatCode.value;
    switch(formatCode.code){
      case msgPackFormatCode.msgPackFormatFixMap:
        break;
      case msgPackFormatCode.msgPackFormatMap16:
        objLen = parseU16();
        break;
      case msgPackFormatCode.msgPackFormatMap32:
        objLen = parseU32();
        break;
    }
    formatCode.reset(_dataList[_offset]);
    bool keyIsStr = formatCode.isString();
    if(keyIsStr){
      for(var i = 0;i<objLen;i++){
        formatCode.reset(_dataList[_offset]);
        _offset++;
        String key = _readString();
        _parseValue(objValue,key:key,shareBinary: shareBinary);
      }
    }else{
      for(var i = 0;i<objLen;i++){
        formatCode.reset(_dataList[_offset]);
        _offset++;
        String key = parseInt().toString();
        _parseValue(objValue,key:key,shareBinary: shareBinary);
      }
    }
  }

}
