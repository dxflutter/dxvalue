// author: 不得闲
// email: 75492895@qq.com
// date: 2021-02-02
// MsgPack的解码


import 'dart:ffi';
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

  void _parseValue(DxValue parent,[String key]){
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
    if(formatCode.isMap()){
      DxValue arrayValue;
      if(key != null){
        arrayValue = parent.newObject(key: key);
      }else{
        arrayValue = parent.newObject();
      }
      parseObject(arrayValue);
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


  void parseArray(DxValue arrayValue){
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
      _parseValue(arrayValue);
    }
  }

  void parseObject(DxValue objValue){
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
        _parseValue(objValue,key);
      }
    }else{
      for(var i = 0;i<objLen;i++){
        formatCode.reset(_dataList[_offset]);
        _offset++;
        String key = parseInt().toString();
        _parseValue(objValue,key);
      }
    }
  }

}
