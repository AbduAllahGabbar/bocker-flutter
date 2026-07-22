part of 'failure.dart';

class ErrorHandler {
  static void _myStackTrace(dynamic error, [StackTrace? stackTrace]) {
    stackTrace ??= StackTrace.current;
    print("My Stack Trace:\n"
        "╔══════════════════════════════════════════════════════════════════════════════════════════╗\n"
        "$error\n"
        "$stackTrace"
        "\n╚══════════════════════════════════════════════════════════════════════════════════════════╝");
  }

  static Failure handle(dynamic error,
      [StackTrace? stackTrace, String? Function(dynamic e)? parsMessage]) {
    if (kDebugMode) {
      Future.delayed(Duration(seconds: 1)).then((value) =>
      throw Error.throwWithStackTrace(error, stackTrace ?? StackTrace.current),);
      return InternalFailure(
        message: parsMessage?.call(error) ?? (kDebugMode
            ? error.toString()
            : 'Un expected error, please try again.'),
      );
    }
    print("Error Type  ==>>>>${error.runtimeType}");
    return InternalFailure(
      message: parsMessage?.call(error) ?? (kDebugMode
          ? error.toString()
          : 'Un expected error, please try again.'),
    );
  }

}

