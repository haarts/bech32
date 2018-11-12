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

    if(decoded.hrp != 'bc' || decoded.hrp != 'tb') {
      throw InvalidHrp();
    }

    return "";
  }
}

List<int> segwitDecode(String address) {}

String segwitEncode(String hrp, int version, List<int> program) {}
