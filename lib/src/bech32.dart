import 'dart:convert';

import 'exceptions.dart';

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

class Bech32Encoder extends Converter<Bech32, String> with Bech32Validations {
  String convert(Bech32 input) {
    var hrp = input.hrp;
    var data = input.data;

    if (hrp.length +
            data.length +
            separator.length +
            Bech32Validations.checksumLength >
        Bech32Validations.maxInputLength) {
      throw TooLong(
          hrp.length + data.length + 1 + Bech32Validations.checksumLength);
    }

    if (hrp.length < 1) {
      throw TooShortHrp();
    }

    if (hasOutOfRangeHrpCharacters(hrp)) {
      throw OutOfRangeHrpCharacters(hrp);
    }

    if (isMixedCase(hrp)) {
      throw MixedCase(hrp);
    }

    hrp = hrp.toLowerCase();

    var checksummed = data + _createChecksum(hrp, data);

    if (hasOutOfBoundsChars(checksummed)) {
      // TODO this could be more informative
      throw OutOfBoundChars('<unknown>');
    }

    return hrp + separator + checksummed.map((i) => charset[i]).join();
  }
}

class Bech32Decoder extends Converter<String, Bech32> with Bech32Validations {
  Bech32 convert(String input) {
    if (input.length > Bech32Validations.maxInputLength) {
      throw TooLong(input.length);
    }

    if (isMixedCase(input)) {
      throw MixedCase(input);
    }

    if (hasInvalidSeparator(input)) {
      throw InvalidSeparator(input.lastIndexOf(separator));
    }

    var separatorPosition = input.lastIndexOf(separator);

    if (isChecksumTooShort(separatorPosition, input)) {
      throw TooShortChecksum();
    }

    if (isHrpTooShort(separatorPosition)) {
      throw TooShortHrp();
    }

    input = input.toLowerCase();

    var hrp = input.substring(0, separatorPosition);
    var data = input.substring(
        separatorPosition + 1, input.length - Bech32Validations.checksumLength);
    var checksum =
        input.substring(input.length - Bech32Validations.checksumLength);

    if (hasOutOfRangeHrpCharacters(hrp)) {
      throw OutOfRangeHrpCharacters(hrp);
    }

    List<int> dataBytes = data.split('').map((c) {
      return charset.indexOf(c);
    }).toList();

    if (hasOutOfBoundsChars(dataBytes)) {
      throw OutOfBoundChars(data[dataBytes.indexOf(-1)]);
    }

    List<int> checksumBytes = checksum.split('').map((c) {
      return charset.indexOf(c);
    }).toList();

    if (hasOutOfBoundsChars(checksumBytes)) {
      throw OutOfBoundChars(checksum[checksumBytes.indexOf(-1)]);
    }

    if (isInvalidChecksum(hrp, dataBytes, checksumBytes)) {
      throw InvalidChecksum();
    }

    return Bech32(hrp, dataBytes);
  }
}

class Bech32Validations {
  static const int maxInputLength = 90;
  static const checksumLength = 6;

  // From the entire input subtract the hrp length, the separator and the required checksum length
  bool isChecksumTooShort(int separatorPosition, String input) {
    return (input.length - separatorPosition - 1 - checksumLength) < 0;
  }

  bool hasOutOfBoundsChars(List<int> data) {
    return data.any((c) => c == -1);
  }

  bool isHrpTooShort(int separatorPosition) {
    return separatorPosition == 0;
  }

  bool isInvalidChecksum(String hrp, List<int> data, List<int> checksum) {
    return !_verifyChecksum(hrp, data + checksum);
  }

  bool isMixedCase(String input) {
    return input.toLowerCase() != input && input.toUpperCase() != input;
  }

  bool hasInvalidSeparator(String bech32) {
    return bech32.lastIndexOf(separator) == -1;
  }

  bool hasOutOfRangeHrpCharacters(String hrp) {
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

  result = result + hrp.codeUnits.map((c) => c & 31).toList();

  return result;
}

bool _verifyChecksum(String hrp, List<int> dataIncludingChecksum) {
  return _polymod(_hrpExpand(hrp) + dataIncludingChecksum) == 1;
}

List<int> _createChecksum(String hrp, List<int> data) {
  var values = _hrpExpand(hrp) + data + [0, 0, 0, 0, 0, 0];
  var polymod = _polymod(values) ^ 1;

  List<int> result = List<int>(6);

  for (int i = 0; i < result.length; i++) {
    result[i] = (polymod >> (5 * (5 - i))) & 31;
  }
  return result;
}
