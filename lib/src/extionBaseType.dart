// author: 不得闲
// email: 75492895@qq.com
// date: 2021-01-28
// 对基本类型的方法扩展
import 'dart:convert';

import 'dart:typed_data';

import 'package:flutter/material.dart';

extension Uint8ListOnString on String {
  Uint8List toU8List([Endian endian = Endian.big]){
    List<int> lst = codeUnits;
    ByteData bd = ByteData(lst.length * 2);
    int index = 0;
    for(var i = 0;i<lst.length;i++){
      bd.setUint16(index, lst[i],endian);
      index += 2;
    }
    return Uint8List.view(bd.buffer);
  }

  Uint8List toGBK(){
    List<int> lst = codeUnits;
    BytesBuilder builder = BytesBuilder();
    for(var i = 0;i<lst.length;i++){
      if(lst[i] < 128){
        builder.addByte(lst[i]);
      }else{
        //第一字节81–FE
        //第二字节,40–7E, 80–FE
        //builder.addByte(byte)
      }
    }
  }

  Uint8List toUtf8(){
    return Utf8Encoder().convert(this);
  }

}

//vhex = ['0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F']
List<int> _vHex = [48,49,50,51,52,53,54,55,56,57,65,66,67,68,69,70];

extension extensionOnUint8List on Uint8List{
  List<int> u8toU16List([Endian endian = Endian.big]){
    int u16Len = length ~/ 2;
    if(u16Len == 0){
      return null;
    }
    ByteData bd = this.buffer.asByteData();
    List<int> lst = List(u16Len);
    int idx = 0;
    for(var i = 0;i<length;i=i+2){
      lst[idx] = bd.getUint16(i,endian);
      idx++;
    }
    return lst;
  }

  String toHex(){
    if(length == 0){
      return "";
    }
    StringBuffer stringBuffer = StringBuffer();
    for(var i = 0;i < length;i++){
      stringBuffer.writeCharCode(_vHex[this[i] >> 4]);
      stringBuffer.writeCharCode(_vHex[this[i] & 0x0f]);
    }
    return stringBuffer.toString();
  }

  void writeHex(StringBuffer stringBuffer){
    for(var i = 0;i < length;i++){
      stringBuffer.writeCharCode(_vHex[this[i] >> 4]);
      stringBuffer.writeCharCode(_vHex[this[i] & 0x0f]);
    }
  }

  String toHexWithFormat({bool arrStyle=true,int spaceLevel=0}){
    if(length == 0){
      return "";
    }
    Uint8List space = Uint8List(spaceLevel << 1);
    for(var i = 0;i < space.length;i++){
      space[i] = 32;
    }
    String spaceStr = String.fromCharCodes(space);

    StringBuffer stringBuffer = StringBuffer();
    int l = length;
    if(arrStyle){
      stringBuffer.write('[\r\n');
      stringBuffer.write(spaceStr);
      for(var i = 0,idx = 0;i < l;i++,idx++){
        stringBuffer.write("0x");
        stringBuffer.writeCharCode(_vHex[this[i] >> 4]);
        stringBuffer.writeCharCode(_vHex[this[i] & 0x0f]);
        if(i != l - 1){
          stringBuffer.write(',');
        }
        if(idx ==  15){
          idx = -1;
          stringBuffer.write("\r\n");
          stringBuffer.write(spaceStr);
        }
      }
      if(spaceLevel <= 1){
        stringBuffer.write('\r\n]');
      }else{
        stringBuffer.write('\r\n');
        stringBuffer.write(spaceStr.substring(spaceStr.length - ((spaceLevel - 1) << 1)));
        stringBuffer.write(']');
      }
    }else{
      stringBuffer.write('\r\n');
      stringBuffer.write(spaceStr);
      for(var i = 0,idx = 0;i < length;i++,idx++){
        stringBuffer.writeCharCode(_vHex[this[i] >> 4]);
        stringBuffer.writeCharCode(_vHex[this[i] & 0x0f]);
        if(idx ==  15){
          idx = -1;
          stringBuffer.write("\r\n");
          stringBuffer.write(spaceStr);
        }
      }
    }
    return stringBuffer.toString();
  }

  String u8toString([Endian endian = Endian.big]){
    List<int> u16Lst = u8toU16List(endian);
    return u16Lst == null?"":String.fromCharCodes(u16Lst);
  }

  String utf8toString(){
    return Utf8Decoder().convert(this);
  }
}


/*Delphi日期初始函数
   Delphi的日期规则为到1899-12-30号的天数+当前的毫秒数/一天的总共毫秒数集合
*/
DateTime _delphiFirstTime= DateTime(1899,12,30); //Delphi的初始化时间
DateTime _delphiUtcTime = DateTime.utc(1899,12,30);

extension dateTimeFromDelphiTime on double{
  DateTime toTime(){
    if(this <= 0){
      return DateTime(0);
    }
    int days = toInt();
    double ms = this - days.toDouble();
    ms = ms * Duration.millisecondsPerDay;
    return _delphiFirstTime.add(Duration(days: days,milliseconds: ms.toInt()));
  }
}

extension delphiTimeonDateTime on DateTime{
  //转换到DelphiTime
  double toDelphiTime(){
    if (this.year == 0 && this.day == 0 && this.month == 0){
      return 0;
    }
    Duration duration;
    DateTime date;
    if (this.isUtc){
      duration = this.difference(_delphiUtcTime);
      date = DateTime.utc(this.year,this.month,this.day);
    }else{
      duration = this.difference(_delphiFirstTime);
      date = DateTime(this.year,this.month,this.day);
    }
    int days = duration.inHours ~/ 24;
    Duration timeSecs = this.difference(date);
    return days.toDouble() + timeSecs.inMilliseconds / Duration.millisecondsPerDay;
  }
}