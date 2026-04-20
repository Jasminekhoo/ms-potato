class Currency {
  static String rm(num value) => 'RM ${value.toStringAsFixed(0)}';
}

String percent(num value) {
  final sign = value > 0 ? '+' : '';
  return '$sign${value.toStringAsFixed(1)}%';
}
