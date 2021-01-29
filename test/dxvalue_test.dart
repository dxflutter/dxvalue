import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dxvalue/dxvalue.dart';

void main() {
  test("test dxValue",(){

    print(int.tryParse("23",radix: 16));

    DxValue mb = DxValue(true);
    mb.forceValue("0/dxsoft/gg",arrayValue: true);
    print(mb);
    mb.forceValue("0/dxsoft",arrayValue: true);
    print(mb);
    DxValue namemb = mb.forceValue("0/dxsoft/gg/dxsoft");
    namemb.setKeyInt("Age", 23);
    namemb.setKeyString("Name", "测试人");
    print(mb);
    mb.forceInt("0/dxsoft/gg", 32);
    print(mb);

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
