library dxvalue;

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dxlibrary/dxlibrary.dart';
import 'src/simplevalue.dart';

export 'src/simplevalue.dart';


class _DxValueIterator extends Iterator<KeyValue>{
  int _startIterator;
  final DxValue value;
  _DxValueIterator(this.value){
    _startIterator = 0;
  }
  @override
  KeyValue get current{
    if(value._isArray){
      return KeyValue("", value._values[_startIterator]);
    }
    return KeyValue(value._keys[_startIterator], value._values[_startIterator]);
  }

  @override
  bool moveNext() {
    _startIterator++;
    if(_startIterator < value._values.length){
      return true;
    }
    _startIterator = 0;
    return false;
  }

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

  String _jsonString(int level){
    StringBuffer stringBuffer = StringBuffer();
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
          }else{
            if (_values[i] != null && _values[i] is DxValue){
              stringBuffer.write((_values[i] as DxValue)._jsonString(level + 1));
            }else{
              stringBuffer.write(_values[i]);
            }

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
          }else{
            if (_values[i] != null && _values[i] is DxValue){
              stringBuffer.write((_values[i] as DxValue)._jsonString(level + 1));
            }else{
              stringBuffer.write(_values[i]);
            }
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
    if(key??"" == ""){
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

  int intByKey(String key,int defValue,[bool ignoreCase=true]){
    BaseValue v = valueByKey(key,ignoreCase);
    return (v == null)?defValue:v.asInteger(defValue: defValue);
  }

  double doubleByKey(String key,double defValue,[bool ignoreCase=true]){
    BaseValue v = valueByKey(key,ignoreCase);
    return (v == null)?defValue:v.asDouble(defValue: defValue);
  }

  bool boolByKey(String key,bool defValue,[bool ignoreCase=true]){
    BaseValue v = valueByKey(key,ignoreCase);
    return (v == null)?defValue:v.asBoolean(defValue: defValue);
  }

  DateTime dateTimeByKey(String key,DateTime defValue,[bool ignoreCase=true]){
    BaseValue v = valueByKey(key,ignoreCase);
    return (v == null)?defValue:v.asDateTime(defValue: defValue);
  }

  String stringByKey(String key,String defValue,[bool ignoreCase=true]){
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

  //dart字符串采用UTF-16编码
  @override
  String toString(){
    return _jsonString(0);
  }

  void clear(){
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

  void setKeyDouble(String key,double value){
    if(_isArray){
      return ;
    }
    int idx = _newKeyIndex(key);
    if(_values[idx] != null && _values[idx] is DoubleValue){
      (_values[idx] as DoubleValue).value = value;
      return;
    }
    _values[idx] = DoubleValue(value: value);
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

  void setKeyDxValue(String key,BaseValue value){
    int idx = _newKeyIndex(key);
    bool oldIsNull = (_values[idx]?.type)??(valueType.VT_Null) == valueType.VT_Null;
    valueType vt = value.type;
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

  void setKeyValue(String key,Object value){
    if(_isArray){
      return ;
    }
    if(value == null){
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

  @override
  int get length => _values.length;

  DxValue forceValue(String path,{bool arrayValue=false,String separator="/"}){
    if(path == ""){
      return null;
    }
    List<String> paths = path.split(separator);
    DxValue parentValue;
    parentValue = this;
    for(var i = 0;i<paths.length;i++){
      if (parentValue._isArray){
        int idx = int.tryParse(paths[i])??-1;
        if(idx == -1 || idx > parentValue.length - 1){ //不符合，需要替换
          if(i == 0){
            if(idx == 0 && parentValue.length == 0){
              parentValue = parentValue.newObject();
              continue;
            }
            return null;
          }
          parentValue = parentValue.newObject(key: paths[i]);
        }else{
          //在中间
          if(parentValue._values[idx] == null || !(parentValue._values[idx] is DxValue)){
            var newValue = DxValue(false);
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
         parentValue = parentValue.newObject(key: paths[i]);
       }else if(parentValue._values[index] == null || !(parentValue._values[index] is DxValue)){
         var newValue = DxValue(false);
         parentValue._values[index] = newValue;
         parentValue = newValue;
       }else{
         parentValue = parentValue._values[index];
       }
    }
    return parentValue;
  }
}

