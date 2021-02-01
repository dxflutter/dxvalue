// author: 不得闲
// email: 75492895@qq.com
// date: 2021-01-28
// 对基本类型的方法扩展
import 'dart:convert';

import 'dart:typed_data';

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

  Uint8List toUtf8(){
    return Utf8Encoder().convert(this);
  }
}

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

  String u8toString([Endian endian = Endian.big]){
    List<int> u16Lst = u8toU16List(endian);
    return u16Lst == null?"":String.fromCharCodes(u16Lst);
  }

  String utf8toString(){
    return Utf8Decoder().convert(this);
  }
}
