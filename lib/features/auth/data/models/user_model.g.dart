// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
  sId: json['_id'] as String?,
  id: (json['id'] as num).toInt(),
  active: json['active'] as bool?,
  email: json['email'] as String,
  password: json['password'] as String?,
  image: json['image'] as String?,
  firstName: json['firstName'] as String?,
  lastName: json['lastName'] as String?,
  clientType: json['clientType'] as String?,
  idNumber: json['idNumber'] as String?,
  country: json['country'] as Map<String, dynamic>?,
  birthDate: json['birthDate'] as String?,
  isIb: json['isIb'] as bool?,
  promoCode: json['promoCode'] as String?,
  referralCampaignId: json['referralCampaignId'] as String?,
  isVerifyEmail: json['isVerifyEmail'] as bool?,
  isFormCompleted: json['isFormCompleted'] as bool?,
  mobile: json['mobile'] as String?,
  phonePrefix: json['phonePrefix'] as String?,
  type: json['type'] as String?,
  isLead: json['isLead'] as bool?,
  balance: json['balance'] as num?,
  mt5Group: json['mt5Group'] as Map<String, dynamic>?,
  ip: json['ip'] as String?,
  permissions: (json['permissions'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  registerDate: json['registerDate'] as String?,
  profile: json['profile'] as Map<String, dynamic>?,
  roles: json['roles'] as List<dynamic>?,
  addedUserInfo: json['added_user_info'] as Map<String, dynamic>?,
  identityForm: json['identityForm'] as Map<String, dynamic>?,
  addressForm: json['addressForm'] as Map<String, dynamic>?,
  ibWallet: json['ibWallet'] as Map<String, dynamic>?,
  campaignsGroupList: json['campaignsGroupList'] as List<dynamic>?,
  mt5ClientCreatedAt: json['mt5ClientCreatedAt'] as String?,
  mt5ClientError: json['mt5ClientError'] as String?,
  mt5ClientId: json['mt5ClientId'] as String?,
  mt5ClientStatus: json['mt5ClientStatus'] as String?,
  editUserInfo: json['editUserInfo'] as Map<String, dynamic>?,
  paymentMethodList: json['paymentMethodList'] as List<dynamic>?,
  phone: json['phone'] as String?,
  fullName: json['fullName'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
  hasAccount: json['hasAccount'] as bool?,
  addresses: (json['addresses'] as List<dynamic>?)
      ?.map((e) => e as Map<String, dynamic>)
      .toList(),
  emailVerified: json['emailVerified'] as bool? ?? false,
  role: json['role'] == null
      ? UserRole.student
      : UserRole.fromJson(json['role'] as String),
  status: json['status'] == null
      ? UserStatus.active
      : UserStatus.fromJson(json['status'] as String),
  deletedAt: json['deletedAt'] == null
      ? null
      : DateTime.parse(json['deletedAt'] as String),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      '_id': instance.sId,
      'id': instance.id,
      'active': instance.active,
      'email': instance.email,
      'password': instance.password,
      'image': instance.image,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'clientType': instance.clientType,
      'idNumber': instance.idNumber,
      'country': instance.country,
      'birthDate': instance.birthDate,
      'isIb': instance.isIb,
      'promoCode': instance.promoCode,
      'referralCampaignId': instance.referralCampaignId,
      'isVerifyEmail': instance.isVerifyEmail,
      'isFormCompleted': instance.isFormCompleted,
      'mobile': instance.mobile,
      'phonePrefix': instance.phonePrefix,
      'type': instance.type,
      'isLead': instance.isLead,
      'balance': instance.balance,
      'mt5Group': instance.mt5Group,
      'ip': instance.ip,
      'permissions': instance.permissions,
      'registerDate': instance.registerDate,
      'profile': instance.profile,
      'roles': instance.roles,
      'added_user_info': instance.addedUserInfo,
      'identityForm': instance.identityForm,
      'addressForm': instance.addressForm,
      'ibWallet': instance.ibWallet,
      'campaignsGroupList': instance.campaignsGroupList,
      'mt5ClientCreatedAt': instance.mt5ClientCreatedAt,
      'mt5ClientError': instance.mt5ClientError,
      'mt5ClientId': instance.mt5ClientId,
      'mt5ClientStatus': instance.mt5ClientStatus,
      'editUserInfo': instance.editUserInfo,
      'paymentMethodList': instance.paymentMethodList,
      'phone': instance.phone,
      'fullName': instance.fullName,
      'avatarUrl': instance.avatarUrl,
      'metadata': instance.metadata,
      'hasAccount': instance.hasAccount,
      'addresses': instance.addresses,
      'emailVerified': instance.emailVerified,
      'role': UserRole.toJson(instance.role),
      'status': _$UserStatusEnumMap[instance.status]!,
      'deletedAt': instance.deletedAt?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$UserStatusEnumMap = {
  UserStatus.active: 'active',
  UserStatus.blocked: 'blocked',
};
