import 'package:flutter_test/flutter_test.dart';

import 'package:dxvalue/dxvalue.dart';

void main() {

  IntValue intvalue = IntValue();
  print(intvalue/5);
  BaseValue base;
  base = IntValue();
  print(base.type.toString());
  print(base.asInteger(defValue: 32));
  print(base.asDouble());

  BaseValue base1,base2;
  base1 = IntValue(value: 32);
  base2 = DoubleValue(value: 32.3);
  print((base1 as IntValue) + base2);



  //print(bas)

  print("类型："+intvalue.type.toString()+",value="+intvalue.toString());
  intvalue.value = 1;
  double b = 23;
  if (intvalue == b){
    print("EquOK");
  }

  DateTimeValue dtvalue = DateTimeValue();
  print(dtvalue);

  DateTime dt = DateTimeValue.dateTimeFromDelphi(44220.8062488773);
  print(dt.toString());
  print(DateTimeValue.toDelphiTime(dt));


  b = 30.3;
  print("${intvalue + b}");
  print("${intvalue & 0}");


  test("test dxValue",(){
    /*final intvalue = IntValue();
    print(intvalue.type);*/
  });
}
