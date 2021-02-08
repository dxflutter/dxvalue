import 'dart:typed_data';
import 'dart:io';
import 'package:dxvalue/dxvalue.dart';

void testJson(){
  String st = """
{
  "Author": "辰东",
  "Age": 40,
  "Birth": "/Date(1612097634950)/",
  "Books":[
     {
        "Name": "遮天",
        "Pages": 13234,
        "Start": "2013-9-20",
        "publish":["17K","红袖添香","轻舞飞扬","越岳飞"]
     },
     {
        "Name": "神墓",
        "Pages": 1324,
        "Start": "2008-9-20",
        "publish":[
          "17K","红袖添香",
          {
            "Name": "阅文集团",
            "Month":12
          }
        ]
     }
  ]
}  
  """;
  DxValue strValue = DxValue(true);
  strValue.resetFromJson(st);
  print(strValue);
  //DxValue strValue = DxValue.fromJson(st);

  Uint8List jsonBytes =  strValue.encodeJson();
  print(String.fromCharCodes(jsonBytes));

  strValue.clear();

  DxValue tempValue = DxValue(false);
  DxValue record = tempValue.forcePath(["路径1","路径2","路径3"],false);
  record.setKeyString("路径4", "测试数据");
  print(tempValue);
}

void testMsgPack(){

  DxValue value = DxValue(false);
  value["Name"] = "不得闲";
  value["Age"] = 32;
  print(value);


  File file = File("./1.bin");
  DxValue dxValue;
  if(file.existsSync()){
    Uint8List u8List = file.readAsBytesSync();
    dxValue = DxValue.fromMsgPack(u8List);
    print(dxValue);

    BaseValue value = dxValue.valueByKey("源天师");
    if(value != null && value.type == valueType.VT_Binary){
      File file = File("d:/源天师.txt");
      file.writeAsBytes((value as BinaryValue).binary,mode: FileMode.write,flush: true);
    }
  }else{
    dxValue = DxValue(false);
  }

  dxValue.clear();
  dxValue.resetValueType(false);
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
  Uint8List bytes = dxValue.encodeMsgPack();
  file.writeAsBytes(bytes,mode: FileMode.write,flush: true);
}

void main(){
  testJson();
  testMsgPack();
}