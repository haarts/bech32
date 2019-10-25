# Bech32

[![pub package](https://img.shields.io/pub/v/bech32.svg)](https://pub.dartlang.org/packages/bech32)
[![CircleCI](https://circleci.com/gh/inapay/bech32.svg?style=svg)](https://circleci.com/gh/inapay/bech32)

An implementation of the [BIP173 spec] for Segwit Bech32 address format.

## Examples

```dart
  Segwit address = segwit.decode("bc1pw508d6qejxtdg4y5r3zarvary0c5xw7kw508d6qejxtdg4y5r3zarvary0c5xw7k7grplx");
  print(address.scriptPubKey);
  // => 5128751e76e8199196d454941c45d1b3a323f1433bd6751e76e8199196d454941c45d1b3a323f1433bd6
  print(address.version);
  // => 1
```

The lightning [BOLT #11 spec] can have longer inputs than the [BIP173 spec] allows. Use the positional maxLength parameter to override the validation.
```dart
  String paymentRequest = "lnbc1pvjluezpp5qqqsyqcyq5rqwzqfqqqsyqcyq5rqwzqfqqqsyqcyq5rqwzqfqypqdpl2pkx2ctnv5sxxmmwwd5kgetjypeh2ursdae8g6twvus8g6rfwvs8qun0dfjkxaq8rkx3yf5tcsyz3d73gafnh3cax9rn449d9p5uxz9ezhhypd0elx87sjle52x86fux2ypatgddc6k63n7erqz25le42c4u4ecky03ylcqca784w";
  Bech32Codec codec = Bech32Codec();
  Bech32 bech32 = codec.decode(
    paymentRequest,
    paymentRequest.length,
  );
  print("hrp: ${bech32.hrp}");
  // => hrp: lnbc
```

## Exceptions

The specification defines a myriad of cases in which decoding and encoding 
should fail. Please make sure your code catches all the relevant exception 
defined in `lib/exceptions.dart`.

## Installing

Add it to your `pubspec.yaml`:

```
dependencies:
  bech32: any
```

## Licence overview

All files in this repository fall under the license specified in 
[COPYING](COPYING). The project is licensed as [AGPL with a lesser clause](https://www.gnu.org/licenses/agpl-3.0.en.html). 
It may be used within a proprietary project, but the core library and any 
changes to it must be published online. Source code for this library must 
always remain free for everybody to access.

## Thanks

[BIP173 spec]: https://github.com/bitcoin/bips/blob/master/bip-0173.mediawiki
[BOLT #11 spec]: https://github.com/lightningnetwork/lightning-rfc/blob/master/11-payment-encoding.md