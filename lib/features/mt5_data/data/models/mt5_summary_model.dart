class Mt5SummaryModel {
  final num balance;
  final num equity;
  final num margin;
  final num freeMargin;
  final num marginFree;
  final num marginLevel;
  final num profit;

  const Mt5SummaryModel({
    this.balance = 0.0,
    this.equity = 0.0,
    this.margin = 0.0,
    this.freeMargin = 0.0,
    this.marginFree = 0.0,
    this.marginLevel = 0.0,
    this.profit = 0.0,
  });

  factory Mt5SummaryModel.fromJson(Map<String, dynamic> json) {
    return Mt5SummaryModel(
      balance: _parseNum(json['balance']),
      equity: _parseNum(json['equity']),
      margin: _parseNum(json['margin']),
      freeMargin: _parseNum(json['freeMargin']),
      marginFree: _parseNum(json['marginFree']),
      marginLevel: _parseNum(json['marginLevel']),
      profit: _parseNum(json['profit']),
    );
  }

  static num _parseNum(dynamic value) {
    if (value is num) return value;
    if (value is String) return num.tryParse(value) ?? 0.0;
    return 0.0;
  }

  num get displayBalance => balance;
  num get displayEquity => equity;
  num get displayMargin => margin;
  num get displayFreeMargin => freeMargin != 0 ? freeMargin : marginFree;
  num get displayMarginLevel => marginLevel;
  num get displayProfit => profit;
}
