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

  String _readString(int strLen){
    if(strLen > 0){
      int first = _offset;
      _offset += strLen;
     Uint8List utf8lst =  _dataList.sublist(first,_offset);
      return utf8lst.utf8toString();
    }
    return "";
  }

  void _parseValue(DxValue parent,[String key]){
    //先获取Code
    formatCode.reset(_dataList[_offset]);
    _offset++;
    switch(formatCode.code){
      case msgPackFormatCode.msgPackFormatFixInt:
      case msgPackFormatCode.msgPackFormatNegFixInt:
        if(key!=null){
          parent.setKeyInt(key, formatCode.value);
        }else{
          parent.setIndexInt(-1, formatCode.value);
        }
        return;

      case msgPackFormatCode.msgPackFormatNil:
      case msgPackFormatCode.msgPackFormatUnUsed:
        if(key != null){
          parent.setKeyValue(key, null);
        }else{
          parent.setIndexValue(-1, null);
        }
        return;

      case msgPackFormatCode.msgPackFormatFalse:
        if(key != null){
          parent.setKeyBool(key, false);
        }else{
          parent.setIndexBool(-1, false);
        }
        return;
      case msgPackFormatCode.msgPackFormatTrue:
        if(key != null){
          parent.setKeyBool(key, true);
        }else{
          parent.setIndexBool(-1, true);
        }
        return;

      case msgPackFormatCode.msgPackFormatFloat:
        if(key != null){
          parent.setKeyFloat(key, parseFloat32());
        }else{
          parent.setIndexFloat(-1, parseFloat32());
        }
        return ;
      case msgPackFormatCode.msgPackFormatDouble:
        if(key != null){
          parent.setKeyDouble(key, parseFloat64());
        }else{
          parent.setIndexDouble(-1, parseFloat64());
        }
        return ;

      case msgPackFormatCode.msgPackFormatFixStr:
        String str = _readString(formatCode.value);
        if(key != null){
          parent.setKeyString(key, str);
        }else{
          parent.setIndexString(-1, str);
        }
        break;
      case msgPackFormatCode.msgPackFormatStr8:
        int strLen = parseU8();
        if(key != null){
          parent.setKeyString(key, _readString(strLen));
        }else{
          parent.setIndexString(-1, _readString(strLen));
        }
        break;
      case msgPackFormatCode.msgPackFormatStr16:
        int strLen = parseU16();
        if(key != null){
          parent.setKeyString(key, _readString(strLen));
        }else{
          parent.setIndexString(-1, _readString(strLen));
        }
        break;
      case msgPackFormatCode.msgPackFormatStr32:
        int strLen = parseU32();
        if(key != null){
          parent.setKeyString(key, _readString(strLen));
        }else{
          parent.setIndexString(-1, _readString(strLen));
        }
        break;
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
  }

}
