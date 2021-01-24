library dxvalue;

enum valueType{
  //简单元素的类型
  VT_Int,
  VT_Double,
  VT_DateTime,
  VT_Boolean,
  VT_String,
  VT_Null,
  //复杂数据结构
  VT_Object,
  VT_Array
}

//基类
abstract class BaseValue {
  get type {
    return valueType.VT_Null;
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

  num operator +(num other) => (value??0) + other;

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

  double operator +(num other) => (value??0) + other;

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

