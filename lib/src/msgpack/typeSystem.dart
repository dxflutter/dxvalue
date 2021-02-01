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
  msgPackFormatNegFixInt  //0xe0-0xff  小负数
}


