/// String capitalization helper methods.
extension CapitalizeX on String {
  /// Returns a copy of this string with its first character capitalized.
  String capitalizeFirst() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
