// author: 不得闲
// email: 75492895@qq.com
// date: 2021-02-02
// MsgPack的解码

import 'dart:typed_data';
import 'package:dxvalue/dxvalue.dart';
import 'package:flutter/cupertino.dart';
import 'typeSystem.dart';
part 'numFormat.dart';

class MsgPackParser implements BinCoder{
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

  @override
  void decodeToValue(Uint8List data, DxValue destValue) {
    formatCode.reset(_dataList[_offset]);
    bool isArray = formatCode.isArray();
    destValue.resetValueType(isArray);
    if(isArray){
      _offset++;
      parseArray(destValue);
    }else if(formatCode.isMap()){
      _offset++;
      parseObject(destValue);
    }
  }

  void _encodeMap(BytesBuilder bytesBuilder,DxValue value){
    int mapLen = value.length;
    if(mapLen < 16){
      bytesBuilder.addByte(0x80 | mapLen);
    }else if (mapLen < 65536){
      bytesBuilder.addByte(0xde);
      bytesBuilder.addByte(mapLen >> 8);
      bytesBuilder.addByte(mapLen);
    }else {
      bytesBuilder.addByte(0xdf);
      bytesBuilder.addByte(mapLen >> 24);
      bytesBuilder.addByte(mapLen >> 16);
      bytesBuilder.addByte(mapLen >> 8);
      bytesBuilder.addByte(mapLen);
    }
    for (var kv in value){
      _encodeString(bytesBuilder, kv.key);
      _encodeValue(bytesBuilder, kv.value);
    }
  }

  void _encodeString(BytesBuilder bytesBuilder,String value){
    Uint8List utf8Bytes = value.toUtf8();
    int strLen = utf8Bytes.length;
    if(strLen < 32){
      bytesBuilder.addByte(0xa0 | strLen);
    }else if (strLen < 256){
      bytesBuilder.addByte(0xd9);
      bytesBuilder.addByte(strLen);
    }else if (strLen < 65536){
      bytesBuilder.addByte(0xda);
      bytesBuilder.addByte(strLen >> 8);
      bytesBuilder.addByte(strLen);
    }else{
      bytesBuilder.addByte(0xdb);
      bytesBuilder.addByte(strLen >> 24);
      bytesBuilder.addByte(strLen >> 16);
      bytesBuilder.addByte(strLen >> 8);
      bytesBuilder.addByte(strLen);
    }
    bytesBuilder.add(utf8Bytes);
  }

  void _encodeArray(BytesBuilder bytesBuilder,DxValue value){
    int arrlen = value.length;
    if(arrlen < 16){
      bytesBuilder.addByte(0x90 | arrlen);
    }else if (arrlen < 65536){
      bytesBuilder.addByte(0xdc);
      bytesBuilder.addByte(arrlen >> 8);
      bytesBuilder.addByte(arrlen);
    }else {
      bytesBuilder.addByte(0xdd);
      bytesBuilder.addByte(arrlen >> 24);
      bytesBuilder.addByte(arrlen >> 16);
      bytesBuilder.addByte(arrlen >> 8);
      bytesBuilder.addByte(arrlen);
    }
    for(var i = 0;i< arrlen;i++){
      _encodeValue(bytesBuilder, value[i]);
    }
  }

  void _encodeInt(BytesBuilder bytesBuilder,int value){
    if(value == null){
      bytesBuilder.addByte(0xc0);
      return;
    }
    if(value >= 0){
      if(value < 128){
        bytesBuilder.addByte(value);
      }else if (value <= 255){
        bytesBuilder.addByte(0xcc);
        bytesBuilder.addByte(value);
      }else if (value <= (1<<16) - 1){
        bytesBuilder.addByte(0xcd);
        bytesBuilder.addByte(value >> 8);
        bytesBuilder.addByte(value);
      }else if (value <= (1<<32) - 1){
        bytesBuilder.addByte(0xce);
        bytesBuilder.addByte(value >> 24);
        bytesBuilder.addByte(value >> 16);
        bytesBuilder.addByte(value >> 8);
        bytesBuilder.addByte(value);
      }else{
        bytesBuilder.addByte(0xcf);
        bytesBuilder.addByte(value >> 56);
        bytesBuilder.addByte(value >> 48);
        bytesBuilder.addByte(value >> 40);
        bytesBuilder.addByte(value >> 32);
        bytesBuilder.addByte(value >> 24);
        bytesBuilder.addByte(value >> 16);
        bytesBuilder.addByte(value >> 8);
        bytesBuilder.addByte(value);
      }
      return;
    }

    int lowFixNeg = 0xe0 - 256;
    if(value >= lowFixNeg){
      bytesBuilder.addByte(value);
    }else if (value >= (-1 << 7)){
      bytesBuilder.addByte(0xd0);
      bytesBuilder.addByte(value);
    }else if (value >= (-1 << 15)){
      bytesBuilder.addByte(0xd1);
      bytesBuilder.addByte(value >> 8);
      bytesBuilder.addByte(value);
    }else if (value >= (-1 << 31)){
      bytesBuilder.addByte(0xd2);
      bytesBuilder.addByte(value >> 24);
      bytesBuilder.addByte(value >> 16);
      bytesBuilder.addByte(value >> 8);
      bytesBuilder.addByte(value);
    }else{
      bytesBuilder.addByte(0xd3);
      bytesBuilder.addByte(value >> 56);
      bytesBuilder.addByte(value >> 48);
      bytesBuilder.addByte(value >> 40);
      bytesBuilder.addByte(value >> 32);
      bytesBuilder.addByte(value >> 24);
      bytesBuilder.addByte(value >> 16);
      bytesBuilder.addByte(value >> 8);
      bytesBuilder.addByte(value);
    }
  }

  void _encodeValue(BytesBuilder bytesBuilder,BaseValue value){
    switch(value.type){
      case valueType.VT_Int:
        _encodeInt(bytesBuilder, (value as IntValue).value);
        return;
      case valueType.VT_Float:
      case valueType.VT_Double:
      case valueType.VT_DateTime:
      case valueType.VT_Boolean:
        if ((value as BoolValue).value??false){
          bytesBuilder.addByte(0xc3);
        }else{
          bytesBuilder.addByte(0xc2);
        }
        return ;
      case valueType.VT_String:
        _encodeString(bytesBuilder, (value as StringValue).value);
        return;
      case valueType.VT_Null:
        bytesBuilder.addByte(0xc0);
        return;
      case valueType.VT_Binary:
      case valueType.VT_Object:
        _encodeMap(bytesBuilder,(value as DxValue));
        return;
      case valueType.VT_Array:
        _encodeArray(bytesBuilder,(value as DxValue));
        return;
    }
  }

  @override
  Uint8List encode(DxValue value) {
    BytesBuilder builder = BytesBuilder();
    if(value.type == valueType.VT_Array){
      _encodeArray(builder,value);
    }else{
      _encodeMap(builder,value);
    }
    return builder.takeBytes();
  }

}
