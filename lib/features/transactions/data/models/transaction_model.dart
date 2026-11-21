class TransactionModel {
  final String? id;
  final Account? account;

  /// Destination account of a transfer, when present.
  final Account? accountTo;
  final PaymentMethod? paymentMethod;
  final num? amount;
  final String? type;
  final String? date;
  final TransactionStatus? transactionStatus;
  final String? code;

  /// Payment-gateway block (MyFatoorah), when the deposit went through one.
  final PaymentGateway? paymentGateway;

  /// The quote the backend applied to this deposit, when it returned one.
  final Map<String, dynamic>? paymentQuote;

  /// Proof that the MT5 balance operation ran: the platform's own deal
  /// ticket and the moment it was synced.
  final String? mt5DealTicket;
  final String? mt5PlatformSyncedAt;

  TransactionModel({
    this.id,
    this.account,
    this.accountTo,
    this.paymentMethod,
    this.amount,
    this.type,
    this.date,
    this.transactionStatus,
    this.code,
    this.paymentGateway,
    this.paymentQuote,
    this.mt5DealTicket,
    this.mt5PlatformSyncedAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['_id'] as String?,
      account: json['account'] != null
          ? Account.fromJson(json['account'] as Map<String, dynamic>)
          : null,
      accountTo: json['accountTo'] != null
          ? Account.fromJson(json['accountTo'] as Map<String, dynamic>)
          : null,
      paymentMethod: json['paymentMethod'] != null
          ? PaymentMethod.fromJson(
              json['paymentMethod'] as Map<String, dynamic>,
            )
          : null,
      amount: json['amount'] as num?,
      type: json['type'] as String?,
      date: json['date'] as String?,
      transactionStatus: json['transactionStatus'] != null
          ? TransactionStatus.fromJson(
              json['transactionStatus'] as Map<String, dynamic>,
            )
          : null,
      code: json['code'] as String?,
      paymentGateway: PaymentGateway.fromJson(json['paymentGateway']),
      paymentQuote: json['paymentQuote'] is Map
          ? Map<String, dynamic>.from(json['paymentQuote'] as Map)
          : null,
      mt5DealTicket: _text(json['mt5DealTicket']),
      mt5PlatformSyncedAt: _text(json['mt5PlatformSyncedAt']),
    );
  }

  static String? _text(Object? value) {
    final text = value?.toString().trim();
    return (text == null || text.isEmpty || text == 'null') ? null : text;
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'account': account?.toJson(),
      'accountTo': accountTo?.toJson(),
      'paymentMethod': paymentMethod?.toJson(),
      'amount': amount,
      'type': type,
      'date': date,
      'transactionStatus': transactionStatus?.toJson(),
      'code': code,
      if (paymentGateway != null) 'paymentGateway': paymentGateway!.toJson(),
      if (paymentQuote != null) 'paymentQuote': paymentQuote,
      if (mt5DealTicket != null) 'mt5DealTicket': mt5DealTicket,
      if (mt5PlatformSyncedAt != null)
        'mt5PlatformSyncedAt': mt5PlatformSyncedAt,
    };
  }

  // --- Status ---------------------------------------------------------------

  /// CRM status: `pending`, `processing`, `approved`, `rejected`, `failed`.
  String? get statusCode => transactionStatus?.code?.trim().toLowerCase();

  /// Gateway status: `pending`, `processing`, `paid`, `failed`,
  /// `verification-failed`, `paid-mt5-failed`.
  String? get gatewayStatus => paymentGateway?.statusCode;

  bool get usedPaymentGateway => paymentGateway != null;

  /// The MT5 side actually ran: the platform returned a deal ticket, or the
  /// backend recorded the moment it synced.
  bool get isMt5Credited =>
      (mt5DealTicket != null && mt5DealTicket!.isNotEmpty) ||
      (mt5PlatformSyncedAt != null && mt5PlatformSyncedAt!.isNotEmpty);

  /// What the user is actually told.
  ///
  /// `paymentGateway.status == paid` is deliberately **not** success: the
  /// money is only in the trading account once the CRM has approved the
  /// transaction and the MT5 operation has not failed.
  TransactionOutcome get outcome {
    final crm = statusCode;
    final gateway = gatewayStatus;

    // The payment went through but the balance operation did not: this needs
    // support, and must never read as either success or plain failure.
    if (gateway == 'paid-mt5-failed') return TransactionOutcome.creditFailed;
    if (gateway == 'verification-failed') {
      return TransactionOutcome.verificationFailed;
    }

    if (crm == 'rejected') return TransactionOutcome.rejected;
    if (crm == 'failed' || gateway == 'failed') {
      return TransactionOutcome.failed;
    }

    if (crm == 'approved') {
      // Approved with the gateway reporting a failed credit is caught above,
      // so the money has reached the account.
      return TransactionOutcome.completed;
    }

    // Paid at the gateway, not yet approved by the CRM.
    if (gateway == 'paid') return TransactionOutcome.awaitingConfirmation;

    if (crm == 'processing' || gateway == 'processing') {
      return TransactionOutcome.processing;
    }

    return TransactionOutcome.pending;
  }
}

/// How a transaction stands, from the user's point of view.
enum TransactionOutcome {
  /// Created, nothing has happened yet.
  pending,

  /// The CRM or the gateway is working on it.
  processing,

  /// The gateway took the money; the CRM has not approved it yet.
  awaitingConfirmation,

  /// Approved by the CRM - the only state that counts as success.
  completed,

  /// Paid, but the MT5 balance operation failed: needs support.
  creditFailed,

  /// The gateway could not verify the payment.
  verificationFailed,

  rejected,
  failed,
}

/// The `paymentGateway` block the CRM stores on a gateway-backed transaction.
class PaymentGateway {
  final String? name;
  final String? status;
  final String? reference;
  final Map<String, dynamic> raw;

  const PaymentGateway({
    this.name,
    this.status,
    this.reference,
    this.raw = const {},
  });

  /// Accepts the block as an object or as a bare status string, since the
  /// shape is the gateway's own.
  static PaymentGateway? fromJson(Object? value) {
    if (value == null) return null;
    if (value is String) {
      final text = value.trim();
      return text.isEmpty ? null : PaymentGateway(status: text);
    }
    if (value is! Map) return null;

    final map = Map<String, dynamic>.from(value);
    return PaymentGateway(
      name: _string(map, const ['name', 'gateway', 'provider']),
      status: _string(map, const ['status', 'state', 'paymentStatus']),
      reference: _string(map, const [
        'reference',
        'invoiceId',
        'paymentId',
        'transactionId',
      ]),
      raw: map,
    );
  }

  /// Normalised for comparison: `Paid`, `PAID` and `paid` are one status.
  String? get statusCode => status?.trim().toLowerCase();

  Map<String, dynamic> toJson() => raw.isNotEmpty
      ? raw
      : {
          if (name != null) 'name': name,
          if (status != null) 'status': status,
          if (reference != null) 'reference': reference,
        };

  static String? _string(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
      if (value is Map) {
        final nested = value['code'] ?? value['name'];
        if (nested is String && nested.trim().isNotEmpty) return nested.trim();
      }
    }
    return null;
  }
}

class Account {
  /// Mongo `_id` - API payloads only.
  final String? id;

  /// Numeric backend id - API payloads only.
  final num? accountId;

  /// The user-facing account number, when the backend embeds it.
  final String? code;

  Account({this.id, this.accountId, this.code});

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['_id'] as String?,
      accountId: json['id'] as num?,
      code: json['code']?.toString(),
    );
  }

  /// What to show the user: always the account code when available.
  String get displayNumber {
    if (code != null && code!.trim().isNotEmpty) return code!.trim();
    return accountId?.toString() ?? '';
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'id': accountId, if (code != null) 'code': code};
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
    return {'code': code, 'name': name};
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
    return {'code': code, 'name': name};
  }
}
