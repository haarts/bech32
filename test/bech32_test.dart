import "package:test/test.dart";

import "package:bech32/bech32.dart";
import "package:bech32/exceptions.dart";

void main() {
  group("bech32", () {
    group("valid test vectors from specification", () {
      List<String> valid = [
        "A12UEL5L",
        "a12uel5l",
        "an83characterlonghumanreadablepartthatcontainsthenumber1andtheexcludedcharactersbio1tt5tgs",
        "abcdef1qpzry9x8gf2tvdw0s3jn54khce6mua7lmqqqxw",
        "11qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqc8247j",
        "split1checkupstagehandshakeupstreamerranterredcaperred2y9e3w",
        "?1ezyfcl",
      ];

      valid.forEach((vec) {
        test("static vector: $vec", () {
          expect(bech32.decode(vec), isNotNull);
        });
      });
    });

    group("invalid test vectors from specification", () {
      test("hrp character out of range (space char)", () {
        expect(() => bech32.decode("\x20" + "1nwldj5"),
            throwsA(TypeMatcher<OutOfRangeHprCharacters>()));
      });

      test("hrp character out of range (delete char)", () {
        expect(() => bech32.decode("\x7F" + "1axkwrx"),
            throwsA(TypeMatcher<OutOfRangeHprCharacters>()));
      });

      test("hrp character out of range (control char)", () {
        expect(() => bech32.decode("\x80" + "1eym55h"),
            throwsA(TypeMatcher<OutOfRangeHprCharacters>()));
      });

      test("too long overall", () {
        expect(
            () => bech32.decode(
                "an84characterslonghumanreadablepartthatcontainsthenumber1andtheexcludedcharactersbio1569pvx"),
            throwsA(TypeMatcher<TooLong>()));
      });

      test("no separator", () {
        expect(() => bech32.decode("pzry9x0s0muk"),
            throwsA(TypeMatcher<InvalidSeparator>()));
      });

      test("empty hpr", () {
        expect(() => bech32.decode("1pzry9x0s0muk"),
            throwsA(TypeMatcher<TooShortHpr>()));
      });

      test("invalid data character", () {
        expect(() => bech32.decode("x1b4n0q5v"),
            throwsA(TypeMatcher<OutOfBoundChars>()));
      });

      test("too short checksum", () {
        expect(() => bech32.decode("li1dgmt3"),
            throwsA(TypeMatcher<InvalidChecksum>()));
      });

      test("invalid checksum character", () {
        expect(() => bech32.decode("de1lg7wt" + "\xFF"),
            throwsA(TypeMatcher<InvalidChecksum>()));
      });

      test("checksum calculated from upper case hpr", () {
        expect(() => bech32.decode("A1G7SGD8"),
            throwsA(TypeMatcher<InvalidChecksum>()));
      });

      test("empty hpr", () {
        expect(() => bech32.decode("10a06t8"),
            throwsA(TypeMatcher<TooShortHpr>()));
      });

      test("empty hpr", () {
        expect(() => bech32.decode("1qzzfhee"),
            throwsA(TypeMatcher<TooShortHpr>()));
      });
    });

    group("lower/upper case handling", () {
      test("throw exception on mixed case", () {});
      test("output lower case only", () {});
    });
  });

  group("segwit", () {});
}
