import 'dart:convert';

import 'package:bech32/bech32.dart';
import 'package:bech32/exceptions.dart';

const SegwitCodec segwit = SegwitCodec();

class SegwitCodec extends Codec<String, String> {
  const SegwitCodec();

  SegwitDecoder get decoder => SegwitDecoder();
  SegwitEncoder get encoder => SegwitEncoder();

  String encode(String data) {
    return SegwitEncoder().convert(data);
  }

  String decode(String data) {
    return SegwitDecoder().convert(data);
  }
}

class SegwitEncoder extends Converter<String, String> {
  String convert(String input) {
    return "";
  }
}

class SegwitDecoder extends Converter<String, String> {
  String convert(String input) {
    Bech32 decoded = bech32.decode(input);

    if (decoded.hrp != 'bc' && decoded.hrp != 'tb') {
      throw InvalidHrp();
    }

    if (decoded.data.length == 0) {
      throw InvalidProgramLength("empty");
    }

    var version = decoded.data[0];

    if (version > 16) {
      throw InvalidWitnessVersion();
    }

    List<int> program = _convertBits(decoded.data.sublist(1), 5, 8, false);

    if (program.length < 2) {
      throw InvalidProgramLength("too short");
    }

    if (program.length > 40) {
      throw InvalidProgramLength("too long");
    }

    if(version == 0 && (program.length != 20 && program.length != 32)) {
      throw InvalidProgramLength("version $version invalid with length ${program.length}");
    }

    return "";
  }
}

List<int> _convertBits(List<int> data, int from, int to, bool pad) {
  var acc = 0;
  var bits = 0;
  List<int> result = [];
  var maxv = (1 << to) - 1;
  var maxAcc = (1 << (from + to - 1)) - 1;

  data.forEach((v) {
    if (v < 0 || (v >> from) != 0) {
      throw Exception();
    }
    acc = (acc << from) | v;
    bits += from;
    while (bits >= to) {
      bits -= to;
      result.add((acc >> bits) & maxv);
    }
  });

  if (pad) {
    if (bits > 0) {
      result.add((acc << (to - bits)) & maxv);
    }
  } else if (bits >= from) {
    throw InvalidPadding("illegal zero padding");
  } else if (((acc << (to - bits)) & maxv) != 0) {
    throw InvalidPadding("non zero");
  }

  return result;
}

List<int> segwitDecode(String address) {}

String segwitEncode(String hrp, int version, List<int> program) {}
