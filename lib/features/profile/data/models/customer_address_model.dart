class CustomerAddressModel {
  final String id;
  final String? company;
  final String? customerId;
  final String firstName;
  final String lastName;
  final String address1;
  final String? address2;
  final String city;
  final String? province;
  final String? postalCode;
  final String countryCode;
  final String? phone;
  final Map<String, dynamic> metadata;
  final String? addressName;
  final bool isDefaultShipping;
  final bool isDefaultBilling;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CustomerAddressModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.address1,
    required this.city,
    required this.countryCode,
    this.company,
    this.customerId,
    this.address2,
    this.province,
    this.postalCode,
    this.phone,
    this.metadata = const <String, dynamic>{},
    this.addressName,
    this.isDefaultShipping = false,
    this.isDefaultBilling = false,
    this.createdAt,
    this.updatedAt,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory CustomerAddressModel.fromJson(Map<String, dynamic> json) {
    return CustomerAddressModel(
      id: (json['id'] ?? '').toString(),
      company: _asNullableString(json['company']),
      customerId: _asNullableString(json['customer_id']),
      firstName: (json['first_name'] ?? '').toString(),
      lastName: (json['last_name'] ?? '').toString(),
      address1: (json['address_1'] ?? '').toString(),
      address2: _asNullableString(json['address_2']),
      city: (json['city'] ?? '').toString(),
      province: _asNullableString(json['province']),
      postalCode: _asNullableString(json['postal_code']),
      countryCode: (json['country_code'] ?? '').toString(),
      phone: _asNullableString(json['phone']),
      metadata: _asMap(json['metadata']),
      addressName: _asNullableString(
        json['address_name'] ?? json['addressName'] ?? json['label'],
      ),
      isDefaultShipping: json['is_default_shipping'] == true,
      isDefaultBilling: json['is_default_billing'] == true,
      createdAt: _asDateTime(json['created_at']),
      updatedAt: _asDateTime(json['updated_at']),
    );
  }

  static DateTime? _asDateTime(Object? value) {
    if (value is! String || value.trim().isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }

  static String? _asNullableString(Object? value) {
    final parsed = value?.toString().trim();
    if (parsed == null || parsed.isEmpty) {
      return null;
    }
    return parsed;
  }

  static Map<String, dynamic> _asMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return <String, dynamic>{};
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company': company,
      'customer_id': customerId,
      'first_name': firstName,
      'last_name': lastName,
      'address_1': address1,
      'address_2': address2,
      'city': city,
      'province': province,
      'postal_code': postalCode,
      'country_code': countryCode,
      'phone': phone,
      'metadata': metadata,
      'address_name': addressName,
      'is_default_shipping': isDefaultShipping,
      'is_default_billing': isDefaultBilling,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
