import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dxvalue/src/json/jsonparse.dart';
import 'package:dxvalue/src/msgpack/coder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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

  JsonParse jsonParse = JsonParse(null);
  DxValue strValue = DxValue(true);
  strValue.decodeWithCoder(st.toUtf8(), jsonParse);

  //DxValue strValue = DxValue.fromJson(st);
  //print(strValue);
  print(String.fromCharCodes(strValue.encodeJson()));



  st = JsonEncoder.encode(strValue);
  print("------strvalue Is------\r\n"+st);
  DxValue newValue = DxValue.fromJson(st);
  print("------newValue Is------\r\n"+newValue.toString());

  Uint8List u8list = JsonEncoder.toU8List(newValue,format: true,utf8: false);
  print(String.fromCharCodes(u8list));

  newValue.clear();

  print("---JsonParse Unicode----");
  newValue.resetFromJsonBytes(u8list);
  print(newValue);



  u8list = JsonEncoder.toU8List(newValue,format: true,utf8: true);
  print("---utf8toString----");
  print(u8list.utf8toString());

  //parse.reset(u8list);
  print("---JsonParse Utf8----");
  newValue.clear();
  newValue.resetFromJsonBytes(u8list);
  print(newValue);

  print(newValue.valueByKey("Author"));
  print(newValue["Author"]);
  //print(parse.parse());

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



  File file = File("d:/1.bin");
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
  Uint8List bytes = dxValue.encodeWithCoder(MsgPackParser());
  file.writeAsBytes(bytes,mode: FileMode.write,flush: true);
}

void testBson(){
  File file = File("d:/2.bson");
  DxValue dxValue;
  if(file.existsSync()) {
    Uint8List u8List = file.readAsBytesSync();
    dxValue = DxValue.fromBson(u8List);
    print(dxValue);

    u8List = dxValue.encodeBson();
    dxValue.clear();
    dxValue.resetFromBson(u8List);
    print(dxValue);

  }
}

void main() {
  test("json dxValue",(){
    testJson();
  });
  test("msgPack dxValue",(){
    testMsgPack();
  });
  test("bson dxValue",(){
    testBson();
  });
}
