class AccountModel {
  final String id;
  final String mongoId;
  final String code;
  final String type;
  final num balance;
  final num equity;
  final num credit;
  final Map<String, dynamic>? accountType;
  final Map<String, dynamic>? leverage;
  final Map<String, dynamic>? status;
  final Map<String, dynamic>? initialBalance;
  final bool active;
  final String date;

  AccountModel({
    required this.id,
    required this.mongoId,
    required this.code,
    required this.type,
    required this.balance,
    required this.equity,
    required this.credit,
    this.accountType,
    this.leverage,
    this.status,
    this.initialBalance,
    required this.active,
    required this.date,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id']?.toString() ?? '',
      mongoId: json['_id'] ?? '',
      code: json['code'] ?? '',
      type: json['type'] ?? 'real',
      balance: json['balance'] ?? 0,
      equity: json['equity'] ?? 0,
      credit: json['credit'] ?? 0,
      accountType: json['accountType'] as Map<String, dynamic>?,
      leverage: json['leverage'] as Map<String, dynamic>?,
      status: json['status'] as Map<String, dynamic>?,
      initialBalance: json['initialBalance'] as Map<String, dynamic>?,
      active: json['active'] ?? false,
      date: json['date'] ?? '',
    );
  }
}
