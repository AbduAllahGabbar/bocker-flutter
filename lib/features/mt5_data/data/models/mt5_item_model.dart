class Mt5ItemModel {
  final String? id;
  final String? source;
  final String? eventType;
  final DateTime? time;
  final String? login;
  final String? ticket;
  final String? symbol;
  final String? action;
  final String? entryLabel;
  final num? lots;
  final num? amount;
  final num? credit;
  final num? profit;
  final num? commission;
  final num? swap;
  final String? comment;
  final Mt5Transaction? transaction;
  final Mt5BonusTransaction? bonusTransaction;
  final String? type;
  final num? volume;
  final num? openPrice;
  final num? priceOpen;
  final num? closePrice;
  final num? priceClose;
  final num? sl;
  final num? tp;
  final DateTime? openTime;
  final DateTime? closeTime;

  const Mt5ItemModel({
    this.id,
    this.source,
    this.eventType,
    this.time,
    this.login,
    this.ticket,
    this.symbol,
    this.action,
    this.entryLabel,
    this.lots,
    this.amount,
    this.credit,
    this.profit,
    this.commission,
    this.swap,
    this.comment,
    this.transaction,
    this.bonusTransaction,
    this.type,
    this.volume,
    this.openPrice,
    this.priceOpen,
    this.closePrice,
    this.priceClose,
    this.sl,
    this.tp,
    this.openTime,
    this.closeTime,
  });

  factory Mt5ItemModel.fromJson(Map<String, dynamic> json) {
    return Mt5ItemModel(
      id: _parseString(json['id']),
      source: _parseString(json['source']),
      eventType: _parseString(json['eventType']),
      time: _parseDate(json['time']),
      login: _parseString(json['login']),
      ticket: _parseString(json['ticket']),
      symbol: _parseString(json['symbol']),
      action: _parseString(json['action']),
      entryLabel: _parseString(json['entryLabel']),
      lots: _parseNum(json['lots']),
      amount: _parseNum(json['amount']),
      credit: _parseNum(json['credit']),
      profit: _parseNum(json['profit']),
      commission: _parseNum(json['commission']),
      swap: _parseNum(json['swap']),
      comment: _parseString(json['comment']),
      transaction: json['transaction'] != null
          ? Mt5Transaction.fromJson(json['transaction'] as Map<String, dynamic>)
          : null,
      bonusTransaction: json['bonusTransaction'] != null
          ? Mt5BonusTransaction.fromJson(json['bonusTransaction'] as Map<String, dynamic>)
          : null,
      type: _parseString(json['type']),
      volume: _parseNum(json['volume']),
      openPrice: _parseNum(json['openPrice']),
      priceOpen: _parseNum(json['priceOpen']),
      closePrice: _parseNum(json['closePrice']),
      priceClose: _parseNum(json['priceClose']),
      sl: _parseNum(json['sl']),
      tp: _parseNum(json['tp']),
      openTime: _parseDate(json['openTime']),
      closeTime: _parseDate(json['closeTime']),
    );
  }

  String get displayTicket => ticket ?? id ?? '';
  String get displaySymbol => symbol ?? '';
  num get displayVolume => volume ?? lots ?? 0.0;
  num get displayProfit => profit ?? amount ?? 0.0;
  String get displayType => type ?? action ?? eventType ?? '';
  num get displayOpenPrice => openPrice ?? priceOpen ?? 0.0;
  num get displayClosePrice => closePrice ?? priceClose ?? 0.0;
  num get displaySl => sl ?? 0.0;
  num get displayTp => tp ?? 0.0;
  num get displayCommission => commission ?? 0.0;
  num get displaySwap => swap ?? 0.0;
  num get displayBonus => bonusTransaction?.amount ?? (entryLabel == 'bonus' ? amount ?? 0.0 : 0.0);
  String get displayOpenTime => openTime?.toIso8601String() ?? time?.toIso8601String() ?? '-';
  String get displayCloseTime => closeTime?.toIso8601String() ?? '-';
}

class Mt5Transaction {
  final String? sId;
  final String? code;
  final String? type;
  final num? amount;
  final Mt5Account? account;
  final Mt5Account? accountTo;
  final Mt5PaymentMethod? paymentMethod;
  final Map<String, dynamic>? paymentMethodDetails;
  final String? comment;
  final Mt5TransactionStatus? transactionStatus;
  final Mt5User? user;
  final Map<String, dynamic>? addUserInfo;
  final Map<String, dynamic>? editUserInfo;
  final bool? createdByAdmin;
  final String? onBehalfOfUserId;
  final Map<String, dynamic>? mt5;
  final String? mt5DealTicket;
  final String? mt5PlatformSyncedAt;
  final Map<String, dynamic>? paymentQuote;
  final Map<String, dynamic>? paymentGateway;
  final String? id;

  const Mt5Transaction({
    this.sId,
    this.code,
    this.type,
    this.amount,
    this.account,
    this.accountTo,
    this.paymentMethod,
    this.paymentMethodDetails,
    this.comment,
    this.transactionStatus,
    this.user,
    this.addUserInfo,
    this.editUserInfo,
    this.createdByAdmin,
    this.onBehalfOfUserId,
    this.mt5,
    this.mt5DealTicket,
    this.mt5PlatformSyncedAt,
    this.paymentQuote,
    this.paymentGateway,
    this.id,
  });

  factory Mt5Transaction.fromJson(Map<String, dynamic> json) {
    return Mt5Transaction(
      sId: _parseString(json['_id']),
      code: _parseString(json['code']),
      type: _parseString(json['type']),
      amount: _parseNum(json['amount']),
      account: json['account'] != null ? Mt5Account.fromJson(json['account']) : null,
      accountTo: json['accountTo'] != null ? Mt5Account.fromJson(json['accountTo']) : null,
      paymentMethod: json['paymentMethod'] != null ? Mt5PaymentMethod.fromJson(json['paymentMethod']) : null,
      paymentMethodDetails: json['paymentMethodDetails'] as Map<String, dynamic>?,
      comment: _parseString(json['comment']),
      transactionStatus: json['transactionStatus'] != null ? Mt5TransactionStatus.fromJson(json['transactionStatus']) : null,
      user: json['user'] != null ? Mt5User.fromJson(json['user']) : null,
      addUserInfo: json['addUserInfo'] as Map<String, dynamic>?,
      editUserInfo: json['editUserInfo'] as Map<String, dynamic>?,
      createdByAdmin: json['createdByAdmin'] as bool?,
      onBehalfOfUserId: _parseString(json['onBehalfOfUserId']),
      mt5: json['mt5'] as Map<String, dynamic>?,
      mt5DealTicket: _parseString(json['mt5DealTicket']),
      mt5PlatformSyncedAt: _parseString(json['mt5PlatformSyncedAt']),
      paymentQuote: json['paymentQuote'] as Map<String, dynamic>?,
      paymentGateway: json['paymentGateway'] as Map<String, dynamic>?,
      id: _parseString(json['id']),
    );
  }
}

class Mt5BonusTransaction {
  final String? sId;
  final DateTime? date;
  final String? mode;
  final String? operation;
  final String? status;
  final String? source;
  final String? operationKey;
  final num? accountId;
  final String? accountCode;
  final String? login;
  final num? userId;
  final Mt5User? user;
  final num? amount;
  final num? delta;
  final num? bonusBefore;
  final num? balanceBefore;
  final bool? expiryEnabled;
  final DateTime? expiryDate;
  final String? expiryStatus;
  final String? message;
  final String? comment;
  final bool? automatic;
  final String? automationId;
  final String? depositTransactionId;
  final String? depositCode;
  final String? parentBonusTransactionId;
  final Map<String, dynamic>? addUserInfo;
  final String? id;
  final num? balanceAfter;
  final num? bonusAfter;
  final String? mt5Ticket;

  const Mt5BonusTransaction({
    this.sId,
    this.date,
    this.mode,
    this.operation,
    this.status,
    this.source,
    this.operationKey,
    this.accountId,
    this.accountCode,
    this.login,
    this.userId,
    this.user,
    this.amount,
    this.delta,
    this.bonusBefore,
    this.balanceBefore,
    this.expiryEnabled,
    this.expiryDate,
    this.expiryStatus,
    this.message,
    this.comment,
    this.automatic,
    this.automationId,
    this.depositTransactionId,
    this.depositCode,
    this.parentBonusTransactionId,
    this.addUserInfo,
    this.id,
    this.balanceAfter,
    this.bonusAfter,
    this.mt5Ticket,
  });

  factory Mt5BonusTransaction.fromJson(Map<String, dynamic> json) {
    return Mt5BonusTransaction(
      sId: _parseString(json['_id']),
      date: _parseDate(json['date']),
      mode: _parseString(json['mode']),
      operation: _parseString(json['operation']),
      status: _parseString(json['status']),
      source: _parseString(json['source']),
      operationKey: _parseString(json['operationKey']),
      accountId: _parseNum(json['accountId']),
      accountCode: _parseString(json['accountCode']),
      login: _parseString(json['login']),
      userId: _parseNum(json['userId']),
      user: json['user'] != null ? Mt5User.fromJson(json['user']) : null,
      amount: _parseNum(json['amount']),
      delta: _parseNum(json['delta']),
      bonusBefore: _parseNum(json['bonusBefore']),
      balanceBefore: _parseNum(json['balanceBefore']),
      expiryEnabled: json['expiryEnabled'] as bool?,
      expiryDate: _parseDate(json['expiryDate']),
      expiryStatus: _parseString(json['expiryStatus']),
      message: _parseString(json['message']),
      comment: _parseString(json['comment']),
      automatic: json['automatic'] as bool?,
      automationId: _parseString(json['automationId']),
      depositTransactionId: _parseString(json['depositTransactionId']),
      depositCode: _parseString(json['depositCode']),
      parentBonusTransactionId: _parseString(json['parentBonusTransactionId']),
      addUserInfo: json['addUserInfo'] as Map<String, dynamic>?,
      id: _parseString(json['id']),
      balanceAfter: _parseNum(json['balanceAfter']),
      bonusAfter: _parseNum(json['bonusAfter']),
      mt5Ticket: _parseString(json['mt5Ticket']),
    );
  }
}

class Mt5Account {
  final String? sId;
  final num? id;

  const Mt5Account({this.sId, this.id});

  factory Mt5Account.fromJson(dynamic json) {
    if (json is String) return Mt5Account(sId: json);
    if (json is Map<String, dynamic>) {
      return Mt5Account(sId: _parseString(json['_id']), id: _parseNum(json['id']));
    }
    return const Mt5Account();
  }
}

class Mt5User {
  final String? sId;
  final num? id;

  const Mt5User({this.sId, this.id});

  factory Mt5User.fromJson(dynamic json) {
    if (json is String) return Mt5User(sId: json);
    if (json is Map<String, dynamic>) {
      return Mt5User(sId: _parseString(json['_id']), id: _parseNum(json['id']));
    }
    return const Mt5User();
  }
}

class Mt5PaymentMethod {
  final String? code;
  final String? name;

  const Mt5PaymentMethod({this.code, this.name});

  factory Mt5PaymentMethod.fromJson(dynamic json) {
    if (json is String) return Mt5PaymentMethod(code: json);
    if (json is Map<String, dynamic>) {
      return Mt5PaymentMethod(code: _parseString(json['code']), name: _parseString(json['name']));
    }
    return const Mt5PaymentMethod();
  }
}

class Mt5TransactionStatus {
  final String? code;
  final String? name;

  const Mt5TransactionStatus({this.code, this.name});

  factory Mt5TransactionStatus.fromJson(dynamic json) {
    if (json is String) return Mt5TransactionStatus(code: json);
    if (json is Map<String, dynamic>) {
      return Mt5TransactionStatus(code: _parseString(json['code']), name: _parseString(json['name']));
    }
    return const Mt5TransactionStatus();
  }
}

String? _parseString(dynamic value) {
  if (value == null) return null;
  return value.toString();
}

num? _parseNum(dynamic value) {
  if (value is num) return value;
  if (value is String) return num.tryParse(value);
  return null;
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is String) return DateTime.tryParse(value);
  return null;
}
