
part of 'coder.dart';

extension intFormat on MsgPackParser {
  int parseU8(){
    int result = _byteData.getUint8(_offset);
    _offset++;
    return result;
  }

  int parseU16(){
    //int result = _dataList[_offset] << 8 | _dataList[_offset+1];
    int result = _byteData.getUint16(_offset);
    _offset += 2;
    return result;
  }

  int parseU32(){
    //int result = _dataList[_offset] << 24 | _dataList[_offset + 1] << 16 | _dataList[_offset + 2] << 8 | _dataList[_offset + 3];
    int result = _byteData.getUint32(_offset);
    _offset += 4;
    return result;
  }

  int parseU64(){
    /*int result = _dataList[_offset] << 56 | _dataList[_offset + 1] << 48 | _dataList[_offset + 2] << 40 | _dataList[_offset + 3] << 32 |
    _dataList[_offset + 4] << 24 | _dataList[_offset + 5] << 16 | _dataList[_offset + 6] << 8 | _dataList[_offset + 7];*/
    int result = _byteData.getUint64(_offset);
    _offset += 8;
    return result;
  }

  double parseFloat32(){
    double result = _byteData.getFloat32(_offset);
    _offset += 4;
    return result;
  }

  double parseFloat64(){
    double result = _byteData.getFloat64(_offset);
    _offset += 8;
    return result;
  }
}