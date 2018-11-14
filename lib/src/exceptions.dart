class TooShortHrp implements Exception {
  String toString() => "The human readable part should have non zero length.";
}

class TooLong implements Exception {
  TooLong(this.length);

  final int length;

  String toString() => "The bech32 string is too long: $length (>90)";
}

class OutOfRangeHrpCharacters implements Exception {
  OutOfRangeHrpCharacters(this.hpr);

  final String hpr;

  String toString() =>
      "The human readable part contains invalid characters: $hpr";
}

class MixedCase implements Exception {
  MixedCase(this.hpr);

  final String hpr;

  String toString() =>
      "The human readable part is mixed case, should either be all lower or all upper case: $hpr";
}

class OutOfBoundChars implements Exception {
  OutOfBoundChars(this.char);

  final String char;

  String toString() => "A character is undefined in bech32: $char";
}

class InvalidSeparator implements Exception {
  InvalidSeparator(this.pos);

  final int pos;

  String toString() => "separator '1' at invalid position: $pos";
}

class InvalidAddress implements Exception {
  String toString() => "";
}

class InvalidChecksum implements Exception {
  String toString() => "Checksum verification failed";
}

class TooShortChecksum implements Exception {
  String toString() => "Checksum is shorter than 6 characters";
}

class InvalidHrp implements Exception {
  String toString() => "Human readable part should be 'bc' or 'tb'.";
}

class InvalidProgramLength implements Exception {
  InvalidProgramLength(this.reason);

  final String reason;

  String toString() => "Program length is invalid: $reason";
}

class InvalidWitnessVersion implements Exception {
  InvalidWitnessVersion(this.version);

  final int version;

  String toString() => "Witness version $version > 16";
}

class InvalidPadding implements Exception {
  InvalidPadding(this.reason);

  final String reason;

  String toString() => "Invalid padding: $reason";
}
