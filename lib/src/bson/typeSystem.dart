// author: 不得闲
// email: 75492895@qq.com
// date: 2021-02-01
// BSON的类型系统定义

import 'package:flutter/material.dart';

enum BsonType{
  bsonNone,
  bsonDouble,                     //0x01 64-bit binary floating point
  bsonString,                     //0x02 UTF-8 string
  bsonEmbeddedDoc,                //0x03 Embedded document
  bsonArray,                      //0x04
  bsonBinary,                     //0x05
  bsonUndefined,                  //0x06
  bsonObjectID,                   //0x07
  bsonBoolean,                    //0x08
  bsonDateTime,                   //0x09
  bsonNull,                       //0x0A
  bsonRegex,                      //0x0B
  bsonDbPointer,                  //0x0C    DBPointer — Deprecated
  bsonJavaScript,                 //0x0D    JavaScript code w/ scope — Deprecated
  bsonSymbol,                     //0x0E    Symbol. — Deprecated
  bsonCodeWithScope,              //0x0F
  bsonInt32,                      //0x10
  bsonTimestamp,                  //0x11
  bsonInt64,                      //0x12
  bsonDecimal128                  //0x13
  /*
  bsonMinKey                      //0xFF
  bsonMaxKey                      //0x7F
  */
}

extension bsonTypeInfo on BsonType{
  String get name {
    switch(this){
      case BsonType.bsonDouble:
        return "double";
      case BsonType.bsonString:
        return "string";
      case BsonType.bsonEmbeddedDoc:
        return "EmbeddedDocument";
      case BsonType.bsonArray:
        return "array";
      case BsonType.bsonBinary:
        return "bin";
      case BsonType.bsonObjectID:
        return "ObjectID";
      case BsonType.bsonBoolean:
        return "boolean";
      case BsonType.bsonDateTime:
        return "dateTime";
      case BsonType.bsonNull:
        return "null";
      case BsonType.bsonRegex:
        return "regex";
      case BsonType.bsonDbPointer:
        return "dbPointer";
      case BsonType.bsonJavaScript:
        return "javaScript";
      case BsonType.bsonSymbol:
        return "symbol";
      case BsonType.bsonCodeWithScope:
        return "CodeWithScope";
      case BsonType.bsonInt32:
        return "int32";
      case BsonType.bsonTimestamp:
        return "timestamp";
      case BsonType.bsonInt64:
        return "int64";
      case BsonType.bsonDecimal128:
        return "decimal128";
      default:
        return "undefined";
    }
  }
}