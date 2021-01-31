
import 'dart:ffi';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dxvalue/dxvalue.dart';
import 'package:dxlibrary/dxlibrary.dart';

//json中字符串的标记格式内容
enum stringStyle{
  str_Utf8,
  str_Unicode,
  str_Utf16,
}

class JsonParse{
  final Uint8List _dataList;
  final stringStyle _strStyle;
  int _offset=0;

  JsonParse(this._dataList,[this._strStyle=stringStyle.str_Utf8]);
  JsonParse.fromList(List<int> l,[stringStyle strStyle=stringStyle.str_Utf8]): this(Uint8List.fromList(l),strStyle);


  void _skipWhiteSpace(){
    int maxLen = _dataList.length;
    while(_offset < maxLen){
      int bt = _dataList[_offset];
      if(bt != 0x20 && bt != 0x13 && bt != 0x10 && bt != 0x09){ // 空格，回车换行和Tab
        return;
      }
      _offset++;
    }
  }

  DxValue parse(){
    _skipWhiteSpace();
    int bt = _dataList[_offset];
    switch(bt){
      case 0x5B:
        //[ 数组开始
        //] 0x5D
        _offset++;
        DxValue result = DxValue(true);
        parseArray(result);
        return result;
      case 0x7B:
        //{对象  ,} 0x7D
        _offset++;
        DxValue result = DxValue(false);
        parseObject(result);
        return result;
      default:
        throw FormatException("无效的Json格式$_offset");
    }
  }

  //读取字符串
  String _readString(){
    _skipWhiteSpace();
    int charCode = _dataList[_offset];
    if(charCode != 0x22){
      throw FormatException("无效的Json格式$_offset");
    }
    _offset++;
    //找下一个字符串标记
    bool isEscape = false;
    bool isUnicode = false;
    int _strIndex = _offset;
    //new Runes(string)
    bool isByteList = true;
    List<int> byteList = List<int>(); //uint8
    int unicodeCount = 0; //记录unicode
    List<int> unicodeList = List<int>();
    while(_strIndex < _dataList.length){
      charCode = _dataList[_strIndex];
      _strIndex ++;
      if(isUnicode){
        // \u \U
        if(charCode >= 0x30 && charCode <= 0x39 ||
            charCode >= 0x41 && charCode <= 0x5A ||
            charCode >=0x61 && charCode <= 0x7A){
          unicodeCount++;
          isUnicode = unicodeCount < 4;
        }else{
          isUnicode = false;
        }
        if(!isUnicode){
          isEscape = false;
          //完毕了
          var unicode = String.fromCharCodes(_dataList.sublist(_strIndex-unicodeCount,_strIndex));
          int unicodeCharCode = int.tryParse(unicode,radix: 16);
          unicodeList.add(unicodeCharCode);
          isEscape = false;
        }
        continue;
      }
      if(!isEscape){
        if(charCode == 0x22){
          //字符串完毕了
          _offset = _strIndex;
          if(isByteList){
            return Utf8Decoder().convert(Uint8List.fromList(byteList));
          }
          return String.fromCharCodes(unicodeList);
        }
        isEscape = charCode == 0x5C; //是转义字符
        if(!isEscape){
          if(isByteList){
            byteList.add(charCode);
          }else{
            unicodeList.add(charCode);
          }
        }
      }else if(!isUnicode){
        switch(charCode){
          case 0x6E:
          // \n
            if(isByteList){
              byteList.add(0x0A);
            }else{
              unicodeList.add(0x0A);
            }
            break;
          case 0x72:
          // \r
            if(isByteList){
              byteList.add(0x0D);
            }else{
              unicodeList.add(0x0D);
            }
            break;
          case 0x74:
          // \t
            if(isByteList){
              byteList.add(0x09);
            }else{
              unicodeList.add(0x09);
            }
            break;
          case 0x55:
          // \U
          case 0x75:
          // \u
            if(isByteList){
              isByteList = false;
              //要将之前的byteList的内容全部移动过来
              unicodeList.addAll(byteList);
              byteList.clear();
            }
            unicodeCount = 0;
            isUnicode = true;
            break;
          case 0x61:
            // \a
            if(isByteList){
              byteList.add(0x07);
            }else{
              unicodeList.add(0x07);
            }
            break;
          case 0x62:
            // \b
            if(isByteList){
              byteList.add(0x08);
            }else{
              unicodeList.add(0x08);
            }
            break;
          case 0x66:
            // \f
            if(isByteList){
              byteList.add(0x0C);
            }else{
              unicodeList.add(0x0C);
            }
            break;
          case 0x76:
            // \v
            if(isByteList){
              byteList.add(0x0B);
            }else{
              unicodeList.add(0x0B);
            }
            break;
          case 0x5c:
            // \\
            if(isByteList){
              byteList.add(92);
            }else{
              unicodeList.add(92);
            }
            break;
          case 0x22:
            // \"
            if(isByteList){
              byteList.add(0x22);
            }else{
              unicodeList.add(0x22);
            }
            break;
          case 0x27:
            // \'
            if(isByteList){
              byteList.add(0x27);
            }else{
              unicodeList.add(0x27);
            }
            break;
          case 0x3F:
            // \?
            if(isByteList){
              byteList.add(0x3F);
            }else{
              unicodeList.add(0x3F);
            }
            break;
          case 0:
            // \0
            if(isByteList){
              byteList.add(0);
            }else{
              unicodeList.add(0);
            }
            break;
        }
      }
    }
    _offset = _strIndex;
    throw FormatException("解析字符串数据异常，位置$_offset");
  }

  void _parseObjValue(DxValue parent, String key){
    _skipWhiteSpace();
    int charCode = _dataList[_offset];
    switch(charCode){
      case 0x22:
        //字符串
        String value = _readString();
        parent.setKeyString(key, value);
        break;
      case 0x5B:
      //[ 数组开始
      //] 0x5D
        break;
      case 0x7B:
        //{对象  ,} 0x7D
        break;
      default:
        //数字或者bool类型
        if(charCode >= 0x30 && charCode <= 0x39 || charCode == 0x2E){
          int dotCount = 0;
          for (var i = _offset;i<_dataList.length;i++){
            if(_dataList[i] == 0x2E){
              dotCount++;
              if(dotCount > 1){
                throw FormatException("无效的Json格式，数字类型无效$_offset");
              }
              continue;
            }
            if((_dataList[i] < 0x30 || _dataList[i] > 0x39)){
              if(_dataList[i] == 0x20 || _dataList[i] == 0x2C || _dataList[i] == 0x5D || _dataList[i] == 0x7D){
                //OK的
                String numValue = String.fromCharCodes(_dataList.sublist(_offset,i));
                if(dotCount > 0){
                  parent.setKeyDouble(key, double.tryParse(numValue));
                }else{
                  parent.setKeyInt(key, int.tryParse(numValue));
                }
                _offset = i;
                return;
              }
              throw FormatException("无效的Json格式，数字类型无效$_offset");
            }
          }
          throw FormatException("无效的Json格式，数字类型无效$_offset");
        }else if (charCode == 0x74){
          //true
          if (_offset+4>=_dataList.length){
            throw FormatException("无效的Json格式$_offset");
          }
          if(_dataList[_offset] == 0x74 && _dataList[_offset+1] == 0x72 && _dataList[_offset+2] == 0x75 && _dataList[_offset+3] == 0x65){
             //true,判定下一位是否是有效的
            if(_dataList[_offset+4] == 0x20 || _dataList[_offset+4] == 0x2C || _dataList[_offset+4] == 0x5D || _dataList[_offset+4] == 0x7D){
              parent.setKeyBool(key, true);
              _offset += 4;
              break;
            }
            throw FormatException("无效的Json格式${_offset+3}");
          }
        }else if(charCode == 0x66){
          //false
          if (_offset+5>=_dataList.length){
            throw FormatException("无效的Json格式$_offset");
          }
          if(_dataList[_offset] == 0x66 && _dataList[_offset+1] == 0x61 && _dataList[_offset+2] == 0x6c && _dataList[_offset+3] == 0x73 && _dataList[_offset+4] == 0x65){
            //false,判定下一位是否是有效的
            if(_dataList[_offset+5] == 0x20 || _dataList[_offset+5] == 0x2C || _dataList[_offset+5] == 0x5D || _dataList[_offset+5] == 0x7D){
              parent.setKeyBool(key, false);
              _offset += 5;
              break;
            }
            throw FormatException("无效的Json格式${_offset+3}");
          }
        }
    }
  }


  void parseObject(DxValue value){
    value.clear();
    int maxLen = _dataList.length;
    bool isFirst = true;
    while(_offset < maxLen){
      _skipWhiteSpace();
      int charCode = _dataList[_offset];
      if(charCode == 0x7D){
        //对象解析完毕
        _offset++;
        return;
      }else if (charCode == 0x2C){
        //没有发现,，没有其他值
        if(isFirst){
          throw FormatException("无效的Json格式$_offset,未发现分隔符,");
        }
        _offset++;
      }else if(!isFirst){
        throw FormatException("无效的Json格式$_offset,未发现分隔符,");
      }else{
        isFirst = false;
      }
      String key = _readString();
      //查找到:
      _skipWhiteSpace();
      charCode = _dataList[_offset];
      if(charCode != 0x3A){
        throw FormatException("无效的Json格式$_offset，未发现键值分隔符:");
      }
      _offset++;
      _parseObjValue(value, key);
    }
  }

  void parseArray(DxValue value){

  }
}