import 'package:bech32/bech32.dart';

void main() {
  Segwit address = segwit.decode(
      "bc1pw508d6qejxtdg4y5r3zarvary0c5xw7kw508d6qejxtdg4y5r3zarvary0c5xw7k7grplx");
  print("scriptPubKey: ${address.scriptPubKey}");
  print("version: ${address.version}");
  print("program: ${address.program}");

  Segwit otherAddress = Segwit('bc', 1, [0, 0]);
  print(segwit.encode(otherAddress));
}
