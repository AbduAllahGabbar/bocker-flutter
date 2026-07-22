// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AuthState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthState()';
}


}

/// @nodoc
class $AuthStateCopyWith<$Res>  {
$AuthStateCopyWith(AuthState _, $Res Function(AuthState) __);
}


/// Adds pattern-matching-related methods to [AuthState].
extension AuthStatePatterns on AuthState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _Loading value)?  loading,TResult Function( _Authenticated value)?  authenticated,TResult Function( _Unauthenticated value)?  unauthenticated,TResult Function( _RegistrationPending value)?  registrationPending,TResult Function( _ResetPasswordSent value)?  resetPasswordSent,TResult Function( _ForgotPasswordOtpSent value)?  forgotPasswordOtpSent,TResult Function( _PasswordUpdated value)?  passwordUpdated,TResult Function( _OtpRequired value)?  otpRequired,TResult Function( _EmailOtpVerified value)?  emailOtpVerified,TResult Function( _IdentitySubmitted value)?  identitySubmitted,TResult Function( _FormNotCompleted value)?  formNotCompleted,TResult Function( _Error value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Authenticated() when authenticated != null:
return authenticated(_that);case _Unauthenticated() when unauthenticated != null:
return unauthenticated(_that);case _RegistrationPending() when registrationPending != null:
return registrationPending(_that);case _ResetPasswordSent() when resetPasswordSent != null:
return resetPasswordSent(_that);case _ForgotPasswordOtpSent() when forgotPasswordOtpSent != null:
return forgotPasswordOtpSent(_that);case _PasswordUpdated() when passwordUpdated != null:
return passwordUpdated(_that);case _OtpRequired() when otpRequired != null:
return otpRequired(_that);case _EmailOtpVerified() when emailOtpVerified != null:
return emailOtpVerified(_that);case _IdentitySubmitted() when identitySubmitted != null:
return identitySubmitted(_that);case _FormNotCompleted() when formNotCompleted != null:
return formNotCompleted(_that);case _Error() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _Loading value)  loading,required TResult Function( _Authenticated value)  authenticated,required TResult Function( _Unauthenticated value)  unauthenticated,required TResult Function( _RegistrationPending value)  registrationPending,required TResult Function( _ResetPasswordSent value)  resetPasswordSent,required TResult Function( _ForgotPasswordOtpSent value)  forgotPasswordOtpSent,required TResult Function( _PasswordUpdated value)  passwordUpdated,required TResult Function( _OtpRequired value)  otpRequired,required TResult Function( _EmailOtpVerified value)  emailOtpVerified,required TResult Function( _IdentitySubmitted value)  identitySubmitted,required TResult Function( _FormNotCompleted value)  formNotCompleted,required TResult Function( _Error value)  error,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _Loading():
return loading(_that);case _Authenticated():
return authenticated(_that);case _Unauthenticated():
return unauthenticated(_that);case _RegistrationPending():
return registrationPending(_that);case _ResetPasswordSent():
return resetPasswordSent(_that);case _ForgotPasswordOtpSent():
return forgotPasswordOtpSent(_that);case _PasswordUpdated():
return passwordUpdated(_that);case _OtpRequired():
return otpRequired(_that);case _EmailOtpVerified():
return emailOtpVerified(_that);case _IdentitySubmitted():
return identitySubmitted(_that);case _FormNotCompleted():
return formNotCompleted(_that);case _Error():
return error(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _Loading value)?  loading,TResult? Function( _Authenticated value)?  authenticated,TResult? Function( _Unauthenticated value)?  unauthenticated,TResult? Function( _RegistrationPending value)?  registrationPending,TResult? Function( _ResetPasswordSent value)?  resetPasswordSent,TResult? Function( _ForgotPasswordOtpSent value)?  forgotPasswordOtpSent,TResult? Function( _PasswordUpdated value)?  passwordUpdated,TResult? Function( _OtpRequired value)?  otpRequired,TResult? Function( _EmailOtpVerified value)?  emailOtpVerified,TResult? Function( _IdentitySubmitted value)?  identitySubmitted,TResult? Function( _FormNotCompleted value)?  formNotCompleted,TResult? Function( _Error value)?  error,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Authenticated() when authenticated != null:
return authenticated(_that);case _Unauthenticated() when unauthenticated != null:
return unauthenticated(_that);case _RegistrationPending() when registrationPending != null:
return registrationPending(_that);case _ResetPasswordSent() when resetPasswordSent != null:
return resetPasswordSent(_that);case _ForgotPasswordOtpSent() when forgotPasswordOtpSent != null:
return forgotPasswordOtpSent(_that);case _PasswordUpdated() when passwordUpdated != null:
return passwordUpdated(_that);case _OtpRequired() when otpRequired != null:
return otpRequired(_that);case _EmailOtpVerified() when emailOtpVerified != null:
return emailOtpVerified(_that);case _IdentitySubmitted() when identitySubmitted != null:
return identitySubmitted(_that);case _FormNotCompleted() when formNotCompleted != null:
return formNotCompleted(_that);case _Error() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( UserModel user,  String? token,  String? refreshToken,  bool isSignIn)?  authenticated,TResult Function()?  unauthenticated,TResult Function( UserModel user)?  registrationPending,TResult Function( String message)?  resetPasswordSent,TResult Function( String email)?  forgotPasswordOtpSent,TResult Function()?  passwordUpdated,TResult Function( String? customerId,  String? phone,  String? email)?  otpRequired,TResult Function()?  emailOtpVerified,TResult Function()?  identitySubmitted,TResult Function( String email,  String password)?  formNotCompleted,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Authenticated() when authenticated != null:
return authenticated(_that.user,_that.token,_that.refreshToken,_that.isSignIn);case _Unauthenticated() when unauthenticated != null:
return unauthenticated();case _RegistrationPending() when registrationPending != null:
return registrationPending(_that.user);case _ResetPasswordSent() when resetPasswordSent != null:
return resetPasswordSent(_that.message);case _ForgotPasswordOtpSent() when forgotPasswordOtpSent != null:
return forgotPasswordOtpSent(_that.email);case _PasswordUpdated() when passwordUpdated != null:
return passwordUpdated();case _OtpRequired() when otpRequired != null:
return otpRequired(_that.customerId,_that.phone,_that.email);case _EmailOtpVerified() when emailOtpVerified != null:
return emailOtpVerified();case _IdentitySubmitted() when identitySubmitted != null:
return identitySubmitted();case _FormNotCompleted() when formNotCompleted != null:
return formNotCompleted(_that.email,_that.password);case _Error() when error != null:
return error(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( UserModel user,  String? token,  String? refreshToken,  bool isSignIn)  authenticated,required TResult Function()  unauthenticated,required TResult Function( UserModel user)  registrationPending,required TResult Function( String message)  resetPasswordSent,required TResult Function( String email)  forgotPasswordOtpSent,required TResult Function()  passwordUpdated,required TResult Function( String? customerId,  String? phone,  String? email)  otpRequired,required TResult Function()  emailOtpVerified,required TResult Function()  identitySubmitted,required TResult Function( String email,  String password)  formNotCompleted,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _Loading():
return loading();case _Authenticated():
return authenticated(_that.user,_that.token,_that.refreshToken,_that.isSignIn);case _Unauthenticated():
return unauthenticated();case _RegistrationPending():
return registrationPending(_that.user);case _ResetPasswordSent():
return resetPasswordSent(_that.message);case _ForgotPasswordOtpSent():
return forgotPasswordOtpSent(_that.email);case _PasswordUpdated():
return passwordUpdated();case _OtpRequired():
return otpRequired(_that.customerId,_that.phone,_that.email);case _EmailOtpVerified():
return emailOtpVerified();case _IdentitySubmitted():
return identitySubmitted();case _FormNotCompleted():
return formNotCompleted(_that.email,_that.password);case _Error():
return error(_that.message);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( UserModel user,  String? token,  String? refreshToken,  bool isSignIn)?  authenticated,TResult? Function()?  unauthenticated,TResult? Function( UserModel user)?  registrationPending,TResult? Function( String message)?  resetPasswordSent,TResult? Function( String email)?  forgotPasswordOtpSent,TResult? Function()?  passwordUpdated,TResult? Function( String? customerId,  String? phone,  String? email)?  otpRequired,TResult? Function()?  emailOtpVerified,TResult? Function()?  identitySubmitted,TResult? Function( String email,  String password)?  formNotCompleted,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Authenticated() when authenticated != null:
return authenticated(_that.user,_that.token,_that.refreshToken,_that.isSignIn);case _Unauthenticated() when unauthenticated != null:
return unauthenticated();case _RegistrationPending() when registrationPending != null:
return registrationPending(_that.user);case _ResetPasswordSent() when resetPasswordSent != null:
return resetPasswordSent(_that.message);case _ForgotPasswordOtpSent() when forgotPasswordOtpSent != null:
return forgotPasswordOtpSent(_that.email);case _PasswordUpdated() when passwordUpdated != null:
return passwordUpdated();case _OtpRequired() when otpRequired != null:
return otpRequired(_that.customerId,_that.phone,_that.email);case _EmailOtpVerified() when emailOtpVerified != null:
return emailOtpVerified();case _IdentitySubmitted() when identitySubmitted != null:
return identitySubmitted();case _FormNotCompleted() when formNotCompleted != null:
return formNotCompleted(_that.email,_that.password);case _Error() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements AuthState {
  const _Initial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthState.initial()';
}


}




/// @nodoc


class _Loading implements AuthState {
  const _Loading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthState.loading()';
}


}




/// @nodoc


class _Authenticated implements AuthState {
  const _Authenticated({required this.user, this.token, this.refreshToken, this.isSignIn = true});
  

 final  UserModel user;
 final  String? token;
 final  String? refreshToken;
@JsonKey() final  bool isSignIn;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthenticatedCopyWith<_Authenticated> get copyWith => __$AuthenticatedCopyWithImpl<_Authenticated>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Authenticated&&(identical(other.user, user) || other.user == user)&&(identical(other.token, token) || other.token == token)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken)&&(identical(other.isSignIn, isSignIn) || other.isSignIn == isSignIn));
}


@override
int get hashCode => Object.hash(runtimeType,user,token,refreshToken,isSignIn);

@override
String toString() {
  return 'AuthState.authenticated(user: $user, token: $token, refreshToken: $refreshToken, isSignIn: $isSignIn)';
}


}

/// @nodoc
abstract mixin class _$AuthenticatedCopyWith<$Res> implements $AuthStateCopyWith<$Res> {
  factory _$AuthenticatedCopyWith(_Authenticated value, $Res Function(_Authenticated) _then) = __$AuthenticatedCopyWithImpl;
@useResult
$Res call({
 UserModel user, String? token, String? refreshToken, bool isSignIn
});


$UserModelCopyWith<$Res> get user;

}
/// @nodoc
class __$AuthenticatedCopyWithImpl<$Res>
    implements _$AuthenticatedCopyWith<$Res> {
  __$AuthenticatedCopyWithImpl(this._self, this._then);

  final _Authenticated _self;
  final $Res Function(_Authenticated) _then;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? user = null,Object? token = freezed,Object? refreshToken = freezed,Object? isSignIn = null,}) {
  return _then(_Authenticated(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserModel,token: freezed == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String?,refreshToken: freezed == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String?,isSignIn: null == isSignIn ? _self.isSignIn : isSignIn // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserModelCopyWith<$Res> get user {
  
  return $UserModelCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}

/// @nodoc


class _Unauthenticated implements AuthState {
  const _Unauthenticated();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Unauthenticated);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthState.unauthenticated()';
}


}




/// @nodoc


class _RegistrationPending implements AuthState {
  const _RegistrationPending(this.user);
  

 final  UserModel user;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegistrationPendingCopyWith<_RegistrationPending> get copyWith => __$RegistrationPendingCopyWithImpl<_RegistrationPending>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegistrationPending&&(identical(other.user, user) || other.user == user));
}


@override
int get hashCode => Object.hash(runtimeType,user);

@override
String toString() {
  return 'AuthState.registrationPending(user: $user)';
}


}

/// @nodoc
abstract mixin class _$RegistrationPendingCopyWith<$Res> implements $AuthStateCopyWith<$Res> {
  factory _$RegistrationPendingCopyWith(_RegistrationPending value, $Res Function(_RegistrationPending) _then) = __$RegistrationPendingCopyWithImpl;
@useResult
$Res call({
 UserModel user
});


$UserModelCopyWith<$Res> get user;

}
/// @nodoc
class __$RegistrationPendingCopyWithImpl<$Res>
    implements _$RegistrationPendingCopyWith<$Res> {
  __$RegistrationPendingCopyWithImpl(this._self, this._then);

  final _RegistrationPending _self;
  final $Res Function(_RegistrationPending) _then;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? user = null,}) {
  return _then(_RegistrationPending(
null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserModel,
  ));
}

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserModelCopyWith<$Res> get user {
  
  return $UserModelCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}

/// @nodoc


class _ResetPasswordSent implements AuthState {
  const _ResetPasswordSent(this.message);
  

 final  String message;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResetPasswordSentCopyWith<_ResetPasswordSent> get copyWith => __$ResetPasswordSentCopyWithImpl<_ResetPasswordSent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResetPasswordSent&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'AuthState.resetPasswordSent(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ResetPasswordSentCopyWith<$Res> implements $AuthStateCopyWith<$Res> {
  factory _$ResetPasswordSentCopyWith(_ResetPasswordSent value, $Res Function(_ResetPasswordSent) _then) = __$ResetPasswordSentCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$ResetPasswordSentCopyWithImpl<$Res>
    implements _$ResetPasswordSentCopyWith<$Res> {
  __$ResetPasswordSentCopyWithImpl(this._self, this._then);

  final _ResetPasswordSent _self;
  final $Res Function(_ResetPasswordSent) _then;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_ResetPasswordSent(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _ForgotPasswordOtpSent implements AuthState {
  const _ForgotPasswordOtpSent(this.email);
  

 final  String email;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ForgotPasswordOtpSentCopyWith<_ForgotPasswordOtpSent> get copyWith => __$ForgotPasswordOtpSentCopyWithImpl<_ForgotPasswordOtpSent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ForgotPasswordOtpSent&&(identical(other.email, email) || other.email == email));
}


@override
int get hashCode => Object.hash(runtimeType,email);

@override
String toString() {
  return 'AuthState.forgotPasswordOtpSent(email: $email)';
}


}

/// @nodoc
abstract mixin class _$ForgotPasswordOtpSentCopyWith<$Res> implements $AuthStateCopyWith<$Res> {
  factory _$ForgotPasswordOtpSentCopyWith(_ForgotPasswordOtpSent value, $Res Function(_ForgotPasswordOtpSent) _then) = __$ForgotPasswordOtpSentCopyWithImpl;
@useResult
$Res call({
 String email
});




}
/// @nodoc
class __$ForgotPasswordOtpSentCopyWithImpl<$Res>
    implements _$ForgotPasswordOtpSentCopyWith<$Res> {
  __$ForgotPasswordOtpSentCopyWithImpl(this._self, this._then);

  final _ForgotPasswordOtpSent _self;
  final $Res Function(_ForgotPasswordOtpSent) _then;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? email = null,}) {
  return _then(_ForgotPasswordOtpSent(
null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _PasswordUpdated implements AuthState {
  const _PasswordUpdated();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PasswordUpdated);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthState.passwordUpdated()';
}


}




/// @nodoc


class _OtpRequired implements AuthState {
  const _OtpRequired({this.customerId, this.phone, this.email});
  

 final  String? customerId;
 final  String? phone;
 final  String? email;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OtpRequiredCopyWith<_OtpRequired> get copyWith => __$OtpRequiredCopyWithImpl<_OtpRequired>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OtpRequired&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email));
}


@override
int get hashCode => Object.hash(runtimeType,customerId,phone,email);

@override
String toString() {
  return 'AuthState.otpRequired(customerId: $customerId, phone: $phone, email: $email)';
}


}

/// @nodoc
abstract mixin class _$OtpRequiredCopyWith<$Res> implements $AuthStateCopyWith<$Res> {
  factory _$OtpRequiredCopyWith(_OtpRequired value, $Res Function(_OtpRequired) _then) = __$OtpRequiredCopyWithImpl;
@useResult
$Res call({
 String? customerId, String? phone, String? email
});




}
/// @nodoc
class __$OtpRequiredCopyWithImpl<$Res>
    implements _$OtpRequiredCopyWith<$Res> {
  __$OtpRequiredCopyWithImpl(this._self, this._then);

  final _OtpRequired _self;
  final $Res Function(_OtpRequired) _then;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? customerId = freezed,Object? phone = freezed,Object? email = freezed,}) {
  return _then(_OtpRequired(
customerId: freezed == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _EmailOtpVerified implements AuthState {
  const _EmailOtpVerified();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EmailOtpVerified);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthState.emailOtpVerified()';
}


}




/// @nodoc


class _IdentitySubmitted implements AuthState {
  const _IdentitySubmitted();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IdentitySubmitted);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthState.identitySubmitted()';
}


}




/// @nodoc


class _FormNotCompleted implements AuthState {
  const _FormNotCompleted({required this.email, required this.password});
  

 final  String email;
 final  String password;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FormNotCompletedCopyWith<_FormNotCompleted> get copyWith => __$FormNotCompletedCopyWithImpl<_FormNotCompleted>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FormNotCompleted&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password));
}


@override
int get hashCode => Object.hash(runtimeType,email,password);

@override
String toString() {
  return 'AuthState.formNotCompleted(email: $email, password: $password)';
}


}

/// @nodoc
abstract mixin class _$FormNotCompletedCopyWith<$Res> implements $AuthStateCopyWith<$Res> {
  factory _$FormNotCompletedCopyWith(_FormNotCompleted value, $Res Function(_FormNotCompleted) _then) = __$FormNotCompletedCopyWithImpl;
@useResult
$Res call({
 String email, String password
});




}
/// @nodoc
class __$FormNotCompletedCopyWithImpl<$Res>
    implements _$FormNotCompletedCopyWith<$Res> {
  __$FormNotCompletedCopyWithImpl(this._self, this._then);

  final _FormNotCompleted _self;
  final $Res Function(_FormNotCompleted) _then;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? email = null,Object? password = null,}) {
  return _then(_FormNotCompleted(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _Error implements AuthState {
  const _Error(this.message);
  

 final  String message;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ErrorCopyWith<_Error> get copyWith => __$ErrorCopyWithImpl<_Error>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Error&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'AuthState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res> implements $AuthStateCopyWith<$Res> {
  factory _$ErrorCopyWith(_Error value, $Res Function(_Error) _then) = __$ErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$ErrorCopyWithImpl<$Res>
    implements _$ErrorCopyWith<$Res> {
  __$ErrorCopyWithImpl(this._self, this._then);

  final _Error _self;
  final $Res Function(_Error) _then;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Error(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
