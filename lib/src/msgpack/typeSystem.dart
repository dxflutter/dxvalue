// author: 不得闲
// email: 75492895@qq.com
// date: 2021-02-01
// MsgPack的类型系统定义

enum msgPackFormatCode{
  msgPackFormatFixInt,   //0x00-0x7f
  msgPackFormatFixMap,   //0x80-0x8f
  msgPackFormatFixArray, //0x90-0x9f
  msgPackFormatFixStr,   //0xa0-0xbf
  msgPackFormatNil,      //0xc0
  msgPackFormatUnUsed,   //0xc1
  msgPackFormatFalse,    //0xc2
  msgPackFormatTrue,     //0xc3
  msgPackFormatBin8,     //0xc4
  msgPackFormatBin16,    //0xc5
  msgPackFormatBin32,    //0xc6
  msgPackFormatExt8,     //0xc7
  msgPackFormatExt16,    //0xc8
  msgPackFormatExt32,    //0xc9

  msgPackFormatFloat,    //0xca
  msgPackFormatDouble,   //0xcb

  msgPackFormatUInt8,    //0xcc
  msgPackFormatUInt16,   //0xcd
  msgPackFormatUInt32,   //0xce
  msgPackFormatUInt64,   //0xcf
  msgPackFormatInt8,     //0xd0
  msgPackFormatInt16,    //0xd1
  msgPackFormatInt32,    //0xd2
  msgPackFormatInt64,    //0xd3

  msgPackFormatFixExt1,  //0xd4
  msgPackFormatFixExt2,  //0xd5
  msgPackFormatFixExt4,  //0xd6
  msgPackFormatFixExt8,  //0xd7
  msgPackFormatFixExt16, //0xd8
  msgPackFormatStr8,     //0xd9
  msgPackFormatStr16,    //0xda
  msgPackFormatStr32,    //0xdb
  msgPackFormatArray16,  //0xdc
  msgPackFormatArray32,  //0xdd
  msgPackFormatMap16,    //0xde
  msgPackFormatMap32,    //0xdf
  msgPackFormatNegFixInt //0xe0-0xff  小负数
}

class FormatCodeValue{
  msgPackFormatCode code;
  int value;
  FormatCodeValue(this.code,this.value);
  FormatCodeValue.from(int formatCode) {
    reset(formatCode);
  }

  bool isMap(){
    return code == msgPackFormatCode.msgPackFormatFixMap || code == msgPackFormatCode.msgPackFormatMap16 || code == msgPackFormatCode.msgPackFormatMap32;
  }

  bool isArray(){
    return code == msgPackFormatCode.msgPackFormatFixArray || code == msgPackFormatCode.msgPackFormatArray16 || code == msgPackFormatCode.msgPackFormatArray32;
  }

  bool isString(){
    return code == msgPackFormatCode.msgPackFormatFixStr || code.index >= msgPackFormatCode.msgPackFormatStr8.index && code.index <= msgPackFormatCode.msgPackFormatStr32.index;
  }

  bool isFixInt(){
    return code == msgPackFormatCode.msgPackFormatFixInt || code == msgPackFormatCode.msgPackFormatNegFixInt;
  }

  bool isInt(){
    return  isFixInt() || code.index >= msgPackFormatCode.msgPackFormatUInt8.index && code.index <= msgPackFormatCode.msgPackFormatInt64.index;
  }

  bool isBin(){
    return code.index >= msgPackFormatCode.msgPackFormatBin8.index && code.index <= msgPackFormatCode.msgPackFormatBin32.index;
  }

  bool isExt(){
    return code.index >= msgPackFormatCode.msgPackFormatExt8.index && code.index <= msgPackFormatCode.msgPackFormatExt32.index;
  }

  bool isFixExt(){
    return code.index >= msgPackFormatCode.msgPackFormatFixExt1.index && code.index <= msgPackFormatCode.msgPackFormatFixExt16.index;
  }

  void reset(int formatCode){
    switch(formatCode){
      case 0xc0:
        code = msgPackFormatCode.msgPackFormatNil;
        value = null;
        return;
      case 0xc1:
        code = msgPackFormatCode.msgPackFormatUnUsed;
        value = null;
        return;
      case 0xc2:
        code = msgPackFormatCode.msgPackFormatFalse;
        value = null;
        return;
      case 0xc3:
        code = msgPackFormatCode.msgPackFormatTrue;
        value = null;
        return;
      case 0xc4:
        code = msgPackFormatCode.msgPackFormatBin8;
        value = null;
        return;
      case 0xc5: 
        code = msgPackFormatCode.msgPackFormatBin16;
        value = null;
        return;
      case 0xc6: 
        code = msgPackFormatCode.msgPackFormatBin32;
        value = null;
        return;
      case 0xc7: 
        code = msgPackFormatCode.msgPackFormatExt8;
        value = null;
        return;
      case 0xc8: 
        code = msgPackFormatCode.msgPackFormatExt16;
        value = null;
        return;
      case 0xc9:
        code = msgPackFormatCode.msgPackFormatExt32;
        value = null;
        return;
      case 0xca:
        code = msgPackFormatCode.msgPackFormatFloat;
        value = null;
        return;
      case 0xcb:
        code = msgPackFormatCode.msgPackFormatDouble;
        value = null;
        return;
      case 0xcc:
        code = msgPackFormatCode.msgPackFormatUInt8;
        value = null;
        return;
      case 0xcd:
        code = msgPackFormatCode.msgPackFormatUInt16;
        value = null;
        return;
      case 0xce:
        code = msgPackFormatCode.msgPackFormatUInt32;
        value = null;
        return;
      case 0xcf:
        code = msgPackFormatCode.msgPackFormatUInt64;
        value = null;
        return;
      case 0xd0:
        code = msgPackFormatCode.msgPackFormatInt8;
        value = null;
        return;
      case 0xd1:
        code = msgPackFormatCode.msgPackFormatInt16;
        value = null;
        return;
      case 0xd2:
        code = msgPackFormatCode.msgPackFormatInt32;
        value = null;
        return;
      case 0xd3:
        code = msgPackFormatCode.msgPackFormatInt64;
        value = null;
        return;
      case 0xd4:
        code = msgPackFormatCode.msgPackFormatFixExt1;
        value = null;
        return;
      case 0xd5:
        code = msgPackFormatCode.msgPackFormatFixExt2;
        value = null;
        return;
      case 0xd6:
        code = msgPackFormatCode.msgPackFormatFixExt4;
        value = null;
        return;
      case 0xd7:
        code = msgPackFormatCode.msgPackFormatFixExt8;
        value = null;
        return;
      case 0xd8:
        code = msgPackFormatCode.msgPackFormatFixExt16;
        value = null;
        return;
      case 0xd9:
        code = msgPackFormatCode.msgPackFormatStr8;
        value = null;
        return;
      case 0xda:
        code = msgPackFormatCode.msgPackFormatStr16;
        value = null;
        return;
      case 0xdb:
        code = msgPackFormatCode.msgPackFormatStr32;
        value = null;
        return;
      case 0xdc:
        code = msgPackFormatCode.msgPackFormatArray16;
        value = null;
        return;
      case 0xdd:
        code = msgPackFormatCode.msgPackFormatArray32;
        value = null;
        return;
      case 0xde:
        code = msgPackFormatCode.msgPackFormatMap16;
        value = null;
        return;
      case 0xdf:
        code = msgPackFormatCode.msgPackFormatMap32;
        value = null;
        return;
      default:
        if(formatCode >= 0x00 && formatCode <= 0x7f){
          code = msgPackFormatCode.msgPackFormatFixInt;
          value = formatCode;
          return;
        }
        if(formatCode >= 0x80 && formatCode <=0x8f){
          code = msgPackFormatCode.msgPackFormatFixMap;
          value = formatCode & 0x0f;
          return;
        }
        if(formatCode >= 0x90 && formatCode <= 0x9f){
          code = msgPackFormatCode.msgPackFormatFixArray;
          value = formatCode & 0x0f;
          return;
        }

        if(formatCode >= 0xa0 && formatCode <= 0xbf){
          code = msgPackFormatCode.msgPackFormatFixStr;
          value = formatCode & 0x1f;
          return;
        }
        if(formatCode >= 0xe0 && formatCode <= 0xff){
          code = msgPackFormatCode.msgPackFormatNegFixInt;
          value = formatCode - 256;
          return;
        }
    }
    code = msgPackFormatCode.msgPackFormatUnUsed;
    value = null;
  }
}