extension StringExtensions on String {
  bool get isNullOrEmpty => isEmpty;
  
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

extension ListExtensions<T> on List<T> {
  bool get isNullOrEmpty => isEmpty;
}
