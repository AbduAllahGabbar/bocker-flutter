class PaymentMethodModel {
  final String code;
  final String name;

  PaymentMethodModel({
    required this.code,
    required this.name,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
    };
  }
}
