library dxvalue;

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum valueType{
  //简单元素的类型
  VT_Int,
  VT_Double,
  VT_DateTime,
  VT_Boolean,
  VT_String,
  VT_Null,
  VT_Binary,
  //复杂数据结构
  VT_Object,
  VT_Array
}

//基类
abstract class BaseValue {
  get type {
    return valueType.VT_Null;
  }

  int asInteger({int defValue}){
    switch (type){
      case valueType.VT_Int:
        return (this as IntValue).value??defValue;
      case valueType.VT_Double:
        return (this as DoubleValue).value?.toInt()??defValue;
      case valueType.VT_Boolean:
        return ((this as BoolValue).value??false)?1:0;
      case valueType.VT_DateTime:
        return DateTimeValue.toDelphiTime((this as DateTimeValue).value??DateTime(0)).toInt();
      case valueType.VT_Null:
        return 0;
      case valueType.VT_String:
        if ((this as StringValue).value == null){
          return defValue;
        }
        return int.tryParse((this as StringValue).value,radix: defValue);
    }
    return defValue;
  }

  double asDouble({double defValue}){
    switch (type){
      case valueType.VT_Int:
        return (this as IntValue).value?.toDouble()??defValue;
      case valueType.VT_Double:
        return (this as DoubleValue).value??defValue;
      case valueType.VT_Boolean:
        return ((this as BoolValue).value??false)?1:0;
      case valueType.VT_DateTime:
        return DateTimeValue.toDelphiTime((this as DateTimeValue).value??DateTime(0));
      case valueType.VT_Null:
        return 0;
      case valueType.VT_String:
        if ((this as StringValue).value == null){
          return defValue;
        }
        return double.tryParse((this as StringValue).value);
    }
    return defValue;
  }

  DateTime asDateTime({DateTime defValue}){
    switch (type){
      case valueType.VT_Int:
        return (this as IntValue).value?.toDouble()??defValue;
      case valueType.VT_Double:
        return (this as DoubleValue).value??defValue;
      case valueType.VT_DateTime:
        return (this as DateTimeValue).value;
      case valueType.VT_String:
        return DateTime.tryParse((this as StringValue).value)??defValue;
    }
    return defValue;
  }

  bool asBoolean({bool defValue}){
    switch (type){
      case valueType.VT_Int:
        return (this as IntValue).value??0 != 0;
      case valueType.VT_Double:
        return (this as DoubleValue).value??0 != 0;
      case valueType.VT_Boolean:
        return (this as BoolValue).value??false;
      case valueType.VT_DateTime:
        return DateTimeValue.toDelphiTime((this as DateTimeValue).value??DateTime(0)) > 0;
      case valueType.VT_Null:
        return false;
      case valueType.VT_String:
        if ((this as StringValue).value == null){
          return false;
        }
        return (this as StringValue).value == "true";
    }
    return defValue;
  }

  String asString(){
    return toString();
  }
}

class IntValue  extends BaseValue{
  int value;
  IntValue({this.value});

  @override
  get type => valueType.VT_Int;

  IntValue.fromString(String vStr){
    value = int.tryParse(vStr,radix: value);
  }

  bool operator == (Object other){
    if(other is IntValue){
      return value == other.value;
    }
    if(other is num){
      return value == other;
    }
    return false;
  }

  int operator &(int other)=>other & (value??0);

  int operator |(int other) => (value??0) | other;

  int operator ^(int other) => (value??0) ^ other;

  int operator ~() => ~(value??0);

  int operator <<(int shiftAmount) => (value??0) << shiftAmount;

  int operator >>(int shiftAmount)=> (value??0) >> shiftAmount;

  Object operator +(Object other){
    if (other is num){
      return (value??0) + other;
    }
    if (other is String){
      return (value?.toString())??""+other;
    }
    if (other is IntValue){
      return value + other.value;
    }
    if (other is DoubleValue){
      return value + other.value;
    }
    if (other is StringValue){
      return (value?.toString())??""+other.value??"";
    }
    throw FormatException("unSuport data type",other);
  }

  num operator *(num other) => (value??0) * other;

  num operator /(num other) => (value??0) / other;

  num operator -(num other)=> (value??0) - other;

  double operator %(num other) => (value??0) % other;

  @override
  String toString() => (value??0).toString();

  @override
  // TODO: implement hashCode
  int get hashCode => super.hashCode;

}

class DoubleValue extends BaseValue{
  double value;
  DoubleValue({this.value});

  @override
  get type => valueType.VT_Double;

  DoubleValue.fromString(String vStr){
    value = double.tryParse(vStr);
  }

  @override
  String toString() => value.toString();

  bool operator == (Object other){
    if (other is double){
      return other == value;
    }
    if (other is int){
      return other.toDouble() == value;
    }
    return false;
  }

  int operator ~/(num other) => (value??0) ~/ other;

  Object operator +(Object other){
    if (other is num){
      return (value??0) + other;
    }
    if (other is String){
      return (value?.toString())??""+other;
    }
    if (other is IntValue){
      return value + other.value;
    }
    if (other is DoubleValue){
      return value + other.value;
    }
    if (other is StringValue){
      return (value?.toString())??""+other.value??"";
    }
    throw FormatException("unSuport data type",other);
  }

  double operator -(num other) => (value??0) - other;

  double operator /(num other) => (value??0)/other;

  double operator %(num other) => (value??0) % other;

  double operator *(num other) => (value??0) * other;

  @override
  // TODO: implement hashCode
  int get hashCode => super.hashCode;

}

class DateTimeValue extends BaseValue{
  DateTime value;
  /*Delphi日期初始函数
   Delphi的日期规则为到1899-12-30号的天数+当前的毫秒数/一天的总共毫秒数集合
   */
  static DateTime _delphiFirstTime= DateTime(1899,12,30); //Delphi的初始化时间
  static DateTime _delphiUtcTime = DateTime.utc(1899,12,30);
  //转换到DelphiTime
  static double toDelphiTime(DateTime time){
    if (time.year == 0 && time.day == 0 && time.month == 0){
      return 0;
    }
    Duration duration;
    DateTime date;
    if (time.isUtc){
      duration = time.difference(_delphiUtcTime);
      date = DateTime.utc(time.year,time.month,time.day);
    }else{
      duration = time.difference(_delphiFirstTime);
      date = DateTime(time.year,time.month,time.day);
    }
    int days = duration.inHours ~/ 24;
    Duration timeSecs = time.difference(date);
    return days.toDouble() + timeSecs.inMilliseconds / Duration.millisecondsPerDay;
  }

  static DateTime dateTimeFromDelphi(double delphiTime){
    if (delphiTime == 0){
      return DateTime(0);
    }
    int days = delphiTime.toInt();
    double ms = delphiTime - days.toDouble();
    ms = ms * Duration.millisecondsPerDay;
    return _delphiFirstTime.add(Duration(days: days,milliseconds: ms.toInt()));
  }

  DateTimeValue({this.value});

  DateTimeValue.fromDelphi(double delphiTime){
    value = dateTimeFromDelphi(delphiTime);
  }

  DateTimeValue.fromString(String vStr){
    DateTime v = DateTime.tryParse(vStr);
    if (v != null){
      value = v;
    }
    double d = double.tryParse(vStr);
    if (d != null){
      value = dateTimeFromDelphi(d);
    }
  }

  @override
  get type {
    return valueType.VT_DateTime;
  }

  @override
  String toString() => value.toString();

  bool operator == (Object other){
    if (other is DateTimeValue){
      return other.value == value;
    }
    if (other is double){
      return dateTimeFromDelphi(other) == value;
    }
    return false;
  }

  DateTime operator +(Duration other){
    return (value??DateTime(0)).add(other);
  }

  @override
  // TODO: implement hashCode
  int get hashCode => super.hashCode;

}

class BoolValue extends BaseValue{
  bool value;
  BoolValue({this.value});
  BoolValue.fromString(String vStr){
    value = bool.fromEnvironment(vStr);
  }

  @override
  get type {
    return valueType.VT_Boolean;
  }

  @override
  String toString() => (value??false).toString();

  bool operator == (Object other){
    if(other is BoolValue){
      return value == other.value;
    }
    if(other is bool){
      return value == other;
    }
    return false;
  }

  @override
  // TODO: implement hashCode
  int get hashCode => super.hashCode;
}

class StringValue extends BaseValue{
  String value;

  StringValue({this.value});

  @override
  get type {
    return valueType.VT_String;
  }

  String operator +(String other) => (value??"") + other;
  bool operator == (Object other){
    if(other is StringValue){
      return value == other.value;
    }
    if(other is String){
      return value == other;
    }
    return false;
  }

  @override
  // TODO: implement hashCode
  int get hashCode => super.hashCode;
}

class BinaryValue extends BaseValue{
  Uint8List binary;
  @override
  get type => valueType.VT_Binary;

  Uint8List asBytes() => binary;

}

class DxValue extends BaseValue{
  bool _isArray;
  List<BaseValue> _values;
  List<String> _keys;
  @override
  get type {
    if(_isArray){
      return valueType.VT_Array;
    }
    return valueType.VT_Object;
    //BytesBuilder
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
    if(key??"" == ""){
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
    if(_isArray || key == null){
      return null;
    }
    if(ignoreCase){
      key = key.toLowerCase();
      for(var i = 0;i<_keys.length;i++){
        if(key.compareTo(_keys[i].toLowerCase()) == 0){
          return _values[i];
        }
      }
    }else{
      for(var i = 0;i<_keys.length;i++){
        if(key == _keys[i]){
          return _values[i];
        }
      }
    }
    return null;
  }

  BaseValue valueByIndex(int index){
    if(index == null || index < 0 || index > _values.length - 1){
      return null;
    }
    return _values[index];
  }


}

