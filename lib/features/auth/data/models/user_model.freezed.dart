// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserModel {

@JsonKey(name: '_id') String? get sId; int get id; bool? get active; String get email; String? get password; String? get image; String? get firstName; String? get lastName; String? get clientType; String? get idNumber; Map<String, dynamic>? get country; String? get birthDate; bool? get isIb; String? get promoCode; String? get referralCampaignId; bool? get isVerifyEmail; bool? get isFormCompleted; String? get mobile; String? get phonePrefix; String? get type; bool? get isLead; num? get balance; Map<String, dynamic>? get mt5Group; String? get ip; List<String>? get permissions; String? get registerDate; Map<String, dynamic>? get profile; List<dynamic>? get roles;@JsonKey(name: 'added_user_info') Map<String, dynamic>? get addedUserInfo; Map<String, dynamic>? get identityForm; Map<String, dynamic>? get addressForm; Map<String, dynamic>? get ibWallet; List<dynamic>? get campaignsGroupList; String? get mt5ClientCreatedAt; String? get mt5ClientError; String? get mt5ClientId; String? get mt5ClientStatus; Map<String, dynamic>? get editUserInfo; List<dynamic>? get paymentMethodList;// Legacy and helper fields
 String? get phone; String? get fullName; String? get avatarUrl; Map<String, dynamic>? get metadata; bool? get hasAccount; List<Map<String, dynamic>>? get addresses; bool get emailVerified;@JsonKey(fromJson: UserRole.fromJson, toJson: UserRole.toJson) UserRole get role; UserStatus get status; DateTime? get deletedAt; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserModelCopyWith<UserModel> get copyWith => _$UserModelCopyWithImpl<UserModel>(this as UserModel, _$identity);

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserModel&&(identical(other.sId, sId) || other.sId == sId)&&(identical(other.id, id) || other.id == id)&&(identical(other.active, active) || other.active == active)&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password)&&(identical(other.image, image) || other.image == image)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.clientType, clientType) || other.clientType == clientType)&&(identical(other.idNumber, idNumber) || other.idNumber == idNumber)&&const DeepCollectionEquality().equals(other.country, country)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&(identical(other.isIb, isIb) || other.isIb == isIb)&&(identical(other.promoCode, promoCode) || other.promoCode == promoCode)&&(identical(other.referralCampaignId, referralCampaignId) || other.referralCampaignId == referralCampaignId)&&(identical(other.isVerifyEmail, isVerifyEmail) || other.isVerifyEmail == isVerifyEmail)&&(identical(other.isFormCompleted, isFormCompleted) || other.isFormCompleted == isFormCompleted)&&(identical(other.mobile, mobile) || other.mobile == mobile)&&(identical(other.phonePrefix, phonePrefix) || other.phonePrefix == phonePrefix)&&(identical(other.type, type) || other.type == type)&&(identical(other.isLead, isLead) || other.isLead == isLead)&&(identical(other.balance, balance) || other.balance == balance)&&const DeepCollectionEquality().equals(other.mt5Group, mt5Group)&&(identical(other.ip, ip) || other.ip == ip)&&const DeepCollectionEquality().equals(other.permissions, permissions)&&(identical(other.registerDate, registerDate) || other.registerDate == registerDate)&&const DeepCollectionEquality().equals(other.profile, profile)&&const DeepCollectionEquality().equals(other.roles, roles)&&const DeepCollectionEquality().equals(other.addedUserInfo, addedUserInfo)&&const DeepCollectionEquality().equals(other.identityForm, identityForm)&&const DeepCollectionEquality().equals(other.addressForm, addressForm)&&const DeepCollectionEquality().equals(other.ibWallet, ibWallet)&&const DeepCollectionEquality().equals(other.campaignsGroupList, campaignsGroupList)&&(identical(other.mt5ClientCreatedAt, mt5ClientCreatedAt) || other.mt5ClientCreatedAt == mt5ClientCreatedAt)&&(identical(other.mt5ClientError, mt5ClientError) || other.mt5ClientError == mt5ClientError)&&(identical(other.mt5ClientId, mt5ClientId) || other.mt5ClientId == mt5ClientId)&&(identical(other.mt5ClientStatus, mt5ClientStatus) || other.mt5ClientStatus == mt5ClientStatus)&&const DeepCollectionEquality().equals(other.editUserInfo, editUserInfo)&&const DeepCollectionEquality().equals(other.paymentMethodList, paymentMethodList)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.hasAccount, hasAccount) || other.hasAccount == hasAccount)&&const DeepCollectionEquality().equals(other.addresses, addresses)&&(identical(other.emailVerified, emailVerified) || other.emailVerified == emailVerified)&&(identical(other.role, role) || other.role == role)&&(identical(other.status, status) || other.status == status)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,sId,id,active,email,password,image,firstName,lastName,clientType,idNumber,const DeepCollectionEquality().hash(country),birthDate,isIb,promoCode,referralCampaignId,isVerifyEmail,isFormCompleted,mobile,phonePrefix,type,isLead,balance,const DeepCollectionEquality().hash(mt5Group),ip,const DeepCollectionEquality().hash(permissions),registerDate,const DeepCollectionEquality().hash(profile),const DeepCollectionEquality().hash(roles),const DeepCollectionEquality().hash(addedUserInfo),const DeepCollectionEquality().hash(identityForm),const DeepCollectionEquality().hash(addressForm),const DeepCollectionEquality().hash(ibWallet),const DeepCollectionEquality().hash(campaignsGroupList),mt5ClientCreatedAt,mt5ClientError,mt5ClientId,mt5ClientStatus,const DeepCollectionEquality().hash(editUserInfo),const DeepCollectionEquality().hash(paymentMethodList),phone,fullName,avatarUrl,const DeepCollectionEquality().hash(metadata),hasAccount,const DeepCollectionEquality().hash(addresses),emailVerified,role,status,deletedAt,createdAt,updatedAt]);

@override
String toString() {
  return 'UserModel(sId: $sId, id: $id, active: $active, email: $email, password: $password, image: $image, firstName: $firstName, lastName: $lastName, clientType: $clientType, idNumber: $idNumber, country: $country, birthDate: $birthDate, isIb: $isIb, promoCode: $promoCode, referralCampaignId: $referralCampaignId, isVerifyEmail: $isVerifyEmail, isFormCompleted: $isFormCompleted, mobile: $mobile, phonePrefix: $phonePrefix, type: $type, isLead: $isLead, balance: $balance, mt5Group: $mt5Group, ip: $ip, permissions: $permissions, registerDate: $registerDate, profile: $profile, roles: $roles, addedUserInfo: $addedUserInfo, identityForm: $identityForm, addressForm: $addressForm, ibWallet: $ibWallet, campaignsGroupList: $campaignsGroupList, mt5ClientCreatedAt: $mt5ClientCreatedAt, mt5ClientError: $mt5ClientError, mt5ClientId: $mt5ClientId, mt5ClientStatus: $mt5ClientStatus, editUserInfo: $editUserInfo, paymentMethodList: $paymentMethodList, phone: $phone, fullName: $fullName, avatarUrl: $avatarUrl, metadata: $metadata, hasAccount: $hasAccount, addresses: $addresses, emailVerified: $emailVerified, role: $role, status: $status, deletedAt: $deletedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $UserModelCopyWith<$Res>  {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) _then) = _$UserModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: '_id') String? sId, int id, bool? active, String email, String? password, String? image, String? firstName, String? lastName, String? clientType, String? idNumber, Map<String, dynamic>? country, String? birthDate, bool? isIb, String? promoCode, String? referralCampaignId, bool? isVerifyEmail, bool? isFormCompleted, String? mobile, String? phonePrefix, String? type, bool? isLead, num? balance, Map<String, dynamic>? mt5Group, String? ip, List<String>? permissions, String? registerDate, Map<String, dynamic>? profile, List<dynamic>? roles,@JsonKey(name: 'added_user_info') Map<String, dynamic>? addedUserInfo, Map<String, dynamic>? identityForm, Map<String, dynamic>? addressForm, Map<String, dynamic>? ibWallet, List<dynamic>? campaignsGroupList, String? mt5ClientCreatedAt, String? mt5ClientError, String? mt5ClientId, String? mt5ClientStatus, Map<String, dynamic>? editUserInfo, List<dynamic>? paymentMethodList, String? phone, String? fullName, String? avatarUrl, Map<String, dynamic>? metadata, bool? hasAccount, List<Map<String, dynamic>>? addresses, bool emailVerified,@JsonKey(fromJson: UserRole.fromJson, toJson: UserRole.toJson) UserRole role, UserStatus status, DateTime? deletedAt, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$UserModelCopyWithImpl<$Res>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._self, this._then);

  final UserModel _self;
  final $Res Function(UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sId = freezed,Object? id = null,Object? active = freezed,Object? email = null,Object? password = freezed,Object? image = freezed,Object? firstName = freezed,Object? lastName = freezed,Object? clientType = freezed,Object? idNumber = freezed,Object? country = freezed,Object? birthDate = freezed,Object? isIb = freezed,Object? promoCode = freezed,Object? referralCampaignId = freezed,Object? isVerifyEmail = freezed,Object? isFormCompleted = freezed,Object? mobile = freezed,Object? phonePrefix = freezed,Object? type = freezed,Object? isLead = freezed,Object? balance = freezed,Object? mt5Group = freezed,Object? ip = freezed,Object? permissions = freezed,Object? registerDate = freezed,Object? profile = freezed,Object? roles = freezed,Object? addedUserInfo = freezed,Object? identityForm = freezed,Object? addressForm = freezed,Object? ibWallet = freezed,Object? campaignsGroupList = freezed,Object? mt5ClientCreatedAt = freezed,Object? mt5ClientError = freezed,Object? mt5ClientId = freezed,Object? mt5ClientStatus = freezed,Object? editUserInfo = freezed,Object? paymentMethodList = freezed,Object? phone = freezed,Object? fullName = freezed,Object? avatarUrl = freezed,Object? metadata = freezed,Object? hasAccount = freezed,Object? addresses = freezed,Object? emailVerified = null,Object? role = null,Object? status = null,Object? deletedAt = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
sId: freezed == sId ? _self.sId : sId // ignore: cast_nullable_to_non_nullable
as String?,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,active: freezed == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool?,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: freezed == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String?,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String?,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,clientType: freezed == clientType ? _self.clientType : clientType // ignore: cast_nullable_to_non_nullable
as String?,idNumber: freezed == idNumber ? _self.idNumber : idNumber // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,birthDate: freezed == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as String?,isIb: freezed == isIb ? _self.isIb : isIb // ignore: cast_nullable_to_non_nullable
as bool?,promoCode: freezed == promoCode ? _self.promoCode : promoCode // ignore: cast_nullable_to_non_nullable
as String?,referralCampaignId: freezed == referralCampaignId ? _self.referralCampaignId : referralCampaignId // ignore: cast_nullable_to_non_nullable
as String?,isVerifyEmail: freezed == isVerifyEmail ? _self.isVerifyEmail : isVerifyEmail // ignore: cast_nullable_to_non_nullable
as bool?,isFormCompleted: freezed == isFormCompleted ? _self.isFormCompleted : isFormCompleted // ignore: cast_nullable_to_non_nullable
as bool?,mobile: freezed == mobile ? _self.mobile : mobile // ignore: cast_nullable_to_non_nullable
as String?,phonePrefix: freezed == phonePrefix ? _self.phonePrefix : phonePrefix // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,isLead: freezed == isLead ? _self.isLead : isLead // ignore: cast_nullable_to_non_nullable
as bool?,balance: freezed == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as num?,mt5Group: freezed == mt5Group ? _self.mt5Group : mt5Group // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,ip: freezed == ip ? _self.ip : ip // ignore: cast_nullable_to_non_nullable
as String?,permissions: freezed == permissions ? _self.permissions : permissions // ignore: cast_nullable_to_non_nullable
as List<String>?,registerDate: freezed == registerDate ? _self.registerDate : registerDate // ignore: cast_nullable_to_non_nullable
as String?,profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,roles: freezed == roles ? _self.roles : roles // ignore: cast_nullable_to_non_nullable
as List<dynamic>?,addedUserInfo: freezed == addedUserInfo ? _self.addedUserInfo : addedUserInfo // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,identityForm: freezed == identityForm ? _self.identityForm : identityForm // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,addressForm: freezed == addressForm ? _self.addressForm : addressForm // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,ibWallet: freezed == ibWallet ? _self.ibWallet : ibWallet // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,campaignsGroupList: freezed == campaignsGroupList ? _self.campaignsGroupList : campaignsGroupList // ignore: cast_nullable_to_non_nullable
as List<dynamic>?,mt5ClientCreatedAt: freezed == mt5ClientCreatedAt ? _self.mt5ClientCreatedAt : mt5ClientCreatedAt // ignore: cast_nullable_to_non_nullable
as String?,mt5ClientError: freezed == mt5ClientError ? _self.mt5ClientError : mt5ClientError // ignore: cast_nullable_to_non_nullable
as String?,mt5ClientId: freezed == mt5ClientId ? _self.mt5ClientId : mt5ClientId // ignore: cast_nullable_to_non_nullable
as String?,mt5ClientStatus: freezed == mt5ClientStatus ? _self.mt5ClientStatus : mt5ClientStatus // ignore: cast_nullable_to_non_nullable
as String?,editUserInfo: freezed == editUserInfo ? _self.editUserInfo : editUserInfo // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,paymentMethodList: freezed == paymentMethodList ? _self.paymentMethodList : paymentMethodList // ignore: cast_nullable_to_non_nullable
as List<dynamic>?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,fullName: freezed == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,hasAccount: freezed == hasAccount ? _self.hasAccount : hasAccount // ignore: cast_nullable_to_non_nullable
as bool?,addresses: freezed == addresses ? _self.addresses : addresses // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>?,emailVerified: null == emailVerified ? _self.emailVerified : emailVerified // ignore: cast_nullable_to_non_nullable
as bool,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as UserStatus,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserModel].
extension UserModelPatterns on UserModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserModel value)  $default,){
final _that = this;
switch (_that) {
case _UserModel():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserModel value)?  $default,){
final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: '_id')  String? sId,  int id,  bool? active,  String email,  String? password,  String? image,  String? firstName,  String? lastName,  String? clientType,  String? idNumber,  Map<String, dynamic>? country,  String? birthDate,  bool? isIb,  String? promoCode,  String? referralCampaignId,  bool? isVerifyEmail,  bool? isFormCompleted,  String? mobile,  String? phonePrefix,  String? type,  bool? isLead,  num? balance,  Map<String, dynamic>? mt5Group,  String? ip,  List<String>? permissions,  String? registerDate,  Map<String, dynamic>? profile,  List<dynamic>? roles, @JsonKey(name: 'added_user_info')  Map<String, dynamic>? addedUserInfo,  Map<String, dynamic>? identityForm,  Map<String, dynamic>? addressForm,  Map<String, dynamic>? ibWallet,  List<dynamic>? campaignsGroupList,  String? mt5ClientCreatedAt,  String? mt5ClientError,  String? mt5ClientId,  String? mt5ClientStatus,  Map<String, dynamic>? editUserInfo,  List<dynamic>? paymentMethodList,  String? phone,  String? fullName,  String? avatarUrl,  Map<String, dynamic>? metadata,  bool? hasAccount,  List<Map<String, dynamic>>? addresses,  bool emailVerified, @JsonKey(fromJson: UserRole.fromJson, toJson: UserRole.toJson)  UserRole role,  UserStatus status,  DateTime? deletedAt,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that.sId,_that.id,_that.active,_that.email,_that.password,_that.image,_that.firstName,_that.lastName,_that.clientType,_that.idNumber,_that.country,_that.birthDate,_that.isIb,_that.promoCode,_that.referralCampaignId,_that.isVerifyEmail,_that.isFormCompleted,_that.mobile,_that.phonePrefix,_that.type,_that.isLead,_that.balance,_that.mt5Group,_that.ip,_that.permissions,_that.registerDate,_that.profile,_that.roles,_that.addedUserInfo,_that.identityForm,_that.addressForm,_that.ibWallet,_that.campaignsGroupList,_that.mt5ClientCreatedAt,_that.mt5ClientError,_that.mt5ClientId,_that.mt5ClientStatus,_that.editUserInfo,_that.paymentMethodList,_that.phone,_that.fullName,_that.avatarUrl,_that.metadata,_that.hasAccount,_that.addresses,_that.emailVerified,_that.role,_that.status,_that.deletedAt,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: '_id')  String? sId,  int id,  bool? active,  String email,  String? password,  String? image,  String? firstName,  String? lastName,  String? clientType,  String? idNumber,  Map<String, dynamic>? country,  String? birthDate,  bool? isIb,  String? promoCode,  String? referralCampaignId,  bool? isVerifyEmail,  bool? isFormCompleted,  String? mobile,  String? phonePrefix,  String? type,  bool? isLead,  num? balance,  Map<String, dynamic>? mt5Group,  String? ip,  List<String>? permissions,  String? registerDate,  Map<String, dynamic>? profile,  List<dynamic>? roles, @JsonKey(name: 'added_user_info')  Map<String, dynamic>? addedUserInfo,  Map<String, dynamic>? identityForm,  Map<String, dynamic>? addressForm,  Map<String, dynamic>? ibWallet,  List<dynamic>? campaignsGroupList,  String? mt5ClientCreatedAt,  String? mt5ClientError,  String? mt5ClientId,  String? mt5ClientStatus,  Map<String, dynamic>? editUserInfo,  List<dynamic>? paymentMethodList,  String? phone,  String? fullName,  String? avatarUrl,  Map<String, dynamic>? metadata,  bool? hasAccount,  List<Map<String, dynamic>>? addresses,  bool emailVerified, @JsonKey(fromJson: UserRole.fromJson, toJson: UserRole.toJson)  UserRole role,  UserStatus status,  DateTime? deletedAt,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _UserModel():
return $default(_that.sId,_that.id,_that.active,_that.email,_that.password,_that.image,_that.firstName,_that.lastName,_that.clientType,_that.idNumber,_that.country,_that.birthDate,_that.isIb,_that.promoCode,_that.referralCampaignId,_that.isVerifyEmail,_that.isFormCompleted,_that.mobile,_that.phonePrefix,_that.type,_that.isLead,_that.balance,_that.mt5Group,_that.ip,_that.permissions,_that.registerDate,_that.profile,_that.roles,_that.addedUserInfo,_that.identityForm,_that.addressForm,_that.ibWallet,_that.campaignsGroupList,_that.mt5ClientCreatedAt,_that.mt5ClientError,_that.mt5ClientId,_that.mt5ClientStatus,_that.editUserInfo,_that.paymentMethodList,_that.phone,_that.fullName,_that.avatarUrl,_that.metadata,_that.hasAccount,_that.addresses,_that.emailVerified,_that.role,_that.status,_that.deletedAt,_that.createdAt,_that.updatedAt);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: '_id')  String? sId,  int id,  bool? active,  String email,  String? password,  String? image,  String? firstName,  String? lastName,  String? clientType,  String? idNumber,  Map<String, dynamic>? country,  String? birthDate,  bool? isIb,  String? promoCode,  String? referralCampaignId,  bool? isVerifyEmail,  bool? isFormCompleted,  String? mobile,  String? phonePrefix,  String? type,  bool? isLead,  num? balance,  Map<String, dynamic>? mt5Group,  String? ip,  List<String>? permissions,  String? registerDate,  Map<String, dynamic>? profile,  List<dynamic>? roles, @JsonKey(name: 'added_user_info')  Map<String, dynamic>? addedUserInfo,  Map<String, dynamic>? identityForm,  Map<String, dynamic>? addressForm,  Map<String, dynamic>? ibWallet,  List<dynamic>? campaignsGroupList,  String? mt5ClientCreatedAt,  String? mt5ClientError,  String? mt5ClientId,  String? mt5ClientStatus,  Map<String, dynamic>? editUserInfo,  List<dynamic>? paymentMethodList,  String? phone,  String? fullName,  String? avatarUrl,  Map<String, dynamic>? metadata,  bool? hasAccount,  List<Map<String, dynamic>>? addresses,  bool emailVerified, @JsonKey(fromJson: UserRole.fromJson, toJson: UserRole.toJson)  UserRole role,  UserStatus status,  DateTime? deletedAt,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that.sId,_that.id,_that.active,_that.email,_that.password,_that.image,_that.firstName,_that.lastName,_that.clientType,_that.idNumber,_that.country,_that.birthDate,_that.isIb,_that.promoCode,_that.referralCampaignId,_that.isVerifyEmail,_that.isFormCompleted,_that.mobile,_that.phonePrefix,_that.type,_that.isLead,_that.balance,_that.mt5Group,_that.ip,_that.permissions,_that.registerDate,_that.profile,_that.roles,_that.addedUserInfo,_that.identityForm,_that.addressForm,_that.ibWallet,_that.campaignsGroupList,_that.mt5ClientCreatedAt,_that.mt5ClientError,_that.mt5ClientId,_that.mt5ClientStatus,_that.editUserInfo,_that.paymentMethodList,_that.phone,_that.fullName,_that.avatarUrl,_that.metadata,_that.hasAccount,_that.addresses,_that.emailVerified,_that.role,_that.status,_that.deletedAt,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserModel extends UserModel {
  const _UserModel({@JsonKey(name: '_id') this.sId, required this.id, this.active, required this.email, this.password, this.image, this.firstName, this.lastName, this.clientType, this.idNumber, final  Map<String, dynamic>? country, this.birthDate, this.isIb, this.promoCode, this.referralCampaignId, this.isVerifyEmail, this.isFormCompleted, this.mobile, this.phonePrefix, this.type, this.isLead, this.balance, final  Map<String, dynamic>? mt5Group, this.ip, final  List<String>? permissions, this.registerDate, final  Map<String, dynamic>? profile, final  List<dynamic>? roles, @JsonKey(name: 'added_user_info') final  Map<String, dynamic>? addedUserInfo, final  Map<String, dynamic>? identityForm, final  Map<String, dynamic>? addressForm, final  Map<String, dynamic>? ibWallet, final  List<dynamic>? campaignsGroupList, this.mt5ClientCreatedAt, this.mt5ClientError, this.mt5ClientId, this.mt5ClientStatus, final  Map<String, dynamic>? editUserInfo, final  List<dynamic>? paymentMethodList, this.phone, this.fullName, this.avatarUrl, final  Map<String, dynamic>? metadata, this.hasAccount, final  List<Map<String, dynamic>>? addresses, this.emailVerified = false, @JsonKey(fromJson: UserRole.fromJson, toJson: UserRole.toJson) this.role = UserRole.student, this.status = UserStatus.active, this.deletedAt, this.createdAt, this.updatedAt}): _country = country,_mt5Group = mt5Group,_permissions = permissions,_profile = profile,_roles = roles,_addedUserInfo = addedUserInfo,_identityForm = identityForm,_addressForm = addressForm,_ibWallet = ibWallet,_campaignsGroupList = campaignsGroupList,_editUserInfo = editUserInfo,_paymentMethodList = paymentMethodList,_metadata = metadata,_addresses = addresses,super._();
  factory _UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

@override@JsonKey(name: '_id') final  String? sId;
@override final  int id;
@override final  bool? active;
@override final  String email;
@override final  String? password;
@override final  String? image;
@override final  String? firstName;
@override final  String? lastName;
@override final  String? clientType;
@override final  String? idNumber;
 final  Map<String, dynamic>? _country;
@override Map<String, dynamic>? get country {
  final value = _country;
  if (value == null) return null;
  if (_country is EqualUnmodifiableMapView) return _country;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  String? birthDate;
@override final  bool? isIb;
@override final  String? promoCode;
@override final  String? referralCampaignId;
@override final  bool? isVerifyEmail;
@override final  bool? isFormCompleted;
@override final  String? mobile;
@override final  String? phonePrefix;
@override final  String? type;
@override final  bool? isLead;
@override final  num? balance;
 final  Map<String, dynamic>? _mt5Group;
@override Map<String, dynamic>? get mt5Group {
  final value = _mt5Group;
  if (value == null) return null;
  if (_mt5Group is EqualUnmodifiableMapView) return _mt5Group;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  String? ip;
 final  List<String>? _permissions;
@override List<String>? get permissions {
  final value = _permissions;
  if (value == null) return null;
  if (_permissions is EqualUnmodifiableListView) return _permissions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? registerDate;
 final  Map<String, dynamic>? _profile;
@override Map<String, dynamic>? get profile {
  final value = _profile;
  if (value == null) return null;
  if (_profile is EqualUnmodifiableMapView) return _profile;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  List<dynamic>? _roles;
@override List<dynamic>? get roles {
  final value = _roles;
  if (value == null) return null;
  if (_roles is EqualUnmodifiableListView) return _roles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  Map<String, dynamic>? _addedUserInfo;
@override@JsonKey(name: 'added_user_info') Map<String, dynamic>? get addedUserInfo {
  final value = _addedUserInfo;
  if (value == null) return null;
  if (_addedUserInfo is EqualUnmodifiableMapView) return _addedUserInfo;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, dynamic>? _identityForm;
@override Map<String, dynamic>? get identityForm {
  final value = _identityForm;
  if (value == null) return null;
  if (_identityForm is EqualUnmodifiableMapView) return _identityForm;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, dynamic>? _addressForm;
@override Map<String, dynamic>? get addressForm {
  final value = _addressForm;
  if (value == null) return null;
  if (_addressForm is EqualUnmodifiableMapView) return _addressForm;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, dynamic>? _ibWallet;
@override Map<String, dynamic>? get ibWallet {
  final value = _ibWallet;
  if (value == null) return null;
  if (_ibWallet is EqualUnmodifiableMapView) return _ibWallet;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  List<dynamic>? _campaignsGroupList;
@override List<dynamic>? get campaignsGroupList {
  final value = _campaignsGroupList;
  if (value == null) return null;
  if (_campaignsGroupList is EqualUnmodifiableListView) return _campaignsGroupList;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? mt5ClientCreatedAt;
@override final  String? mt5ClientError;
@override final  String? mt5ClientId;
@override final  String? mt5ClientStatus;
 final  Map<String, dynamic>? _editUserInfo;
@override Map<String, dynamic>? get editUserInfo {
  final value = _editUserInfo;
  if (value == null) return null;
  if (_editUserInfo is EqualUnmodifiableMapView) return _editUserInfo;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  List<dynamic>? _paymentMethodList;
@override List<dynamic>? get paymentMethodList {
  final value = _paymentMethodList;
  if (value == null) return null;
  if (_paymentMethodList is EqualUnmodifiableListView) return _paymentMethodList;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

// Legacy and helper fields
@override final  String? phone;
@override final  String? fullName;
@override final  String? avatarUrl;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  bool? hasAccount;
 final  List<Map<String, dynamic>>? _addresses;
@override List<Map<String, dynamic>>? get addresses {
  final value = _addresses;
  if (value == null) return null;
  if (_addresses is EqualUnmodifiableListView) return _addresses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey() final  bool emailVerified;
@override@JsonKey(fromJson: UserRole.fromJson, toJson: UserRole.toJson) final  UserRole role;
@override@JsonKey() final  UserStatus status;
@override final  DateTime? deletedAt;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserModelCopyWith<_UserModel> get copyWith => __$UserModelCopyWithImpl<_UserModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserModel&&(identical(other.sId, sId) || other.sId == sId)&&(identical(other.id, id) || other.id == id)&&(identical(other.active, active) || other.active == active)&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password)&&(identical(other.image, image) || other.image == image)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.clientType, clientType) || other.clientType == clientType)&&(identical(other.idNumber, idNumber) || other.idNumber == idNumber)&&const DeepCollectionEquality().equals(other._country, _country)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&(identical(other.isIb, isIb) || other.isIb == isIb)&&(identical(other.promoCode, promoCode) || other.promoCode == promoCode)&&(identical(other.referralCampaignId, referralCampaignId) || other.referralCampaignId == referralCampaignId)&&(identical(other.isVerifyEmail, isVerifyEmail) || other.isVerifyEmail == isVerifyEmail)&&(identical(other.isFormCompleted, isFormCompleted) || other.isFormCompleted == isFormCompleted)&&(identical(other.mobile, mobile) || other.mobile == mobile)&&(identical(other.phonePrefix, phonePrefix) || other.phonePrefix == phonePrefix)&&(identical(other.type, type) || other.type == type)&&(identical(other.isLead, isLead) || other.isLead == isLead)&&(identical(other.balance, balance) || other.balance == balance)&&const DeepCollectionEquality().equals(other._mt5Group, _mt5Group)&&(identical(other.ip, ip) || other.ip == ip)&&const DeepCollectionEquality().equals(other._permissions, _permissions)&&(identical(other.registerDate, registerDate) || other.registerDate == registerDate)&&const DeepCollectionEquality().equals(other._profile, _profile)&&const DeepCollectionEquality().equals(other._roles, _roles)&&const DeepCollectionEquality().equals(other._addedUserInfo, _addedUserInfo)&&const DeepCollectionEquality().equals(other._identityForm, _identityForm)&&const DeepCollectionEquality().equals(other._addressForm, _addressForm)&&const DeepCollectionEquality().equals(other._ibWallet, _ibWallet)&&const DeepCollectionEquality().equals(other._campaignsGroupList, _campaignsGroupList)&&(identical(other.mt5ClientCreatedAt, mt5ClientCreatedAt) || other.mt5ClientCreatedAt == mt5ClientCreatedAt)&&(identical(other.mt5ClientError, mt5ClientError) || other.mt5ClientError == mt5ClientError)&&(identical(other.mt5ClientId, mt5ClientId) || other.mt5ClientId == mt5ClientId)&&(identical(other.mt5ClientStatus, mt5ClientStatus) || other.mt5ClientStatus == mt5ClientStatus)&&const DeepCollectionEquality().equals(other._editUserInfo, _editUserInfo)&&const DeepCollectionEquality().equals(other._paymentMethodList, _paymentMethodList)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.hasAccount, hasAccount) || other.hasAccount == hasAccount)&&const DeepCollectionEquality().equals(other._addresses, _addresses)&&(identical(other.emailVerified, emailVerified) || other.emailVerified == emailVerified)&&(identical(other.role, role) || other.role == role)&&(identical(other.status, status) || other.status == status)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,sId,id,active,email,password,image,firstName,lastName,clientType,idNumber,const DeepCollectionEquality().hash(_country),birthDate,isIb,promoCode,referralCampaignId,isVerifyEmail,isFormCompleted,mobile,phonePrefix,type,isLead,balance,const DeepCollectionEquality().hash(_mt5Group),ip,const DeepCollectionEquality().hash(_permissions),registerDate,const DeepCollectionEquality().hash(_profile),const DeepCollectionEquality().hash(_roles),const DeepCollectionEquality().hash(_addedUserInfo),const DeepCollectionEquality().hash(_identityForm),const DeepCollectionEquality().hash(_addressForm),const DeepCollectionEquality().hash(_ibWallet),const DeepCollectionEquality().hash(_campaignsGroupList),mt5ClientCreatedAt,mt5ClientError,mt5ClientId,mt5ClientStatus,const DeepCollectionEquality().hash(_editUserInfo),const DeepCollectionEquality().hash(_paymentMethodList),phone,fullName,avatarUrl,const DeepCollectionEquality().hash(_metadata),hasAccount,const DeepCollectionEquality().hash(_addresses),emailVerified,role,status,deletedAt,createdAt,updatedAt]);

@override
String toString() {
  return 'UserModel(sId: $sId, id: $id, active: $active, email: $email, password: $password, image: $image, firstName: $firstName, lastName: $lastName, clientType: $clientType, idNumber: $idNumber, country: $country, birthDate: $birthDate, isIb: $isIb, promoCode: $promoCode, referralCampaignId: $referralCampaignId, isVerifyEmail: $isVerifyEmail, isFormCompleted: $isFormCompleted, mobile: $mobile, phonePrefix: $phonePrefix, type: $type, isLead: $isLead, balance: $balance, mt5Group: $mt5Group, ip: $ip, permissions: $permissions, registerDate: $registerDate, profile: $profile, roles: $roles, addedUserInfo: $addedUserInfo, identityForm: $identityForm, addressForm: $addressForm, ibWallet: $ibWallet, campaignsGroupList: $campaignsGroupList, mt5ClientCreatedAt: $mt5ClientCreatedAt, mt5ClientError: $mt5ClientError, mt5ClientId: $mt5ClientId, mt5ClientStatus: $mt5ClientStatus, editUserInfo: $editUserInfo, paymentMethodList: $paymentMethodList, phone: $phone, fullName: $fullName, avatarUrl: $avatarUrl, metadata: $metadata, hasAccount: $hasAccount, addresses: $addresses, emailVerified: $emailVerified, role: $role, status: $status, deletedAt: $deletedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$UserModelCopyWith<$Res> implements $UserModelCopyWith<$Res> {
  factory _$UserModelCopyWith(_UserModel value, $Res Function(_UserModel) _then) = __$UserModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: '_id') String? sId, int id, bool? active, String email, String? password, String? image, String? firstName, String? lastName, String? clientType, String? idNumber, Map<String, dynamic>? country, String? birthDate, bool? isIb, String? promoCode, String? referralCampaignId, bool? isVerifyEmail, bool? isFormCompleted, String? mobile, String? phonePrefix, String? type, bool? isLead, num? balance, Map<String, dynamic>? mt5Group, String? ip, List<String>? permissions, String? registerDate, Map<String, dynamic>? profile, List<dynamic>? roles,@JsonKey(name: 'added_user_info') Map<String, dynamic>? addedUserInfo, Map<String, dynamic>? identityForm, Map<String, dynamic>? addressForm, Map<String, dynamic>? ibWallet, List<dynamic>? campaignsGroupList, String? mt5ClientCreatedAt, String? mt5ClientError, String? mt5ClientId, String? mt5ClientStatus, Map<String, dynamic>? editUserInfo, List<dynamic>? paymentMethodList, String? phone, String? fullName, String? avatarUrl, Map<String, dynamic>? metadata, bool? hasAccount, List<Map<String, dynamic>>? addresses, bool emailVerified,@JsonKey(fromJson: UserRole.fromJson, toJson: UserRole.toJson) UserRole role, UserStatus status, DateTime? deletedAt, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$UserModelCopyWithImpl<$Res>
    implements _$UserModelCopyWith<$Res> {
  __$UserModelCopyWithImpl(this._self, this._then);

  final _UserModel _self;
  final $Res Function(_UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sId = freezed,Object? id = null,Object? active = freezed,Object? email = null,Object? password = freezed,Object? image = freezed,Object? firstName = freezed,Object? lastName = freezed,Object? clientType = freezed,Object? idNumber = freezed,Object? country = freezed,Object? birthDate = freezed,Object? isIb = freezed,Object? promoCode = freezed,Object? referralCampaignId = freezed,Object? isVerifyEmail = freezed,Object? isFormCompleted = freezed,Object? mobile = freezed,Object? phonePrefix = freezed,Object? type = freezed,Object? isLead = freezed,Object? balance = freezed,Object? mt5Group = freezed,Object? ip = freezed,Object? permissions = freezed,Object? registerDate = freezed,Object? profile = freezed,Object? roles = freezed,Object? addedUserInfo = freezed,Object? identityForm = freezed,Object? addressForm = freezed,Object? ibWallet = freezed,Object? campaignsGroupList = freezed,Object? mt5ClientCreatedAt = freezed,Object? mt5ClientError = freezed,Object? mt5ClientId = freezed,Object? mt5ClientStatus = freezed,Object? editUserInfo = freezed,Object? paymentMethodList = freezed,Object? phone = freezed,Object? fullName = freezed,Object? avatarUrl = freezed,Object? metadata = freezed,Object? hasAccount = freezed,Object? addresses = freezed,Object? emailVerified = null,Object? role = null,Object? status = null,Object? deletedAt = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_UserModel(
sId: freezed == sId ? _self.sId : sId // ignore: cast_nullable_to_non_nullable
as String?,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,active: freezed == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool?,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: freezed == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String?,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String?,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,clientType: freezed == clientType ? _self.clientType : clientType // ignore: cast_nullable_to_non_nullable
as String?,idNumber: freezed == idNumber ? _self.idNumber : idNumber // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self._country : country // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,birthDate: freezed == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as String?,isIb: freezed == isIb ? _self.isIb : isIb // ignore: cast_nullable_to_non_nullable
as bool?,promoCode: freezed == promoCode ? _self.promoCode : promoCode // ignore: cast_nullable_to_non_nullable
as String?,referralCampaignId: freezed == referralCampaignId ? _self.referralCampaignId : referralCampaignId // ignore: cast_nullable_to_non_nullable
as String?,isVerifyEmail: freezed == isVerifyEmail ? _self.isVerifyEmail : isVerifyEmail // ignore: cast_nullable_to_non_nullable
as bool?,isFormCompleted: freezed == isFormCompleted ? _self.isFormCompleted : isFormCompleted // ignore: cast_nullable_to_non_nullable
as bool?,mobile: freezed == mobile ? _self.mobile : mobile // ignore: cast_nullable_to_non_nullable
as String?,phonePrefix: freezed == phonePrefix ? _self.phonePrefix : phonePrefix // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,isLead: freezed == isLead ? _self.isLead : isLead // ignore: cast_nullable_to_non_nullable
as bool?,balance: freezed == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as num?,mt5Group: freezed == mt5Group ? _self._mt5Group : mt5Group // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,ip: freezed == ip ? _self.ip : ip // ignore: cast_nullable_to_non_nullable
as String?,permissions: freezed == permissions ? _self._permissions : permissions // ignore: cast_nullable_to_non_nullable
as List<String>?,registerDate: freezed == registerDate ? _self.registerDate : registerDate // ignore: cast_nullable_to_non_nullable
as String?,profile: freezed == profile ? _self._profile : profile // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,roles: freezed == roles ? _self._roles : roles // ignore: cast_nullable_to_non_nullable
as List<dynamic>?,addedUserInfo: freezed == addedUserInfo ? _self._addedUserInfo : addedUserInfo // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,identityForm: freezed == identityForm ? _self._identityForm : identityForm // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,addressForm: freezed == addressForm ? _self._addressForm : addressForm // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,ibWallet: freezed == ibWallet ? _self._ibWallet : ibWallet // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,campaignsGroupList: freezed == campaignsGroupList ? _self._campaignsGroupList : campaignsGroupList // ignore: cast_nullable_to_non_nullable
as List<dynamic>?,mt5ClientCreatedAt: freezed == mt5ClientCreatedAt ? _self.mt5ClientCreatedAt : mt5ClientCreatedAt // ignore: cast_nullable_to_non_nullable
as String?,mt5ClientError: freezed == mt5ClientError ? _self.mt5ClientError : mt5ClientError // ignore: cast_nullable_to_non_nullable
as String?,mt5ClientId: freezed == mt5ClientId ? _self.mt5ClientId : mt5ClientId // ignore: cast_nullable_to_non_nullable
as String?,mt5ClientStatus: freezed == mt5ClientStatus ? _self.mt5ClientStatus : mt5ClientStatus // ignore: cast_nullable_to_non_nullable
as String?,editUserInfo: freezed == editUserInfo ? _self._editUserInfo : editUserInfo // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,paymentMethodList: freezed == paymentMethodList ? _self._paymentMethodList : paymentMethodList // ignore: cast_nullable_to_non_nullable
as List<dynamic>?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,fullName: freezed == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,hasAccount: freezed == hasAccount ? _self.hasAccount : hasAccount // ignore: cast_nullable_to_non_nullable
as bool?,addresses: freezed == addresses ? _self._addresses : addresses // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>?,emailVerified: null == emailVerified ? _self.emailVerified : emailVerified // ignore: cast_nullable_to_non_nullable
as bool,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as UserStatus,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
