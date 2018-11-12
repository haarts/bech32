# Bech32

[![pub package](https://img.shields.io/pub/v/bech32.svg)](https://pub.dartlang.org/packages/bech32)

An implementation of the [BIP173 spec] for Segwit Bech32 address format.

## Examples

```dart
  Segwit address = segwit.decode("bc1pw508d6qejxtdg4y5r3zarvary0c5xw7kw508d6qejxtdg4y5r3zarvary0c5xw7k7grplx");
  print(address.scriptPubKey);
  // => 5128751e76e8199196d454941c45d1b3a323f1433bd6751e76e8199196d454941c45d1b3a323f1433bd6
  print(address.version);
  // => 1
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
