class TransactionModel {
  final String? id;
  final Account? account;
  final PaymentMethod? paymentMethod;
  final num? amount;
  final String? type;
  final String? date;
  final TransactionStatus? transactionStatus;
  final String? code;

  TransactionModel({
    this.id,
    this.account,
    this.paymentMethod,
    this.amount,
    this.type,
    this.date,
    this.transactionStatus,
    this.code,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['_id'] as String?,
      account: json['account'] != null
          ? Account.fromJson(json['account'] as Map<String, dynamic>)
          : null,
      paymentMethod: json['paymentMethod'] != null
          ? PaymentMethod.fromJson(
              json['paymentMethod'] as Map<String, dynamic>)
          : null,
      amount: json['amount'] as num?,
      type: json['type'] as String?,
      date: json['date'] as String?,
      transactionStatus: json['transactionStatus'] != null
          ? TransactionStatus.fromJson(
              json['transactionStatus'] as Map<String, dynamic>)
          : null,
      code: json['code'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'account': account?.toJson(),
      'paymentMethod': paymentMethod?.toJson(),
      'amount': amount,
      'type': type,
      'date': date,
      'transactionStatus': transactionStatus?.toJson(),
      'code': code,
    };
  }
}

class Account {
  final String? id;
  final num? accountId;

  Account({this.id, this.accountId});

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['_id'] as String?,
      accountId: json['id'] as num?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'id': accountId,
    };
  }
}

class PaymentMethod {
  final String? code;
  final String? name;

  PaymentMethod({this.code, this.name});

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      code: json['code'] as String?,
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
    };
  }
}

class TransactionStatus {
  final String? code;
  final String? name;

  TransactionStatus({this.code, this.name});

  factory TransactionStatus.fromJson(Map<String, dynamic> json) {
    return TransactionStatus(
      code: json['code'] as String?,
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
    };
  }
}
