class AccountModel {
  /// Numeric backend identifier. Used in API payloads only — never shown to
  /// the user, who always sees [code].
  final String id;

  /// Mongo `_id`, required by several API payloads.
  final String mongoId;

  /// The human-facing account number. This is what the user sees everywhere.
  final String code;

  final String type;
  final num balance;
  final num equity;
  final num credit;
  final Map<String, dynamic>? accountType;
  final Map<String, dynamic>? leverage;

  /// Approval status, e.g. `{code: 'pending', name: 'Pending'}`.
  final Map<String, dynamic>? status;

  final Map<String, dynamic>? initialBalance;
  final bool active;
  final String date;

  /// Full document, so MT5 details the backend adds are never lost.
  final Map<String, dynamic> raw;

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
    this.raw = const {},
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id']?.toString() ?? '',
      mongoId: json['_id'] ?? '',
      code: json['code']?.toString() ?? '',
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
      raw: json,
    );
  }

  bool get isDemo => type == 'demo';

  /// Display label for the account number, e.g. `Account 100234`.
  /// Falls back to the numeric id only when the backend sent no code.
  String get displayNumber => code.isNotEmpty ? code : id;

  // --- Approval status ------------------------------------------------------

  String? get statusCode => status?['code']?.toString();

  String? get statusName => status?['name']?.toString();

  bool get isPending => statusCode?.toLowerCase() == 'pending';

  bool get isApproved {
    final code = statusCode?.toLowerCase();
    return code == 'approved' || code == 'active' || code == 'accepted';
  }

  bool get isRejected {
    final code = statusCode?.toLowerCase();
    return code == 'rejected' || code == 'declined';
  }

  /// The smallest deposit the broker accepts on this account, when the
  /// backend states one (`minimumDeposit`, or `min` on the account type).
  num? get minimumDeposit {
    final direct = raw['minimumDeposit'];
    if (direct is num) return direct;
    if (direct is String) {
      final parsed = num.tryParse(direct);
      if (parsed != null) return parsed;
    }
    final fromType = accountType?['min'] ?? accountType?['minimumDeposit'];
    if (fromType is num) return fromType;
    if (fromType is String) return num.tryParse(fromType);
    return null;
  }

  // --- MT5 details ----------------------------------------------------------
  //
  // The MT5 block is read defensively: the backend may return it either nested
  // under `mt5` or flattened on the account document. Only values that are
  // actually present are exposed, so the UI can hide what the backend did not
  // send instead of showing a placeholder.

  Map<String, dynamic> get _mt5 {
    final nested = raw['mt5'];
    if (nested is Map) return Map<String, dynamic>.from(nested);
    return raw;
  }

  /// The MT5 trading account login.
  String? get mt5Login =>
      _firstString(_mt5, const ['login', 'mt5Login', 'mt5_login', 'mtLogin']);

  /// The MT5 server the account lives on.
  String? get mt5Server => _firstString(_mt5, const [
    'server',
    'mt5Server',
    'mt5_server',
    'serverName',
  ]);

  /// The MT5 group assigned to the account.
  String? get mt5Group =>
      _firstString(_mt5, const ['group', 'mt5Group', 'mt5_group', 'groupName']);

  /// `true` when the backend returned any MT5 detail worth displaying.
  ///
  /// Note: trading passwords are intentionally **not** exposed by this model —
  /// they are never shown in the app and never logged.
  bool get hasMt5Details =>
      mt5Login != null || mt5Server != null || mt5Group != null;

  static String? _firstString(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      if (value == null) continue;
      if (value is Map) {
        final nested = value['name'] ?? value['code'] ?? value['login'];
        if (nested != null && nested.toString().trim().isNotEmpty) {
          return nested.toString().trim();
        }
        continue;
      }
      final text = value.toString().trim();
      if (text.isNotEmpty && text != 'null') return text;
    }
    return null;
  }
}
