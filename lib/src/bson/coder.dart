// author: 不得闲
// email: 75492895@qq.com
// date: 2021-02-02
// BSON的解码

import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../dxvalue.dart';
import 'typeSystem.dart';

///
///    BSON文档（对象）由一个有序的元素列表构成。每个元素由一个字段名、一个类型和一个值组成。字段名为字符串。
///    所以BSON文档必然是Object
///

class BsonParser implements BinCoder{
  Uint8List _dataList;
  bool _shareBinary;
  int _offset=0;
  ByteData _byteData;
  BsonParser([this._dataList,this._shareBinary]);

  void _parseBsonDocument(DxValue destValue){
    int docLen = _byteData.getUint32(_offset,Endian.little);
    if(docLen > _dataList.length - _offset){
      throw FormatException("invalidate bson document length: out of range");
    }
    _offset += 4;
    //读取文档体，由一个个的元素组成
    //每个元素为一个类型+字段名+值组成
    while(_offset < _dataList.length){
      int bsonType = _dataList[_offset];
      _offset++;
      //读取字段,cstring,ansic
      int keyEnd = _dataList.indexOf(0,_offset);
      if(keyEnd < 0){
        throw FormatException("invalidate bson Key");
      }
      String keyName = _dataList.sublist(_offset,keyEnd).utf8toString();
      _offset = keyEnd + 1; //跳过一个 \0
      switch(bsonType){
        case 0x04: //BsonType.bsonArray.index:
          break;
        case 0x03: //BsonType.bsonEmbeddedDoc.index:
          DxValue objValue = destValue.newObject(key: keyName);
          _parseBsonDocument(objValue);
          break;
        default:
          _parseValue(bsonType,destValue,keyName: keyName);
      }
      if(_offset == docLen - 1 && _dataList[_offset] == 0){
        return;
      }
    }
  }

  void _parseValue(int bsonType,DxValue parentValue,{String keyName}){
    switch(bsonType){
      case 0x01:
        //double
        double value =  _byteData.getFloat64(_offset,Endian.little);
        if(keyName == null){
          parentValue.setIndexDouble(-1, value);
        }else{
          parentValue.setKeyDouble(keyName, value);
        }
        _offset += 8;
        return;
      case 0x02:
        int valueLen = _byteData.getUint32(_offset,Endian.little);
        _offset += 4;
        int start = _offset;
        _offset += valueLen;
        if(keyName == null){
          parentValue.setIndexString( -1, _dataList.sublist(start,_offset-1).utf8toString());
        }else{
          parentValue.setKeyString(keyName, _dataList.sublist(start,_offset-1).utf8toString());
        }
        return;
      case 0x05:
        //binary
        ExtValue extValue;
        int valueLen = _byteData.getUint32(_offset,Endian.little);
        _offset+=4;
        //子类型
        int subType = _dataList[_offset];
        _offset++;
        if(subType == 2){
          valueLen = _byteData.getUint32(_offset,Endian.little);
          _offset += 4;
          if(valueLen > _dataList.length - _offset){
            throw FormatException("binary length out of range");
          }
          extValue = ExtValue(0, null);
        }else{
          extValue = ExtValue(0x05, null);
        }
        int start = _offset;
        _offset += valueLen;
        if(_shareBinary){
          extValue.binary = _dataList.sublist(start,_offset);
        }else{
          extValue.binary = Uint8List.fromList(_dataList.sublist(start,_offset));
        }
        return;
      case 0x07:
        //ObjectID ,12字节
        ExtValue extValue;
        int start = _offset;
        _offset += 12;
        if(_shareBinary){
          extValue = ExtValue(0x07,_dataList.sublist(start,_offset));
        }else{
          extValue = ExtValue(0x07,Uint8List.fromList(_dataList.sublist(start,_offset)));
        }
        if(keyName == null){
          parentValue.setIndexDxValue(-1, extValue);
        }else{
          parentValue.setKeyDxValue(keyName, extValue);
        }
        return;
      case 0x08:
        //boolean
        if(keyName == null){
          parentValue.setIndexBool(-1, _dataList[_offset]==1);
        }else{
          parentValue.setKeyBool(keyName, _dataList[_offset]==1);
        }
        _offset++;
        return;
      case 0x09:
        //DateTime Unix 纪元(1970 年 1 月 1 日)以来的毫秒数
        Duration vUnix = Duration(milliseconds: _byteData.getUint64(_offset,Endian.little));
        _offset += 8;
        if(keyName == null){
          parentValue.setIndexDateTime(-1, DateTime(1970).add(vUnix));
        }else{
          parentValue.setKeyDateTime(keyName, DateTime(1970).add(vUnix));
        }
        return;
      case 0x0A:
        //null
        return;
      case 0x0B:
        //Regex
        return;
      case 0x0C:
        //dbPoint
        return;
      case 0x0D:
        //javascript
        return;
      case 0x0E:
        //symbol
        return;
      case 0x0F:
        //CodeWithScope
        return;
      case 0x10:
        //int32
        if(keyName == null){
          parentValue.setIndexInt(-1, _byteData.getInt32(_offset,Endian.little));
        }else{
          parentValue.setKeyInt(keyName, _byteData.getInt32(_offset,Endian.little));
        }
        _offset += 4;
        return;
      case 0x11:
        //Timestamp 64 位值 前4个字节是一个增量，后4个字节是一个时间戳。
        ExtValue extValue = ExtValue(0x11, null);
        int start = _offset;
        _offset += 8;
        if(_shareBinary){
          extValue.binary = _dataList.sublist(start,_offset);
        }else{
          extValue.binary = Uint8List.fromList(_dataList.sublist(start,_offset));
        }
        return;
      case 0x12:
        //int64
        if(keyName == null){
          parentValue.setIndexInt(-1, _byteData.getInt64(_offset,Endian.little));
        }else{
          parentValue.setKeyInt(keyName, _byteData.getInt64(_offset,Endian.little));
        }
        _offset += 8;
        return;
      case 0x13:
        //Decimal128
        ExtValue extValue = ExtValue(0x13, null);
        int start = _offset;
        _offset += 16;
        if(_shareBinary){
          extValue.binary = _dataList.sublist(start,_offset);
        }else{
          extValue.binary = Uint8List.fromList(_dataList.sublist(start,_offset));
        }
        return;
      case 0xFF:
        //minKey
        return;
      case 0x7F:
        //maxKey
        return;
    }
  }

  @override
  void decodeToValue(Uint8List data, DxValue destValue) {
    _dataList = data;
    _offset = 0;
    int dataLen = (_dataList?.length)??0;
    if(dataLen < 4){
      //文档长度不够
      throw FormatException("invalidate bson document,doc length out of range");
    }
    _byteData = ByteData.sublistView(_dataList);
    _parseBsonDocument(destValue);
  }



  @override
  Uint8List encode(DxValue value) {
    // TODO: implement encode
    throw UnimplementedError();
  }

}