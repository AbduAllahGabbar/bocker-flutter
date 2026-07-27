// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ticket_details_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TicketDetailsState {

 Map<String, dynamic> get ticket;
/// Create a copy of TicketDetailsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TicketDetailsStateCopyWith<TicketDetailsState> get copyWith => _$TicketDetailsStateCopyWithImpl<TicketDetailsState>(this as TicketDetailsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TicketDetailsState&&const DeepCollectionEquality().equals(other.ticket, ticket));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(ticket));

@override
String toString() {
  return 'TicketDetailsState(ticket: $ticket)';
}


}

/// @nodoc
abstract mixin class $TicketDetailsStateCopyWith<$Res>  {
  factory $TicketDetailsStateCopyWith(TicketDetailsState value, $Res Function(TicketDetailsState) _then) = _$TicketDetailsStateCopyWithImpl;
@useResult
$Res call({
 Map<String, dynamic> ticket
});




}
/// @nodoc
class _$TicketDetailsStateCopyWithImpl<$Res>
    implements $TicketDetailsStateCopyWith<$Res> {
  _$TicketDetailsStateCopyWithImpl(this._self, this._then);

  final TicketDetailsState _self;
  final $Res Function(TicketDetailsState) _then;

/// Create a copy of TicketDetailsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ticket = null,}) {
  return _then(_self.copyWith(
ticket: null == ticket ? _self.ticket : ticket // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [TicketDetailsState].
extension TicketDetailsStatePatterns on TicketDetailsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _Loading value)?  loading,TResult Function( _Success value)?  success,TResult Function( _Error value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Success() when success != null:
return success(_that);case _Error() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _Loading value)  loading,required TResult Function( _Success value)  success,required TResult Function( _Error value)  error,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _Loading():
return loading(_that);case _Success():
return success(_that);case _Error():
return error(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _Loading value)?  loading,TResult? Function( _Success value)?  success,TResult? Function( _Error value)?  error,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Success() when success != null:
return success(_that);case _Error() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( Map<String, dynamic> ticket)?  initial,TResult Function( Map<String, dynamic> ticket)?  loading,TResult Function( Map<String, dynamic> ticket)?  success,TResult Function( Map<String, dynamic> ticket,  String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that.ticket);case _Loading() when loading != null:
return loading(_that.ticket);case _Success() when success != null:
return success(_that.ticket);case _Error() when error != null:
return error(_that.ticket,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( Map<String, dynamic> ticket)  initial,required TResult Function( Map<String, dynamic> ticket)  loading,required TResult Function( Map<String, dynamic> ticket)  success,required TResult Function( Map<String, dynamic> ticket,  String message)  error,}) {final _that = this;
switch (_that) {
case _Initial():
return initial(_that.ticket);case _Loading():
return loading(_that.ticket);case _Success():
return success(_that.ticket);case _Error():
return error(_that.ticket,_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( Map<String, dynamic> ticket)?  initial,TResult? Function( Map<String, dynamic> ticket)?  loading,TResult? Function( Map<String, dynamic> ticket)?  success,TResult? Function( Map<String, dynamic> ticket,  String message)?  error,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that.ticket);case _Loading() when loading != null:
return loading(_that.ticket);case _Success() when success != null:
return success(_that.ticket);case _Error() when error != null:
return error(_that.ticket,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements TicketDetailsState {
  const _Initial(final  Map<String, dynamic> ticket): _ticket = ticket;
  

 final  Map<String, dynamic> _ticket;
@override Map<String, dynamic> get ticket {
  if (_ticket is EqualUnmodifiableMapView) return _ticket;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_ticket);
}


/// Create a copy of TicketDetailsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InitialCopyWith<_Initial> get copyWith => __$InitialCopyWithImpl<_Initial>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial&&const DeepCollectionEquality().equals(other._ticket, _ticket));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_ticket));

@override
String toString() {
  return 'TicketDetailsState.initial(ticket: $ticket)';
}


}

/// @nodoc
abstract mixin class _$InitialCopyWith<$Res> implements $TicketDetailsStateCopyWith<$Res> {
  factory _$InitialCopyWith(_Initial value, $Res Function(_Initial) _then) = __$InitialCopyWithImpl;
@override @useResult
$Res call({
 Map<String, dynamic> ticket
});




}
/// @nodoc
class __$InitialCopyWithImpl<$Res>
    implements _$InitialCopyWith<$Res> {
  __$InitialCopyWithImpl(this._self, this._then);

  final _Initial _self;
  final $Res Function(_Initial) _then;

/// Create a copy of TicketDetailsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ticket = null,}) {
  return _then(_Initial(
null == ticket ? _self._ticket : ticket // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

/// @nodoc


class _Loading implements TicketDetailsState {
  const _Loading(final  Map<String, dynamic> ticket): _ticket = ticket;
  

 final  Map<String, dynamic> _ticket;
@override Map<String, dynamic> get ticket {
  if (_ticket is EqualUnmodifiableMapView) return _ticket;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_ticket);
}


/// Create a copy of TicketDetailsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoadingCopyWith<_Loading> get copyWith => __$LoadingCopyWithImpl<_Loading>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loading&&const DeepCollectionEquality().equals(other._ticket, _ticket));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_ticket));

@override
String toString() {
  return 'TicketDetailsState.loading(ticket: $ticket)';
}


}

/// @nodoc
abstract mixin class _$LoadingCopyWith<$Res> implements $TicketDetailsStateCopyWith<$Res> {
  factory _$LoadingCopyWith(_Loading value, $Res Function(_Loading) _then) = __$LoadingCopyWithImpl;
@override @useResult
$Res call({
 Map<String, dynamic> ticket
});




}
/// @nodoc
class __$LoadingCopyWithImpl<$Res>
    implements _$LoadingCopyWith<$Res> {
  __$LoadingCopyWithImpl(this._self, this._then);

  final _Loading _self;
  final $Res Function(_Loading) _then;

/// Create a copy of TicketDetailsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ticket = null,}) {
  return _then(_Loading(
null == ticket ? _self._ticket : ticket // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

/// @nodoc


class _Success implements TicketDetailsState {
  const _Success(final  Map<String, dynamic> ticket): _ticket = ticket;
  

 final  Map<String, dynamic> _ticket;
@override Map<String, dynamic> get ticket {
  if (_ticket is EqualUnmodifiableMapView) return _ticket;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_ticket);
}


/// Create a copy of TicketDetailsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SuccessCopyWith<_Success> get copyWith => __$SuccessCopyWithImpl<_Success>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Success&&const DeepCollectionEquality().equals(other._ticket, _ticket));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_ticket));

@override
String toString() {
  return 'TicketDetailsState.success(ticket: $ticket)';
}


}

/// @nodoc
abstract mixin class _$SuccessCopyWith<$Res> implements $TicketDetailsStateCopyWith<$Res> {
  factory _$SuccessCopyWith(_Success value, $Res Function(_Success) _then) = __$SuccessCopyWithImpl;
@override @useResult
$Res call({
 Map<String, dynamic> ticket
});




}
/// @nodoc
class __$SuccessCopyWithImpl<$Res>
    implements _$SuccessCopyWith<$Res> {
  __$SuccessCopyWithImpl(this._self, this._then);

  final _Success _self;
  final $Res Function(_Success) _then;

/// Create a copy of TicketDetailsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ticket = null,}) {
  return _then(_Success(
null == ticket ? _self._ticket : ticket // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

/// @nodoc


class _Error implements TicketDetailsState {
  const _Error(final  Map<String, dynamic> ticket, this.message): _ticket = ticket;
  

 final  Map<String, dynamic> _ticket;
@override Map<String, dynamic> get ticket {
  if (_ticket is EqualUnmodifiableMapView) return _ticket;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_ticket);
}

 final  String message;

/// Create a copy of TicketDetailsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ErrorCopyWith<_Error> get copyWith => __$ErrorCopyWithImpl<_Error>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Error&&const DeepCollectionEquality().equals(other._ticket, _ticket)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_ticket),message);

@override
String toString() {
  return 'TicketDetailsState.error(ticket: $ticket, message: $message)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res> implements $TicketDetailsStateCopyWith<$Res> {
  factory _$ErrorCopyWith(_Error value, $Res Function(_Error) _then) = __$ErrorCopyWithImpl;
@override @useResult
$Res call({
 Map<String, dynamic> ticket, String message
});




}
/// @nodoc
class __$ErrorCopyWithImpl<$Res>
    implements _$ErrorCopyWith<$Res> {
  __$ErrorCopyWithImpl(this._self, this._then);

  final _Error _self;
  final $Res Function(_Error) _then;

/// Create a copy of TicketDetailsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ticket = null,Object? message = null,}) {
  return _then(_Error(
null == ticket ? _self._ticket : ticket // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
