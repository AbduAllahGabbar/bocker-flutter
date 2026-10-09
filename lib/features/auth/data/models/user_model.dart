import 'package:freezed_annotation/freezed_annotation.dart';
import '../enums/user_role.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
sealed class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    @JsonKey(name: '_id') String? sId,
    required int id,
    bool? active,
    required String email,
    String? password,
    String? image,
    String? firstName,
    String? lastName,
    String? clientType,
    String? idNumber,
    Map<String, dynamic>? country,
    String? birthDate,
    bool? isIb,
    String? promoCode,
    String? referralCampaignId,
    bool? isVerifyEmail,
    bool? isFormCompleted,
    String? mobile,
    String? phonePrefix,
    String? type,
    bool? isLead,
    num? balance,
    Map<String, dynamic>? mt5Group,
    String? ip,
    List<String>? permissions,
    String? registerDate,
    Map<String, dynamic>? profile,
    List<dynamic>? roles,
    @JsonKey(name: 'added_user_info') Map<String, dynamic>? addedUserInfo,

    Map<String, dynamic>? identityForm,
    Map<String, dynamic>? addressForm,

    Map<String, dynamic>? ibWallet,
    List<dynamic>? campaignsGroupList,
    String? mt5ClientCreatedAt,
    String? mt5ClientError,
    String? mt5ClientId,
    String? mt5ClientStatus,
    Map<String, dynamic>? editUserInfo,
    List<dynamic>? paymentMethodList,

    // Legacy and helper fields
    String? phone,
    String? fullName,
    String? avatarUrl,
    Map<String, dynamic>? metadata,
    bool? hasAccount,
    List<Map<String, dynamic>>? addresses,
    @Default(false) bool emailVerified,
    @JsonKey(fromJson: UserRole.fromJson, toJson: UserRole.toJson)
    @Default(UserRole.student)
    UserRole role,
    @Default(UserStatus.active) UserStatus status,
    DateTime? deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _UserModel;

  String get userId => (id ?? sId ?? '').toString();

  String get displayFullName {
    if (fullName != null && fullName!.isNotEmpty) return fullName!;
    final name = '${firstName ?? ''} ${lastName ?? ''}'.trim();
    return name.isNotEmpty ? name : email;
  }

  String get displayPhone {
    if (phone != null && phone!.isNotEmpty) return phone!;
    return '${phonePrefix ?? ''}${mobile ?? ''}';
  }

  bool get isEmailVerified => (isVerifyEmail == true) || emailVerified;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
