# dxvalue
  
**[English](./README.md "English")**  **[中文简体](./README_CN.md "简体中文")**  
dart版本的超级值对象，支持Json,MsgPack，Bson
## 开始
### 1、构造函数
- 创建一个空白的DxValue
- 从Json创建一个DxValue
- 从MsgPack创建一个DxValue  
- 从Bson创建一个DxValue 

创建空白对象的时候，需要指定一个参数，用来表示要创建数组类型，还是要创建对象类型。
### 2、解码
- 通过构造函数 **DxValue.fromJson** 构建Json
- 通过构造函数 **DxValue.fromMsgPack** 构建MsgPack
- 通过构造函数 **DxValue.fromBson** 构建Bson
- 使用 **resetFromMsgPack** 针对已经构建好的对象解码MsgPack
- 使用 **resetFromJson** 针对已经构建好的对象解析Json
- 使用 **resetFromBson** 针对已经构建好的对象解析Bson
- 自己实现解码器，使用 **decodeWithCoder** 设定解码器进行解码

### 3、编码
- **encodeJson** 将DxValue编码到Json二进制
- **encodeMsgPack** 将DxValue编码到MsgPack二进制
- **encodeBson** 将DxValue编码到Bson二进制
- 自定义编码器，使用 **encodeWithCoder** 进行自定义编码

### 4、使用
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
### 5、设置值
设置可以使用set等一系列函数，进行设置，对于Object，可以使用setKey...相关的函数进行设定，对于数组，可以使用setIndex...等函数进行设定
构建新的对象，使用 **newObject**,**newArray**来构建子对象结构  

使用 **forceValue** 或者 **forcePath** 来强制构建一个不存在的路由路径
```dart
  DxValue dxvalue = DxValue(false);
  DxValue childHome = dxvalue.forceValue("root/home/childhome",arrayValue: false);
  DxValue homes = childHome.newArray(key: "homes");
  homes.setIndexInt(-1, 100);
  homes.setIndexString(-1, "平米");
  print(dxvalue);
```
这将会打印内容如下：
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

### 6、取值
取值相关函数，主要是 **...ByIndex** 或者 **...ByKey** 等函数组成，比如说 **valueByIndex, intByKey, doubleByKey, dateTimeByKey** 等
使用**clear**，清空对象

### 7、语法糖，操作符重载
对于DxValue，重载了[]操作符，所以，对于JsonObject，可以使用 [string]进行检索，对于数组可以使用 [int]进行数据获取，比如
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

重载了[]=操作符，可以直接使用本语法赋值，比如

```dart
DxValue value = DxValue(false);
value["Name"] = "不得闲";
value["Age"] = 32;
print(value);
```