/// The order types offered by the web filter, in the same order.
///
/// [value] is what gets sent to `/mt5-data/list` inside `where.type`, [label]
/// is what the user sees. Matching against the api response is done on
/// [normalizeKey], so `buyLimit`, `buy_limit` and `Buy Limit` all match.
class Mt5OrderType {
  final String value;
  final String label;

  const Mt5OrderType(this.value, this.label);

  static const List<Mt5OrderType> all = [
    Mt5OrderType('buy', 'Buy'),
    Mt5OrderType('sell', 'Sell'),
    Mt5OrderType('buyLimit', 'Buy Limit'),
    Mt5OrderType('sellLimit', 'Sell Limit'),
    Mt5OrderType('buyStop', 'Buy Stop'),
    Mt5OrderType('sellStop', 'Sell Stop'),
    Mt5OrderType('buyStopLimit', 'Buy Stop Limit'),
    Mt5OrderType('sellStopLimit', 'Sell Stop Limit'),
    Mt5OrderType('balance', 'Balance'),
    Mt5OrderType('bonus', 'Bonus'),
  ];

  static String normalizeKey(String value) =>
      value.toLowerCase().replaceAll(RegExp('[^a-z0-9]'), '');

  static String labelOf(String? value) {
    if (value == null) return '';
    for (final type in all) {
      if (normalizeKey(type.value) == normalizeKey(value)) return type.label;
    }
    return value;
  }
}
