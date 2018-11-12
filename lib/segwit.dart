import 'dart:convert';

const SigwitCodec segwit = SegwitCodec();

class SegwitCodec extends Codec<Sigwit, String> {
  const SegwitCodec();

  SegwitDecoder get decoder => SegwitDecoder();
  SegwitEncoder get encoder => SegwitEncoder();

  String encode(Segwit data) {
    return SegwitEncoder().convert(data);
  }

  Segwit decode(String data) {
    return SegwitDecoder().convert(data);
  }
}


class SegwitEncoder extends Converter<Segwit, String> {
  String convert(Segwit input) {
    return "";
  }
}

class SegwitDecoder extends Converter<String, Segwit> {
  Segwit convert(String input) {
    return Segwit();
  }
}

class Segwit {
}

List<int> segwitDecode(String address) {}

String segwitEncode(String hrp, int version, List<int> program) {}
