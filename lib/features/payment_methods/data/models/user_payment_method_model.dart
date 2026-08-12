import '../../../transactions/data/models/payment_method_model.dart';

class CurrencyModel {
  final String id;
  final num numId;
  final String name;

  CurrencyModel({
    required this.id,
    required this.numId,
    required this.name,
  });

  factory CurrencyModel.fromJson(Map<String, dynamic> json) {
    return CurrencyModel(
      id: json['_id'] ?? '',
      numId: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class UserPaymentMethodModel {
  final PaymentMethodModel paymentMethod;
  final int code;
  
  // Bank fields
  final String? beneficiaryName;
  final String? accountNumber;
  final String? swiftCode;
  final CurrencyModel? currency;
  final String? notes;

  // Card fields
  final String? cardNumber;
  final String? cardholderName;
  final String? cardExpiryDate;
  final String? cvvCode;

  // Crypto fields
  final String? network;
  final String? walletAddress;

  UserPaymentMethodModel({
    required this.paymentMethod,
    required this.code,
    this.beneficiaryName,
    this.accountNumber,
    this.swiftCode,
    this.currency,
    this.notes,
    this.cardNumber,
    this.cardholderName,
    this.cardExpiryDate,
    this.cvvCode,
    this.network,
    this.walletAddress,
  });

  factory UserPaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return UserPaymentMethodModel(
      paymentMethod: PaymentMethodModel.fromJson(json['paymentMethod'] ?? {}),
      code: json['code'] ?? 0,
      beneficiaryName: json['beneficiaryName'],
      accountNumber: json['accountNumber'],
      swiftCode: json['swiftCode'],
      currency: json['currency'] != null ? CurrencyModel.fromJson(json['currency']) : null,
      notes: json['notes'],
      cardNumber: json['cardNumber'],
      cardholderName: json['cardholderName'],
      cardExpiryDate: json['cardExpiryDate'],
      cvvCode: json['cvvCode'],
      network: json['network'],
      walletAddress: json['walletAddress'],
    );
  }
}
