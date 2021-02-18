# dxvalue
  
**[English](./README.md "English")**  **[中文简体](./README_CN.md "简体中文")**  
A super value library support json,msgpack,bson.
## Getting Started
### 1、Constructors
- create an empty DxValue()
- create DxValue from Json
- create DxValue from MsgPack
- create DxValue from Bson

When creating a blank object, you need to specify a parameter to indicate whether you want to create an array type or an object type.

### 2、Decode
- use Constructors **DxValue.fromJson**  to decode  json
- use Constructors **DxValue.fromMsgPack** to decode msgpack
- use Constructors **DxValue.fromBson** to decode bson
- use **resetFromMsgPack** method to decode msgpack
- use **resetFromJson** method to decode json
- use **resetFromBson** method to decode bson
- use **decodeWithCoder** appoint custom decoder to decode custom Code

### 3、encode
- **encodeJson** 
- **encodeMsgPack**
- **encodeBson**
- use **encodeWithCoder** appoint custom encoder to encode custom code

### 4、useage
```dart
    DxValue dxValue = DxValue(false);
    dxValue.setKeyInt("fixInt1", 23);
    dxValue.setKeyInt("NegFixInt", -19);
    dxValue.setKeyInt("Int", 256);
    dxValue.setKeyInt("Int1", 255);
    dxValue.setKeyInt("Int2", 2255);
    dxValue.setKeyInt("Int3", 655234);
    dxValue.setKeyString("string", "字符串测试内燃烧地方，嘎斯的发生地方阿斯顿发生的发生地方阿三的发生地方");
    dxValue.setKeyString("fixStr", "测试Fix");
    dxValue.setKeyFloat("Float", 32.423);
    dxValue.setKeyDouble("Double",83.45234423424234);
    dxValue.setKeyDateTime("now", DateTime.now());
    String binary = """
  仙路尽头谁为峰，
  一见无始道成空。
  源天师，晚年不祥
""";
    dxValue.setKeyBinary("源天师", binary.toUtf8());
    dxValue.setKeyExtBinary("源天师2", 3, binary.toUtf8());
    dxValue.encodeMsgPack();
    dxValue.encodeJson();
```
### 5、setValues
You can use a series of functions such as set... to setValue. For object, you can use **setkey...** Related functions to set. For array, you can use **setIndex...** And other functions to set
To build a new object, use **newobject**, **newarray** to build a sub object structure

use **forceValue** or **forcePath**  can create an unexists path route 
```dart
  DxValue dxvalue = DxValue(false);
  DxValue childHome = dxvalue.forceValue("root/home/childhome",arrayValue: false);
  DxValue homes = childHome.newArray(key: "homes");
  homes.setIndexInt(-1, 100);
  homes.setIndexString(-1, "平米");
  print(dxvalue);
```
This will print as follows:
```json
{
  "root":{
    "home":{
      "childhome":{
        "homes":[
          100,
          "平米"
        ]
      }
    }
  }
}
```

### 6、getValues
If you want to get the value inside dxvalue,you can use some functions like **...ByIndex** or **...ByKey** 
such as **valueByIndex, intByKey, doubleByKey, dateTimeByKey** ...
use **clear** method to clear dxvalue

### 7、Syntax sugar, operator overloading
For dxvalue, the [] operator is overloaded. Therefore, for jsonobject, [string] can be used to retrieve data, and for array, [int] can be used to retrieve data, such as
```dart
DxValue value = DxValue(false);
value.setKeyString("Name","不得闲");
value.setKeyInt("Age",32);
print(value["Name"]);
print(value["Age"]);
DxValue childs = value.newArray(key: "childs");
childs.setIndexString(-1,"test");
print(childs[0]);
```

the operator []= is overloaded, you can directly use this syntax assignment, such as
```dart
DxValue value = DxValue(false);
value["Name"] = "不得闲";
value["Age"] = 32;
print(value);
```

