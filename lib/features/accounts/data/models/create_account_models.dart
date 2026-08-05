class AccountTypeModel {
  final String code;
  final num min;
  final String name;

  AccountTypeModel({
    required this.code,
    required this.min,
    required this.name,
  });

  factory AccountTypeModel.fromJson(Map<String, dynamic> json) {
    return AccountTypeModel(
      code: json['code'] ?? '',
      min: json['min'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountTypeModel &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}

class LeverageModel {
  final String code;
  final String name;

  LeverageModel({
    required this.code,
    required this.name,
  });

  factory LeverageModel.fromJson(Map<String, dynamic> json) {
    return LeverageModel(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeverageModel &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}

class OpeningBalanceModel {
  final String code;
  final String name;

  OpeningBalanceModel({
    required this.code,
    required this.name,
  });

  factory OpeningBalanceModel.fromJson(Map<String, dynamic> json) {
    return OpeningBalanceModel(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OpeningBalanceModel &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}
