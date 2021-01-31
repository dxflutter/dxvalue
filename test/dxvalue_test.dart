import 'dart:convert';
import 'dart:typed_data';

import 'package:dxvalue/src/json/jsonparse.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dxvalue/dxvalue.dart';

void main() {
  /*String st = '{   "Name": false, "b\\u6d4b\\u8bd5\\u4e2da":"asdf","\\u6587\\u8f6c\\u6362":23.34}';
  print(st);
  var parse = JsonParse(Uint8List.fromList(st.codeUnits));
  print(parse.parse()) ;*/
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
    //print(parse.parse());
  });
}
