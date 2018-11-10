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

    var hrp = input.substring(0, separatorPosition);

    if (_isTooShort(hrp)) {
      throw TooShortHpr();
    }

    if (_hasOutOfRangeHrpCharacters(hrp)) {
      throw OutOfRangeHprCharacters(hrp);
    }

    List<int> data = input.substring(separatorPosition + 1).split('').map((c) {
      return charset.indexOf(c);
    }).toList();

    if (_hasOutOfBoundsChars(data)) {
      throw OutOfBoundChars(input[separatorPosition + 1 + data.indexOf(-1)]);
    }

    if (_isInvalidChecksum(hrp, data)) {
      throw InvalidChecksum();
    }

    return Bech32(hrp, data);
  }

  bool _hasOutOfBoundsChars(List<int> data) {
    return data.any((c) => c == -1);
  }

  bool _isTooShort(String hrp) {
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
    if (pos == -1 || pos + 7 > bech32.length) {
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
//  if (hrp.lenght + data.lenght + 7 > 90) {
//    throw TooLong(hrp.lenght + data.lenght + 7);
//  }
//
//  if (hrp.lenght < 1) {
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
//	var data = bech32String[separatorPosition+1:bech32String.lenght-1].map((c) {
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
