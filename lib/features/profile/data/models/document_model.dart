class VerificationDocumentModel {
  final IdentityDocumentModel identityForm;
  final AddressDocumentModel addressForm;

  VerificationDocumentModel({
    required this.identityForm,
    required this.addressForm,
  });

  factory VerificationDocumentModel.fromJson(Map<String, dynamic> json) {
    final doc = json['doc'] as Map<String, dynamic>? ?? {};
    final identityForm = doc['identityForm'] as Map<String, dynamic>? ?? {};
    final addressForm = doc['addressForm'] as Map<String, dynamic>? ?? {};
    
    return VerificationDocumentModel(
      identityForm: IdentityDocumentModel.fromJson(identityForm),
      addressForm: AddressDocumentModel.fromJson(addressForm),
    );
  }
}

class IdentityDocumentModel {
  final String docType;
  final String docNumber;
  final String country;
  final String status;
  final String? rejectionReason;
  final String lastUpdateDate;
  final Map<String, dynamic> originalJson;

  IdentityDocumentModel({
    required this.docType,
    required this.docNumber,
    required this.country,
    required this.status,
    this.rejectionReason,
    required this.lastUpdateDate,
    required this.originalJson,
  });

  factory IdentityDocumentModel.fromJson(Map<String, dynamic> json) {
    final docTypeRaw = json['docType'];
    return IdentityDocumentModel(
      docType: docTypeRaw == 'passport' ? 'Passport' : (docTypeRaw == 'national_id' ? 'National ID' : docTypeRaw?.toString() ?? 'N/A'),
      docNumber: json['docNumber']?.toString() ?? 'N/A',
      country: json['countryIssue']?['name']?.toString() ?? 'N/A',
      status: json['status']?.toString() ?? 'pending',
      rejectionReason: json['rejectionReason']?.toString(),
      lastUpdateDate: json['lastUpdateDate']?.toString().split('T').first ?? 'recently',
      originalJson: json,
    );
  }
}

class AddressDocumentModel {
  final String country;
  final String city;
  final String address;
  final String postalCode;
  final String status;
  final String? rejectionReason;
  final String lastUpdateDate;
  final Map<String, dynamic> originalJson;

  AddressDocumentModel({
    required this.country,
    required this.city,
    required this.address,
    required this.postalCode,
    required this.status,
    this.rejectionReason,
    required this.lastUpdateDate,
    required this.originalJson,
  });

  factory AddressDocumentModel.fromJson(Map<String, dynamic> json) {
    return AddressDocumentModel(
      country: json['country']?['name']?.toString() ?? 'N/A',
      city: json['city']?.toString() ?? 'N/A',
      address: json['address']?.toString() ?? 'N/A',
      postalCode: json['postalCode']?.toString() ?? 'N/A',
      status: json['status']?.toString() ?? 'pending',
      rejectionReason: json['rejectionReason']?.toString(),
      lastUpdateDate: json['lastUpdateDate']?.toString().split('T').first ?? 'recently',
      originalJson: json,
    );
  }
}
