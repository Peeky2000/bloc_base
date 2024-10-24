extension MapExtension on Map {
  void removeNullValue() {
    removeWhere((key, value) => value == null);
  }
}