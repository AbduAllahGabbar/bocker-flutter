import 'transaction_model.dart';

/// Payment quote returned by `POST /api/accountsTransactions/myfatoorah-quote`.
///
/// The backend is the single source of truth for fees — the app never computes
/// them. Only the values the backend actually returns are exposed; anything
/// missing stays `null` so the UI can hide it instead of showing a made-up
/// number.
class MyFatoorahQuoteModel {
  /// The amount that will be credited to the trading account.
  final num? amount;

  /// Processing fee charged on top of [amount].
  final num? fee;

  /// Amount the client is actually charged (`amount` + `fee`).
  final num? total;

  /// Currency code of the charge, when supplied.
  final String? currency;

  /// `percent` or `fixed`, when supplied.
  final String? feeType;

  /// The configured fee value behind [fee], when supplied.
  final num? feeValue;

  /// Full response, so nothing the backend sends is lost.
  final Map<String, dynamic> raw;

  const MyFatoorahQuoteModel({
    this.amount,
    this.fee,
    this.total,
    this.currency,
    this.feeType,
    this.feeValue,
    this.raw = const {},
  });

  factory MyFatoorahQuoteModel.fromJson(Map<String, dynamic> json) {
    // The quote may be returned at the root or nested under a wrapper key.
    final Map<String, dynamic> source = _unwrap(json);

    return MyFatoorahQuoteModel(
      amount: _num(source, const ['amount', 'baseAmount', 'netAmount']),
      fee: _num(source, const ['fee', 'fees', 'feeAmount', 'commission']),
      total: _num(source, const [
        'total',
        'totalAmount',
        'amountWithFee',
        'grossAmount',
        'chargeAmount',
      ]),
      currency: _string(source, const [
        'currency',
        'currencyCode',
        'currencyIso',
      ]),
      feeType: _string(source, const ['feeType', 'defaultFeeType']),
      feeValue: _num(source, const ['feeValue', 'defaultFeeValue']),
      raw: json,
    );
  }

  /// `true` when the backend returned at least one monetary value to display.
  bool get hasBreakdown => amount != null || fee != null || total != null;

  static Map<String, dynamic> _unwrap(Map<String, dynamic> json) {
    for (final key in const ['quote', 'doc', 'data', 'result']) {
      final nested = json[key];
      if (nested is Map) {
        return {...json, ...Map<String, dynamic>.from(nested)};
      }
    }
    return json;
  }

  static num? _num(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is num) return value;
      if (value is String) {
        final parsed = num.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  static String? _string(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
      if (value is Map) {
        final name = value['code'] ?? value['name'];
        if (name is String && name.trim().isNotEmpty) return name.trim();
      }
    }
    return null;
  }
}

/// Result of `POST /api/accountsTransactions/add`.
///
/// For gateway-backed deposits (MyFatoorah) the backend returns a redirect URL
/// for the hosted payment page. The URL key is read defensively because the
/// gateway payload is passed through from the provider.
class AddTransactionResult {
  /// The created transaction as returned by the backend (`doc`).
  final TransactionModel transaction;

  /// Full response body.
  final Map<String, dynamic> raw;

  /// Hosted payment page to open, when the backend returned one.
  final String? paymentUrl;

  const AddTransactionResult({
    required this.transaction,
    required this.raw,
    this.paymentUrl,
  });

  factory AddTransactionResult.fromJson(Map<String, dynamic> json) {
    final doc = json['doc'];
    return AddTransactionResult(
      transaction: TransactionModel.fromJson(
        doc is Map ? Map<String, dynamic>.from(doc) : const {},
      ),
      raw: json,
      paymentUrl: _findPaymentUrl(json),
    );
  }

  bool get requiresGatewayRedirect => paymentUrl != null;

  /// Compared case-insensitively: the gateway payload is passed through from
  /// the provider, which uses its own casing (e.g. MyFatoorah's `InvoiceURL`).
  static const _urlKeys = <String>[
    'paymenturl',
    'invoiceurl',
    'redirecturl',
    'url',
  ];

  static String? _findPaymentUrl(Object? node, [int depth = 0]) {
    if (depth > 4) return null;
    if (node is Map) {
      for (final entry in node.entries) {
        final key = entry.key.toString().toLowerCase();
        if (!_urlKeys.contains(key)) continue;
        final value = entry.value;
        if (value is String && _isHttpUrl(value)) return value;
      }
      for (final value in node.values) {
        final found = _findPaymentUrl(value, depth + 1);
        if (found != null) return found;
      }
    } else if (node is List) {
      for (final value in node) {
        final found = _findPaymentUrl(value, depth + 1);
        if (found != null) return found;
      }
    }
    return null;
  }

  static bool _isHttpUrl(String value) {
    final uri = Uri.tryParse(value.trim());
    return uri != null &&
        uri.hasScheme &&
        (uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.host.isNotEmpty;
  }
}
