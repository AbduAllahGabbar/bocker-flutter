import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
export 'package:dartz/dartz.dart';

part 'error_handler.dart';

typedef Result<T> = Either<Failure, T>;

abstract class ResultX{

  static Future<Either<Failure, R>> tryCatch<R>(
    Future<dynamic> Function() action, {
    String? Function(dynamic e)? onError,
  })
  async {
    try {
      final result = await action();
      if (result is R) {
        return Right(result);
      }
      if (result is Failure) {
        return result.left();
      }
      if(result is String) {
        return Left(Failure.internal(result));
      }
      if(result is Either<Failure, R>) {
        return result;
      }

      return Left(Failure.internal(result));
    } catch (e, stack) {
      return ErrorHandler.handle(e, stack, onError).left();
    }
  }

 static void handleResult<R>(
      Either<Failure, R> result, {
        required void Function(R r) onSuccess,
        required void Function(Failure l) onFailure,
      }) {
    result.fold(onFailure, onSuccess);
  }
}
class Failure {
  final String message;

  final int? code;

  const Failure({required this.message, this.code});

  factory Failure.internal(String message, {int? code}) =>
      InternalFailure(message: message, code: code);

  factory Failure.server(String message, {int? code}) =>
      ServerFailure(message: message, code: code);

  Left<Failure, R> serverLeft<R>(String message, {int? code}) =>
      ServerFailure(message: message, code: code).left();

  Left<Failure, R> left<R>() => Left(this);

  Left<Failure, R> internalFailure<R>(String message, {int? code}) =>
      InternalFailure(message: message, code: code).left();


}

class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code});

  factory ServerFailure.fromJson(Map<String, dynamic> json, int? code) {
    if (json.containsKey('keyPattern')) {
      return ServerFailure.fromDuplicatedError(json, code);
    } else if (json.containsKey("errors")) {
      return ServerFailure.fromMissedRequiredFiled(json, code);
    }
    return ServerFailure(message: json.toString(), code: code);
  }

  factory ServerFailure.fromDuplicatedError(
    Map<String, dynamic> json,
    int? code,
  ) {
    String duplicatedField = _findDuplicatedField(json);
    return ServerFailure(
      message: '$duplicatedField Already exists',
      code: code,
    );
  }

  static String _findDuplicatedField(Map<String, dynamic> json) {
    Map<String, dynamic> keyPattern = json["keyPattern"];
    if (keyPattern.isNotEmpty) {
      return keyPattern.keys.first;
    }
    return "no-mention-field";
  }

  factory ServerFailure.fromMissedRequiredFiled(
    Map<String, dynamic> json,
    int? code,
  ) {
    String message = extractFirstErrorMessage(json);
    return ServerFailure(message: message, code: code);
  }

  static String extractFirstErrorKey(Map<String, dynamic> jsonMap) {
    if (jsonMap.containsKey("errors") &&
        jsonMap["errors"] is Map<String, dynamic>) {
      final errors = jsonMap["errors"] as Map<String, dynamic>;
      if (errors.isNotEmpty) {
        return errors.keys.first;
      }
    }
    return "no-mention-field";
  }

  static String extractFirstErrorMessage(Map<String, dynamic> jsonMap) {
    if (jsonMap.containsKey("errors") &&
        jsonMap["errors"] is Map<String, dynamic>) {
      final errors = jsonMap["errors"] as Map<String, dynamic>;
      if (errors.isNotEmpty) {
        final firstError = errors.values.first;
        if (firstError is Map<String, dynamic> &&
            firstError.containsKey("message")) {
          return firstError["message"] as String;
        }
      }
    }
    return "حدث خطأ غير معروف.";
  }

  static Map<String, String> extractAllErrorMessages(
    Map<String, dynamic> jsonMap,
  ) {
    final Map<String, String> result = {};
    if (jsonMap.containsKey("errors") &&
        jsonMap["errors"] is Map<String, dynamic>) {
      final errors = jsonMap["errors"] as Map<String, dynamic>;
      errors.forEach((key, value) {
        if (value is Map<String, dynamic> && value.containsKey("message")) {
          result[key] = value["message"] as String;
        }
      });
    }
    return result;
  }
}

class InternalFailure extends Failure {
  InternalFailure({required super.message, super.code});
}
extension EitherX<L, R> on Either<L, R>{
  R? get right => fold((l) => null, (r) => r);
  L? get left => fold((l) => l, (r) => null);
}