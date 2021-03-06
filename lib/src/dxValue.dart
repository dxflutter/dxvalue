// author: 不得闲
// email: 75492895@qq.com
// date: 2021-01-20
// 万能值对象DxValue

///
/// Demo:
/// DxValue strValue = DxValue.fromJson('{"Name":"Text","Age":32}');
/// print(strValue["Name"]);
/// print(strValue.stringByKey("Name");
/// strValue.forcePath(["路径1","路径2","路径3"],false);
/// strValue.setKeyString("路径4", "测试数据");
///
/// strValue.resetFromJson('{"Name":"Text","Age":32}');
/// strValue = DxValue(false);
///

import 'dart:typed_data';

import 'package:dxvalue/src/bson/coder.dart';
import 'package:dxvalue/src/msgpack/coder.dart';
import 'package:dxvalue/src/msgpack/typeSystem.dart';

import 'json/jsonparse.dart';
import 'simpleValue.dart';
import 'extionBaseType.dart';

class _DxValueIterator extends Iterator<KeyValue>{
  int _startIterator;
  final DxValue value;
  KeyValue _keyValue;
  _DxValueIterator(this.value){
    _startIterator = -1;
    _keyValue = KeyValue("", null);
  }
  @override
  KeyValue get current{
    _keyValue.value = value._values[_startIterator];
    if(value._isArray){
      _keyValue.key = "";
      return _keyValue;
    }
    _keyValue.key = value._keys[_startIterator];
    return _keyValue;
  }

  @override
  bool moveNext() {
    _startIterator++;
    if(_startIterator < value._values.length){
      return true;
    }
    _startIterator = -1;
    return false;
  }

}


abstract class BinCoder{
  Uint8List encode(DxValue value);
  void decodeToValue(Uint8List data,DxValue destValue);
}


class DxValue extends BaseValue{
  bool _isArray;
  List<BaseValue> _values;
  List<String> _keys;
  int _newKeyIndex(String key){
    int idx = -1;
    for(var i = 0;i<_keys.length;i++){
      if(key == _keys[i]){
        idx = i;
        break;
      }
    }
    if (idx == -1){
      _keys.add(key);
      _values.add(null);
      idx = _values.length - 1;
    }
    return idx;
  }

  String _writeJsonString(int level,StringBuffer stringBuffer){
    if(_isArray){
      stringBuffer.write('[\r\n');
      if(_values != null){
        for(var i = 0;i<_values.length;i++){
          if(i!=0){
            stringBuffer.write(',\r\n');
          }
          for(var i = 0;i <= level;i++){
            stringBuffer.write('  ');
          }

          if(_values[i] != null && _values[i].type == valueType.VT_String || _values[i].type == valueType.VT_DateTime){
            stringBuffer.write('"');
            stringBuffer.write(_values[i]);
            stringBuffer.write('"');
          }else if (_values[i] != null && _values[i] is DxValue) {
            (_values[i] as DxValue)._writeJsonString(level + 1, stringBuffer);
          } else if (_values[i] != null && _values[i] is ExtValue) {
            (_values[i] as ExtValue)._writeString(level + 1, stringBuffer);
          } else if (_values[i] != null && _values[i] is BinaryValue){
            (_values[i] as BinaryValue)._writeBinary(stringBuffer);
          }else{
            stringBuffer.write(_values[i]);
          }
        }
      }
      stringBuffer.write('\r\n');
      for(var i = 0;i < level;i++){
        stringBuffer.write('  ');
      }
      stringBuffer.write(']');
    }else{
      stringBuffer.write('{\r\n');
      if(_values != null){
        for(var i = 0;i<_values.length;i++){
          if(i!=0){
            stringBuffer.write(',\r\n');
          }
          for(var i = 0;i <= level;i++){
            stringBuffer.write('  ');
          }
          stringBuffer.write('"');
          stringBuffer.write(_keys[i]);
          stringBuffer.write('":');

          if(_values[i] != null && _values[i].type == valueType.VT_String || _values[i].type == valueType.VT_DateTime){
            stringBuffer.write('"');
            stringBuffer.write(_values[i]);
            stringBuffer.write('"');
          }else if (_values[i] != null && _values[i] is DxValue) {
            (_values[i] as DxValue)._writeJsonString(level + 1, stringBuffer);
          } else if (_values[i] != null && _values[i] is ExtValue){
            (_values[i] as ExtValue)._writeString(level + 1,stringBuffer);
          } else if (_values[i] != null && _values[i] is BinaryValue){
            (_values[i] as BinaryValue)._writeBinary(stringBuffer);
          }else{
            stringBuffer.write(_values[i]);
          }
        }
      }
      stringBuffer.write('\r\n');
      for(var i = 0;i < level;i++){
        stringBuffer.write('  ');
      }
      stringBuffer.write('}');
    }
    return stringBuffer.toString();
  }

  @override
  Iterator<KeyValue> get iterator => _DxValueIterator(this);


  @override
  get type {
    if(_isArray){
      return valueType.VT_Array;
    }
    return valueType.VT_Object;
  }

  DxValue(bool arrayValue){
    _isArray = arrayValue;
    _values = List<BaseValue>();
    if (!_isArray){
      _keys = List<String>();
    }
  }

  DxValue.fromJson(String jsonStr){
    _values = List<BaseValue>();
    _isArray = true;
    resetFromJson(jsonStr);
  }

  DxValue.fromMsgPack(Uint8List msgPackData,[bool shareBinary=true]){
    _values = List<BaseValue>();
    _isArray = true;
    resetFromMsgPack(msgPackData,shareBinary);
  }

  DxValue.fromBson(Uint8List bsonData,[bool shareBinary=true]){
    _values = List<BaseValue>();
    resetFromBson(bsonData,shareBinary);
  }

  void resetFromBson(Uint8List bsonData,[bool shareBinary=true]){
    BsonParser parse = BsonParser(null,shareBinary);
    if(_keys == null){
      _keys = List<String>();
    }else{
      _keys.clear();
    }
    _values.clear();
    _isArray = false;
    parse.decodeToValue(bsonData, this);
  }

  void resetFromMsgPack(Uint8List msgPackData,[bool shareBinary=true]){
    MsgPackParser parse = MsgPackParser(msgPackData);
    FormatCodeValue fmtCode = parse.checkCode(true);
    if(fmtCode.isMap()){
      if(_keys == null){
        _keys = List<String>();
      }else{
        _keys.clear();
      }
      _isArray = false;
      parse.parseObject(this,shareBinary);
    }else if(fmtCode.isArray()){
      _isArray = true;
      _keys = null;
      parse.parseArray(this,shareBinary);
    }
  }

  void resetValueType(bool array){
    _isArray = array;
    if (!_isArray){
      if(_keys == null){
        _keys = List<String>();
      }else{
        _keys.clear();
      }
    }else{
      _keys = null;
    }
  }

  void resetFromJson(String jsonStr){
    clear();
    JsonParse parse = JsonParse.fromString(jsonStr);
    _isArray = !parse.isObject();
    if (!_isArray){
      if(_keys == null){
        _keys = List<String>();
      }else{
        _keys.clear();
      }
      parse.parseObject(this);
    }else{
      _keys = null;
      parse.parseArray(this);
    }
  }

  void decodeWithCoder(Uint8List data, BinCoder codeStyle){
    codeStyle.decodeToValue(data, this);
  }

  Uint8List encodeWithCoder(BinCoder codeStyle){
    return codeStyle.encode(this);
  }

  Uint8List encodeJson({bool format=true,bool utf8=false}){
    return JsonEncoder.toU8List(this,format: format,utf8: utf8);
  }

  Uint8List encodeBson(){
    return BsonParser().encode(this);
  }

  Uint8List encodeMsgPack(){
    return MsgPackParser().encode(this);
  }

  void resetFromJsonBytes(Uint8List u8List){
    JsonParse parse = JsonParse(u8List);
    _isArray = !parse.isObject();
    if (!_isArray && _keys == null){
      _keys = List<String>();
    }else if (_isArray){
      _keys = null;
    }
    parse.parseObject(this);
  }

  DxValue newObject({String key}){
    DxValue v;
    if(_isArray){
      v = DxValue(false);
      _values.add(v);
      return v;
    }
    if((key??"") == ""){
      return null;
    }
    for(var i = 0;i<_values.length;i++){
      if(key == _keys[i]){
        if (_values[i] != null && _values[i].type == valueType.VT_Object){
          return _values[i] as DxValue;
        }
        v = DxValue(false);
        _values[i] = v;
        return v;
      }
    }
    _keys.add(key);
    v = DxValue(false);
    _values.add(v);
    return v;
  }

  DxValue newArray({String key}){
    DxValue v;
    if(_isArray){
      v = DxValue(true);
      _values.add(v);
      return v;
    }
    if((key??"") == ""){
      return null;
    }
    for(var i = 0;i<_values.length;i++){
      if(key == _keys[i]){
        if (_values[i] != null && _values[i].type == valueType.VT_Object){
          return _values[i] as DxValue;
        }
        v = DxValue(true);
        _values[i] = v;
        return v;
      }
    }
    _keys.add(key);
    v = DxValue(true);
    _values.add(v);
    return v;
  }

  BaseValue valueByKey(String key,[bool ignoreCase=true]){
    int index = _keyIndex(key,ignoreCase);
    if(index != -1){
      return _values[index];
    }
    return null;
  }

  int _keyIndex(String key,[bool ignoreCase=true]){
    if(_isArray || key == null || key.length == 0){
      return -1;
    }
    if(ignoreCase){
      key = key.toLowerCase();
      for(var i = 0;i<_keys.length;i++){
        if(key.compareTo(_keys[i].toLowerCase()) == 0){
          return i;
        }
      }
    }else{
      for(var i = 0;i<_keys.length;i++){
        if(key == _keys[i]){
          return i;
        }
      }
    }
    return -1;
  }

  BaseValue valueByIndex(int index){
    if(index == null || index < 0 || index > _values.length - 1){
      return null;
    }
    return _values[index];
  }

  int intByKey(String key,[int defValue=0,bool ignoreCase=true]){
    BaseValue v = valueByKey(key,ignoreCase);
    return (v == null)?defValue:v.asInteger(defValue: defValue);
  }

  double doubleByKey(String key,[double defValue=0,bool ignoreCase=true]){
    BaseValue v = valueByKey(key,ignoreCase);
    return (v == null)?defValue:v.asDouble(defValue: defValue);
  }

  bool boolByKey(String key,[bool defValue=false,bool ignoreCase=true]){
    BaseValue v = valueByKey(key,ignoreCase);
    return (v == null)?defValue:v.asBoolean(defValue: defValue);
  }

  DateTime dateTimeByKey(String key,DateTime defValue,[bool ignoreCase=true]){
    BaseValue v = valueByKey(key,ignoreCase);
    return (v == null)?defValue:v.asDateTime(defValue: defValue);
  }

  String stringByKey(String key,[String defValue="",bool ignoreCase=true]){
    BaseValue v = valueByKey(key,ignoreCase);
    return (v == null)?defValue:v.asString();
  }

  BaseValue operator [](Object index){
    if(index is int){
      if(index >= 0 && index < _values.length){
        return _values[index];
      }
    }else if (index is String){
      return valueByKey(index);
    }else if (index is IntValue){
      int idx = index.value??-1;
      if(idx >= 0 && idx < _values.length){
        return _values[idx];
      }
    }else if (index is StringValue){
      return valueByKey(index.value??"");
    }
    return null;
  }

  void operator []=(Object index, Object value){
    if(index is int){
      setIndexValue(index, value);
    }else if (index is String){
      setKeyValue(index, value);
    }else if (index is BaseValue){
      if(index is IntValue){
        setIndexValue(index.value, value);
      }else if (index is StringValue){
        setKeyValue(index.value, value);
      }
    }
  }

  //dart字符串采用UTF-16编码
  @override
  String toString(){
    StringBuffer stringBuffer = StringBuffer();
    _writeJsonString(0, stringBuffer);
    return stringBuffer.toString();
    //return JsonEncoder.encode(this,format: true);
  }

  void clear(){
    for(var i = 0;i<_values.length;i++){
      if(_values[i] != null && _values[i] is DxValue){
        (_values[i] as DxValue).clear();
      }
    }
    _values.clear();
    if(_keys != null){
      _keys.clear();
    }
  }

  void setKeyInt(String key,int value){
    if(_isArray){
      return ;
    }
    int idx = _newKeyIndex(key);
    if(_values[idx] != null && _values[idx] is IntValue){
      (_values[idx] as IntValue).value = value;
      return;
    }
    _values[idx] = IntValue(value: value);
  }

  void setIndexInt(int index,int value){
    if(!_isArray){
      return ;
    }

    if(index < 0 || index > _values.length - 1){
      _values.add(IntValue(value: value));
      return ;
    }
    if(_values[index] != null && _values[index] is IntValue){
      (_values[index] as IntValue).value = value;
      return;
    }
    _values[index] = IntValue(value: value);
  }

  void setKeyString(String key,String value){
    if(_isArray){
      return ;
    }
    int idx = _newKeyIndex(key);
    if(_values[idx] != null && _values[idx] is StringValue){
      (_values[idx] as StringValue).value = value;
      return;
    }
    _values[idx] = StringValue(value: value);
  }

  void setIndexString(int index,String value){
    if(!_isArray){
      return ;
    }

    if(index < 0 || index > _values.length - 1){
      _values.add(StringValue(value: value));
      return ;
    }
    if(_values[index] != null && _values[index] is IntValue){
      (_values[index] as StringValue).value = value;
      return;
    }
    _values[index] = StringValue(value: value);
  }

  void setKeyDouble(String key,double value){
    if(_isArray){
      return ;
    }
    int idx = _newKeyIndex(key);
    if(_values[idx] != null && _values[idx] is DoubleValue){
      DoubleValue v = (_values[idx] as DoubleValue);
      v.value = value;
      v.float32 = false;
      return;
    }
    _values[idx] = DoubleValue(value: value);
  }

  void setKeyFloat(String key,double value){
    if(_isArray){
      return ;
    }
    int idx = _newKeyIndex(key);
    if(_values[idx] != null && _values[idx] is DoubleValue){
      DoubleValue v = (_values[idx] as DoubleValue);
      v.value = value;
      v.float32 = true;
      return;
    }
    _values[idx] = DoubleValue.fromFloat(value: value);
  }

  void setIndexDouble(int index,double value){
    if(!_isArray){
      return ;
    }

    if(index < 0 || index > _values.length - 1){
      _values.add(DoubleValue(value: value));
      return ;
    }
    if(_values[index] != null && _values[index] is IntValue){
      DoubleValue v = (_values[index] as DoubleValue);
      v.value = value;
      v.float32 = false;
      return;
    }
    _values[index] = DoubleValue(value: value);
  }

  void setIndexFloat(int index,double value){
    if(!_isArray){
      return ;
    }
    if(index < 0 || index > _values.length - 1){
      _values.add(DoubleValue.fromFloat(value: value));
      return ;
    }
    if(_values[index] != null && _values[index] is IntValue){
      DoubleValue v = (_values[index] as DoubleValue);
      v.value = value;
      v.float32 = true;
      return;
    }
    _values[index] = DoubleValue.fromFloat(value: value);
  }

  void setKeyBool(String key,bool value){
    if(_isArray){
      return ;
    }
    int idx = _newKeyIndex(key);
    if(_values[idx] != null && _values[idx] is BoolValue){
      (_values[idx] as BoolValue).value = value;
      return;
    }
    _values[idx] = BoolValue(value: value);
  }

  void setIndexBool(int index,bool value){
    if(!_isArray){
      return ;
    }

    if(index < 0 || index > _values.length - 1){
      _values.add(BoolValue(value: value));
      return ;
    }
    if(_values[index] != null && _values[index] is IntValue){
      (_values[index] as BoolValue).value = value;
      return;
    }
    _values[index] = BoolValue(value: value);
  }

  void setKeyDateTime(String key,DateTime value){
    if(_isArray){
      return ;
    }
    int idx = _newKeyIndex(key);
    if(_values[idx] != null && _values[idx] is DateTimeValue){
      (_values[idx] as DateTimeValue).value = value;
      return;
    }
    _values[idx] = DateTimeValue(value: value);
  }

  void setKeyExtBinary(String key,int extType,Uint8List binary,[bool copyBinary=false]){
    if(_isArray || extType > 127 || extType < - 128){
      return;
    }
    int idx = _newKeyIndex(key);
    if(copyBinary){
      binary = Uint8List.fromList(binary);
    }
    if(_values[idx] != null && _values[idx] is ExtValue){
      ExtValue extValue = (_values[idx] as ExtValue);
      extValue.extType = extType;
      extValue.binary = binary;
      return;
    }
    _values[idx] = ExtValue(extType, binary);
  }

  void setKeyBinary(String key,Uint8List binary,[bool copyBinary=false]){
    if(_isArray){
      return;
    }
    int idx = _newKeyIndex(key);
    if(copyBinary){
      binary = Uint8List.fromList(binary);
    }
    if(_values[idx] != null && _values[idx] is BinaryValue){
      BinaryValue binaryValue = (_values[idx] as BinaryValue);
      binaryValue.binary = binary;
      return;
    }
    _values[idx] = BinaryValue(binary);
  }

  void setIndexDateTime(int index,DateTime value){
    if(!_isArray){
      return ;
    }

    if(index < 0 || index > _values.length - 1){
      _values.add(DateTimeValue(value: value));
      return ;
    }
    if(_values[index] != null && _values[index] is IntValue){
      (_values[index] as DateTimeValue).value = value;
      return;
    }
    _values[index] = DateTimeValue(value: value);
  }

  void setIndexExtBinary(int index,int extType,Uint8List binary,[bool copyBinary=false]){
    if(!_isArray || extType > 127 || extType < - 128){
      return;
    }
    if(copyBinary){
      binary = Uint8List.fromList(binary);
    }
    if(index < 0 || index > _values.length - 1){
      _values[index] = ExtValue(extType, binary);
      return;
    }
    if(_values[index] != null && _values[index] is ExtValue){
      ExtValue extValue = (_values[index] as ExtValue);
      extValue.extType = extType;
      extValue.binary = binary;
      return;
    }
    _values[index] = ExtValue(extType, binary);
  }

  void setIndexBinary(int index,Uint8List binary,[bool copyBinary=false]){
    if(!_isArray){
      return;
    }
    if(copyBinary){
      binary = Uint8List.fromList(binary);
    }
    if(index < 0 || index > _values.length - 1){
      _values[index] = BinaryValue(binary);
      return;
    }
    if(_values[index] != null && _values[index] is BinaryValue){
      BinaryValue binaryValue = (_values[index] as BinaryValue);
      binaryValue.binary = binary;
      return;
    }
    _values[index] = BinaryValue(binary);
  }

  void _innerSetIndexValue(int idx,BaseValue value){
    bool oldIsNull = (_values[idx]?.type)??(valueType.VT_Null) == valueType.VT_Null;
    valueType vt = (value?.type)??valueType.VT_Null;
    if (vt == valueType.VT_Null){
      _values[idx] = null;
      return;
    }
    if (oldIsNull || _values[idx].type != vt){
      _values[idx] = value;
      return ;
    }
    switch(value.type){
      case valueType.VT_String:
        (_values[idx] as StringValue).value = (value as StringValue).value;
        return;
      case valueType.VT_Boolean:
        (_values[idx] as BoolValue).value = (value as BoolValue).value;
        return;
      case valueType.VT_Int:
        (_values[idx] as IntValue).value = (value as IntValue).value;
        return;
      case valueType.VT_Double:
        (_values[idx] as DoubleValue).value = (value as DoubleValue).value;
        return;
      case valueType.VT_DateTime:
        (_values[idx] as DateTimeValue).value = (value as DateTimeValue).value;
        return;
    }
    _values[idx] = value;
  }

  void setKeyDxValue(String key,BaseValue value){
    _innerSetIndexValue(_newKeyIndex(key),value);
  }

  void setIndexDxValue(int index,BaseValue value){
    if(!_isArray){
      return ;
    }
    if(index < 0 || index > _values.length - 1){
      _values.add(value);
      return;
    }
    _innerSetIndexValue(index,value);
  }

  void setKeyValue(String key,Object value){
    if(value == null){
      if(_isArray){
        return ;
      }
      int idx = _newKeyIndex(key);
      _values[idx] = null;
      return;
    }
    if (value is String){
      setKeyString(key, value);
      return ;
    }
    if (value is int){
      setKeyInt(key, value);
      return ;
    }
    if (value is bool){
      setKeyBool(key,value);
      return ;
    }
    if (value is double){
      setKeyDouble(key, value);
      return ;
    }
    if(value is DateTime){
      setKeyDateTime(key, value);
      return ;
    }

    if(value is DxValueMarshal){
      int idx = _newKeyIndex(key);
      _values[idx] = value.toDxValue();
      return;
    }

    if (value is BaseValue){
      setKeyDxValue(key,value);
      return ;
    }
  }

  void setIndexObject(int index,DxValue objValue){
    if(!_isArray || objValue._isArray){
      return ;
    }

    if(index < 0 || index > _values.length - 1){
      _values.add(objValue);
      return ;
    }
    if(_values[index] != null && _values[index] is DxValue){
      (_values[index] as DxValue).clear();
    }
    _values[index] = objValue;
  }

  void setIndexArray(int index,DxValue objValue){
    if(!_isArray || !objValue._isArray){
      return ;
    }

    if(index < 0 || index > _values.length - 1){
      _values.add(objValue);
      return ;
    }
    if(_values[index] != null && _values[index] is DxValue){
      (_values[index] as DxValue).clear();
    }
    _values[index] = objValue;
  }

  void setIndexValue(int index,Object value){
    if(value == null){
      if(!_isArray){
        return ;
      }
      if(index < 0 || index > _values.length - 1){
        _values.add(value);
        return;
      }
      _innerSetIndexValue(index, null);
      return;
    }
    if (value is String){
      setIndexString(index, value);
      return ;
    }
    if (value is int){
      setIndexInt(index, value);
      return ;
    }
    if (value is bool){
      setIndexBool(index,value);
      return ;
    }
    if (value is double){
      setIndexDouble(index, value);
      return ;
    }
    if(value is DateTime){
      setIndexDateTime(index, value);
      return ;
    }

    if(value is DxValueMarshal){
      if(index < 0 || index > _values.length - 1){
        _values.add(value.toDxValue());
        return;
      }
      _innerSetIndexValue(index, value.toDxValue());
      return;
    }

    if (value is BaseValue){
      if(index < 0 || index > _values.length - 1){
        _values.add(value);
        return;
      }
      _innerSetIndexValue(index, value);
      return ;
    }
  }

  @override
  int get length => _values.length;

  DxValue forceValue(String path,{bool arrayValue=false,String separator="/"}){
    if(path == ""){
      return null;
    }
    List<String> paths = path.split(separator);
    return forcePath(paths,arrayValue);
  }

  DxValue forcePath(List<String> paths,[bool arrayValue=false]){
    DxValue parentValue;
    parentValue = this;
    for(var i = 0;i<paths.length;i++){
      if (parentValue._isArray){
        int idx = int.tryParse(paths[i])??-1;
        bool canArray = idx != -1;
        if(!canArray || idx > parentValue.length - 1){ //不符合，需要替换
          if(i == 0){
            if(idx == 0 && parentValue.length == 0){
              parentValue = parentValue.newObject();
              continue;
            }
            return null;
          }
          if(!canArray){
            parentValue._isArray = false;
            parentValue._values.clear();
            parentValue._keys = List<String>();
          }
          if(i == paths.length - 1 && arrayValue){
            parentValue = parentValue.newArray(key: paths[i]);
            return parentValue;
          }
          parentValue = parentValue.newObject(key: paths[i]);
        }else{
          //在中间
          if(parentValue._values[idx] == null || !(parentValue._values[idx] is DxValue)){
            DxValue newValue;
            if(i == paths.length - 1){
              newValue = DxValue(arrayValue);
            }else{
              newValue = DxValue(false);
            }
            parentValue._values[idx] = newValue;
            parentValue = newValue;
          }else{
            parentValue = parentValue._values[idx];
          }
        }
        continue;
      }
      var index = parentValue._keyIndex(paths[i]);
      if (index == -1){
        if(i == paths.length - 1){
          if(arrayValue){
            return parentValue.newArray(key: paths[i]);
          }
          return parentValue.newObject(key: paths[i]);
        }
        parentValue = parentValue.newObject(key: paths[i]);
      }else if(parentValue._values[index] == null || !(parentValue._values[index] is DxValue)){
        DxValue newValue;
        if(i == paths.length - 1){
          newValue = DxValue(arrayValue);
        }else{
          newValue = DxValue(false);
        }
        parentValue._values[index] = newValue;
        parentValue = newValue;
      }else if (i < paths.length - 1){
        parentValue = parentValue._values[index];
      }else {
        if (parentValue._values[index] != null && parentValue._values[index] is DxValue){
          parentValue = parentValue._values[index];
          if(parentValue._isArray != arrayValue){
            parentValue._isArray = arrayValue;
            if(!parentValue._isArray){
              parentValue._keys = null;
            }else{
              parentValue._values.clear();
              parentValue._keys = List<String>();
            }
          }
          return parentValue;
        }
        DxValue newValue = DxValue(arrayValue);
        parentValue._values[index] = newValue;
        parentValue = newValue;
        return parentValue;
      }
    }
    return parentValue;
  }

  forceInt(String path,int value,[String separator="/"]){
    if((path??"") == ""){
      return ;
    }
    List<String> paths = path.split(separator);
    if(paths.length == 1){
      setKeyInt(path, value);
      return ;
    }
    DxValue objValue = forcePath(paths.sublist(0,paths.length - 1));
    objValue.setKeyInt(paths[paths.length - 1], value);
  }

  forceBool(String path,bool value,[String separator="/"]){
    if((path??"") == ""){
      return ;
    }
    List<String> paths = path.split(separator);
    if(paths.length == 1){
      setKeyBool(path, value);
      return ;
    }
    DxValue objValue = forcePath(paths.sublist(0,paths.length - 1));
    objValue.setKeyBool(paths[paths.length - 1], value);
  }

  forceString(String path,String value,[String separator="/"]){
    if((path??"") == ""){
      return ;
    }
    List<String> paths = path.split(separator);
    if(paths.length == 1){
      setKeyString(path, value);
      return ;
    }
    DxValue objValue = forcePath(paths.sublist(0,paths.length - 1));
    objValue.setKeyString(paths[paths.length - 1], value);
  }

  forceDouble(String path,double value,[String separator="/"]){
    if((path??"") == ""){
      return ;
    }
    List<String> paths = path.split(separator);
    if(paths.length == 1){
      setKeyDouble(path, value);
      return ;
    }
    DxValue objValue = forcePath(paths.sublist(0,paths.length - 1));
    objValue.setKeyDouble(paths[paths.length - 1], value);
  }

  forceDateTime(String path,DateTime value,[String separator="/"]){
    if((path??"") == ""){
      return ;
    }

    List<String> paths = path.split(separator);
    if(paths.length == 1){
      setKeyDateTime(path, value);
      return ;
    }
    DxValue objValue = forcePath(paths.sublist(0,paths.length - 1));
    objValue.setKeyDateTime(paths[paths.length - 1], value);
  }
}


class ExtValue   extends BaseValue{
  Uint8List binary;
  int  extType;    // 0 - 127 application Custom Type,  -128- -1 系统预留类型 ,,-1为时间日期
  @override
  get type => valueType.VT_Binary;

  msgPackFormatCode msgPackCode(){
    int l = binary.length;
    if(l == 1){
      return msgPackFormatCode.msgPackFormatFixExt1;
    }
    if (l == 2){
      return msgPackFormatCode.msgPackFormatFixExt2;
    }
    if (l == 4){
      return msgPackFormatCode.msgPackFormatFixExt4;
    }
    if (l == 8){
      return msgPackFormatCode.msgPackFormatFixExt8;
    }
    if (l == 16){
      return msgPackFormatCode.msgPackFormatFixExt16;
    }
    if (l < 256){
      return msgPackFormatCode.msgPackFormatExt8;
    }
    if (l < 2 << 16){
      return msgPackFormatCode.msgPackFormatExt16;
    }
    if (l < 2 << 32){
      return msgPackFormatCode.msgPackFormatExt32;
    }
    throw FormatException("不支持超过4G的扩展二进制信息");
  }

  ExtValue(this.extType,this.binary);

  void _writeString(int spaceLevel,StringBuffer stringBuffer){
    Uint8List space = Uint8List((spaceLevel + 1) << 1);
    for(var i = 0;i < space.length;i++){
      space[i] = 32;
    }
    String spaceStr = String.fromCharCodes(space);

    stringBuffer.write('{\r\n');
    stringBuffer.write(spaceStr);


    stringBuffer.write('"extType":');
    stringBuffer.write(extType);
    stringBuffer.write(',\r\n');
    stringBuffer.write(spaceStr);
    stringBuffer.write('"data":"');
    //转换成二进制
    stringBuffer.write(binary.toHexWithFormat(spaceLevel: spaceLevel + 2));
    stringBuffer.write('"\r\n');
    if(spaceStr.length > 1){
      stringBuffer.write(spaceStr.substring(spaceStr.length - 2));
    }
    stringBuffer.write('}');
  }

  @override
  String toString(){
    StringBuffer stringBuffer = StringBuffer();
    _writeString(0, stringBuffer);
    return stringBuffer.toString();
  }
}

class BinaryValue extends BaseValue{
  Uint8List binary;
  @override
  get type => valueType.VT_Binary;

  BinaryValue([this.binary]);

  void _writeBinary(StringBuffer stringBuffer){
    if(binary == null){
      stringBuffer.write("null");
    }
    stringBuffer.write('"Bin(');
    binary.writeHex(stringBuffer);
    stringBuffer.write(')"');
  }

  @override
  String toString(){
    StringBuffer stringBuffer = StringBuffer();
    _writeBinary(stringBuffer);
    return stringBuffer.toString();
  }
}