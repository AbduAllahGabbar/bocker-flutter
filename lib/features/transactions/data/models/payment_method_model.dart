class PaymentMethodModel {
  final String code;
  final String name;
  final List<Map<String, dynamic>> list;

  PaymentMethodModel({
    required this.code,
    required this.name,
    this.list = const [],
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> parsedList = [];
    if (json['list'] != null && json['list'] is List) {
      parsedList = List<Map<String, dynamic>>.from(
          (json['list'] as List).map((e) => Map<String, dynamic>.from(e as Map)));
    }

    return PaymentMethodModel(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      list: parsedList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'list': list,
    };
  }
}
