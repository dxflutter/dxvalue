// author: 不得闲
// email: 75492895@qq.com
// date: 2021-01-20
// 万能值对象基类BaseValue

import 'dart:typed_data';
import 'extionBaseType.dart';

enum valueType{
  //简单元素的类型
  VT_Int,
  VT_Double,
  VT_Float,
  VT_DateTime,
  VT_Boolean,
  VT_String,
  VT_Null,
  VT_Binary,
  //复杂数据结构
  VT_Object,
  VT_Array
}

abstract class DxValueMarshal{
  BaseValue toDxValue();
  void fromDxValue(BaseValue fromValue);
}

class KeyValue {
  String key;
  BaseValue value;
  KeyValue(this.key,this.value);
  @override
  String toString(){
    return "Key=$key\r\nvalue=$value";
  }
}

//基类
abstract class BaseValue extends Iterable<KeyValue>{
  get type {
    return valueType.VT_Null;
  }

  @override
  Iterator<KeyValue> get iterator => throw UnimplementedError();

  int asInteger({int defValue}){
    switch (type){
      case valueType.VT_Int:
        return (this as IntValue).value??defValue;
      case valueType.VT_Double:
        return (this as DoubleValue).value?.toInt()??defValue;
      case valueType.VT_Boolean:
        return ((this as BoolValue).value??false)?1:0;
      case valueType.VT_DateTime:
        return (this as DateTimeValue).value??DateTime(0).toDelphiTime().toInt();
      case valueType.VT_Null:
        return 0;
      case valueType.VT_String:
        if ((this as StringValue).value == null){
          return defValue;
        }
        return int.tryParse((this as StringValue).value)??defValue;
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
        return (this as DateTimeValue).value??DateTime(0).toDelphiTime();
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
        return (this as DateTimeValue).value??DateTime(0).toDelphiTime() > 0;
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

  Object operator +(Object other){
    if(other is String || this is StringValue || other is StringValue){
      return toString()+other.toString();
    }
    if(other is num){
      if(this is IntValue){
        return (this as IntValue).value??0 + other;
      }
      if(this is DoubleValue){
        return (this as DoubleValue).value??0 + other;
      }
      throw FormatException("不支持的操作");
    }
    if(other is IntValue){
      if(this is IntValue){
        return (this as IntValue).value??0 + other.value;
      }
      if(this is DoubleValue){
        return (this as DoubleValue).value??0 + other.value;
      }
      throw FormatException("不支持的操作");
    }
    if (other is DoubleValue){
      if(this is IntValue){
        return (this as IntValue).value??0 + other.value;
      }
      if(this is DoubleValue){
        return (this as DoubleValue).value??0 + other.value;
      }
    }
    throw FormatException("不支持的操作");
  }
}

class IntValue  extends BaseValue{
  int value;
  IntValue({this.value});

  @override
  get type => valueType.VT_Int;

  IntValue.fromString(String vStr){
    value = int.tryParse(vStr)??value;
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
  bool float32;
  DoubleValue({this.value}){
    float32 = false;
  }

  DoubleValue.fromFloat({this.value}){
    float32 = true;
  }

  @override
  get type {
    if(float32){
      return valueType.VT_Float;
    }
    return valueType.VT_Double;
  }

  DoubleValue.fromString(String vStr){
    value = double.tryParse(vStr);
    float32 = false;
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
  DateTimeValue({this.value});
  DateTimeValue.fromDelphi(double delphiTime){
    value = delphiTime.toTime();
  }
  DateTimeValue.fromString(String vStr){
    DateTime v = DateTime.tryParse(vStr);
    if (v != null){
      value = v;
    }
    double d = double.tryParse(vStr);
    if (d != null){
      value = d.toTime();
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
      if(value == null && other == null){
        return true;
      }
      return (value != null) && other == value.toDelphiTime();
    }
    return false;
  }

  DateTime operator +(covariant Duration other){
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

  String operator +(covariant String other) => (value??"") + other;
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
  String toString() => value.toString();

  @override
  // TODO: implement hashCode
  int get hashCode => super.hashCode;
}
