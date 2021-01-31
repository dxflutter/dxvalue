import 'dart:convert';
import 'dart:typed_data';

import 'package:dxvalue/src/json/jsonparse.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dxvalue/dxvalue.dart';

void main() {
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
  test("test dxValue",(){
    DxValue strValue = DxValue.fromJson(st);
    print(strValue);
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
  });
}
