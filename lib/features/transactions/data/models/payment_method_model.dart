class PaymentMethodModel {
  final String code;
  final String name;
  final List<Map<String, dynamic>> list;

  /// Whether the broker has this method switched on. A method the backend
  /// does not mark either way is treated as enabled, so nothing disappears
  /// because a field is missing.
  final bool active;

  PaymentMethodModel({
    required this.code,
    required this.name,
    this.list = const [],
    this.active = true,
  });

  /// `code` without separators or case, so `my-fatoorah`, `MyFatoorah` and
  /// `myfatoorah` all compare equal.
  String get normalizedCode =>
      code.toLowerCase().replaceAll(RegExp('[^a-z0-9]'), '');

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> parsedList = [];
    if (json['list'] != null && json['list'] is List) {
      parsedList = List<Map<String, dynamic>>.from(
        (json['list'] as List).map((e) => Map<String, dynamic>.from(e as Map)),
      );
    }

    return PaymentMethodModel(
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      list: parsedList,
      active: json['active'] is bool ? json['active'] as bool : true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'code': code, 'name': name, 'list': list, 'active': active};
  }
}
