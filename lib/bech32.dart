import 'dart:convert';

import 'package:bech32/exceptions.dart';

const Bech32Codec bech32 = Bech32Codec();

class Bech32Codec extends Codec<Bech32, String> {
  const Bech32Codec();

  Bech32Decoder get decoder => Bech32Decoder();
  Bech32Encoder get encoder => Bech32Encoder();

  String encode(Bech32 data) {
    return Bech32Encoder().convert(data);
  }

  Bech32 decode(String data) {
    return Bech32Decoder().convert(data);
  }
}

class Bech32Encoder extends Converter<Bech32, String> {
  String convert(Bech32 input) {
    return "";
  }
}

class Bech32Decoder extends Converter<String, Bech32> {
  static const int maxInputLength = 90;
  static const checksumLength = 6;

  Bech32 convert(String input) {
    if (input.length > maxInputLength) {
      throw TooLong(input.length);
    }

    if (_isMixedCase(input)) {
      throw MixedCase(input);
    }

    if (_hasInvalidSeparator(input)) {
      throw InvalidSeparator(input.lastIndexOf(separator));
    }

    input = input.toLowerCase();

    var separatorPosition = input.lastIndexOf(separator);

    if (_isChecksumTooShort(separatorPosition, input)) {
      throw InvalidChecksum();
    }

    var hrp = input.substring(0, separatorPosition);
    var data =
        input.substring(separatorPosition + 1, input.length - checksumLength);
    var checksum = input.substring(input.length - checksumLength);

    if (_isHrpTooShort(hrp)) {
      throw TooShortHrp();
    }

    if (_hasOutOfRangeHrpCharacters(hrp)) {
      throw OutOfRangeHrpCharacters(hrp);
    }

    List<int> dataBytes = data.split('').map((c) {
      return charset.indexOf(c);
    }).toList();

    if (_hasOutOfBoundsChars(dataBytes)) {
      throw OutOfBoundChars(data[dataBytes.indexOf(-1)]);
    }

    if (_isInvalidChecksum(hrp, dataBytes)) {
      throw InvalidChecksum();
    }

    return Bech32(hrp, dataBytes);
  }

  // From the entire input subtract the hrp length, the separator and the required checksum length
  bool _isChecksumTooShort(int separatorPosition, String input) {
    return (input.length - separatorPosition - 1 - checksumLength) < 0;
  }

  bool _hasOutOfBoundsChars(List<int> data) {
    return data.any((c) => c == -1);
  }

  bool _isHrpTooShort(String hrp) {
    return hrp.length < 1;
  }

  bool _isInvalidChecksum(String hrp, List<int> data) {
    return _verifyChecksum(hrp, data);
  }

  bool _isMixedCase(String input) {
    return input.toLowerCase() != input && input.toUpperCase() != input;
  }

  bool _hasInvalidSeparator(String bech32) {
    var pos = bech32.lastIndexOf(separator);
    // -1: not found
    // pos + 7 only found in checksum part
    if (pos == -1) {
      return true;
    }

    return false;
  }

  bool _hasOutOfRangeHrpCharacters(String hrp) {
    return hrp.codeUnits.any((c) => c < 33 || c > 126);
  }
}

class Bech32 {
  Bech32(this.hrp, this.data);

  final String hrp;
  final List<int> data;
}

const String separator = "1";

const List<String> charset = [
  "q",
  "p",
  "z",
  "r",
  "y",
  "9",
  "x",
  "8",
  "g",
  "f",
  "2",
  "t",
  "v",
  "d",
  "w",
  "0",
  "s",
  "3",
  "j",
  "n",
  "5",
  "4",
  "k",
  "h",
  "c",
  "e",
  "6",
  "m",
  "u",
  "a",
  "7",
  "l",
];

const List<int> generator = [
  0x3b6a57b2,
  0x26508e6d,
  0x1ea119fa,
  0x3d4233dd,
  0x2a1462b3,
];

int _polymod(List<int> values) {
  var chk = 1;
  values.forEach((int v) {
    var top = chk >> 25;
    chk = (chk & 0x1ffffff) << 5 ^ v;
    for (int i = 0; i < generator.length; i++) {
      if ((top >> i) & 1 == 1) {
        chk ^= generator[i];
      }
    }
  });

  return chk;
}

List<int> _hrpExpand(String hrp) {
  var result = hrp.codeUnits.map((c) => c >> 5).toList();
  result = result + [0];

  result = result + result.map((c) => c & 31).toList();

  return result;
}

bool _verifyChecksum(String hrp, List<int> data) {
  return _polymod(_hrpExpand(hrp) + data) == 1;
}

List<int> _createChecksum(String hrp, List<int> data) {
  var values = _hrpExpand(hrp) + data;
  var polymod = _polymod(values + [0, 0, 0, 0, 0]) ^ 1;

  return [];
}

//String encode(String hrp, List<int> data) {
//  if (hrp.length + data.length + 7 > 90) {
//    throw TooLong(hrp.length + data.length + 7);
//  }
//
//  if (hrp.length < 1) {
//    throw TooShortHpr();
//  }
//
//  if (_hasInValidHrpCharacters(hrp)) {
//    throw InvalidHprCharacters(hrp);
//  }
//
//  if (_isMixedCase(hrp)) {
//    throw MixedCase(hrp);
//  }
//
//	var lower = hrp == hrp.toLowerCase();
//  hrp = hrp.toLowerCase();
//
//  var checksummed = data + _createChecksum(hrp, data);
//
//  if (_hasOutOfBoundsChars(checksummed)) {
//    return OutofBoundChars(_firstOutOfBoundChar(checksummed));
//  }
//
//  var result = hrp + separator + checksummed.map((i) => charset[i]).join();
//  if (lower) {
//    return result;
//  }
//
//  return result.toUpperCase();
//}

//List<int> decode(String bech32String) {
//  if (bech32String.length > 90) {
//    throw TooLong(bech32String.length);
//  }
//
//  if(_isMixedCase(bech32String)) {
//    throw MixedCase(bech32String);
//  }
//
//	if(_hasInvalidSeparator(bech32String)) {
//  	throw InvalidSeparator(bech32String);
//	}
//
//	bech32String = bech32String.toLowerCase();
//
//	var separatorPosition = bech32String.indexOf(separator)
//
//	var hrp = bech32String[0:]
//
//  if (_hasInValidHrpCharacters(hrp)) {
//    throw InvalidHprCharacters(hrp);
//  }
//
//	var data = bech32String[separatorPosition+1:bech32String.length-1].map((c) {
//    charset.index(c);
//	});
//
//	if(_validChecksum(hrp, data)) {
//  	throw InvalidChecksum();
//	}
//
//	return SomeClass();
//}

List<int> segwitDecode(String address) {}

String segwitEncode(String hrp, int version, List<int> program) {}
