import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dxvalue/dxvalue.dart';

void main() {
  test("test dxValue",(){
    DxValue dxvalue = DxValue(false);
    dxvalue.setKeyValue("Name", "不得闲");
    dxvalue.setKeyValue("Age", 32);
    dxvalue.setKeyValue("men", true);
    var childvalue = dxvalue.newObject(key: "child");
    childvalue.setKeyValue("Name", "child1");
    childvalue.setKeyValue("Age", 3);
    print(dxvalue);
    print(dxvalue["Name"]);
    print(dxvalue[1]);

    for(KeyValue kv in dxvalue){
      print(kv);
    }
  });
}
