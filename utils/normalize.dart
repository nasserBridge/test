Map<String, dynamic> normalizeMap(dynamic value) {
  if (value is Map) {
    return value.map((key, val) {
      return MapEntry(
        key.toString(),
        normalizeValue(val),
      );
    });
  }
  throw ArgumentError('Expected Map but got ${value.runtimeType}');
}

dynamic normalizeValue(
  dynamic value,
) {
  if (value is Map) {
    return normalizeMap(value);
  }
  if (value is List) {
    return value.map(normalizeValue).toList();
  }
  return value;
}
