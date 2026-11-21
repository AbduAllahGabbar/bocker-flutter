import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/env/app_config.dart';
import '../../di/di_container.dart';

/// Downloading a remote file to the device and handing it to another app.
///
/// Android: files land in the app's external files directory
/// (`/Android/data/<id>/files/downloads`), which needs no storage permission
/// and is reachable from any file manager. `open_filex` ships the
/// `FileProvider` that shares them with the viewer app.
///
/// iOS: files land in the app's documents directory, which the Files app
/// lists (see `UIFileSharingEnabled` in `ios/Runner/Info.plist`), and are
/// handed over through `UIDocumentInteractionController`.
class FileDownloadService {
  FileDownloadService._();

  static final FileDownloadService instance = FileDownloadService._();

  static const String _folder = 'downloads';

  Dio get _dio => di<Dio>();

  /// Saves [url] under [fileName] and returns the local path.
  /// Throws a [FileDownloadException] when the file cannot be fetched.
  Future<String> download({
    required String url,
    String? fileName,
    void Function(int received, int total)? onProgress,
  }) async {
    final absolute = AppConfig.resolveUrl(url);
    if (absolute == null) {
      throw const FileDownloadException('This file has no valid address.');
    }

    final directory = await _downloadsDirectory();
    final name = safeFileName(fileName ?? _nameFromUrl(absolute));
    final path = '${directory.path}${Platform.pathSeparator}$name';

    try {
      await _dio.download(
        absolute,
        path,
        onReceiveProgress: onProgress,
        // The file lives behind the same API, so the session headers on the
        // shared Dio are what authorise the request.
        options: Options(responseType: ResponseType.stream),
      );
      return path;
    } catch (e) {
      // Never leave a half-written file behind.
      try {
        final partial = File(path);
        if (await partial.exists()) await partial.delete();
      } catch (_) {
        /* nothing actionable */
      }
      throw FileDownloadException(_messageFor(e));
    }
  }

  /// The already-downloaded copy of [fileName], or `null`.
  Future<String?> existingFile(String fileName) async {
    try {
      final directory = await _downloadsDirectory();
      final file = File(
        '${directory.path}${Platform.pathSeparator}${safeFileName(fileName)}',
      );
      return await file.exists() ? file.path : null;
    } catch (_) {
      return null;
    }
  }

  /// Hands a local file to whichever app on the device can display it.
  Future<OpenOutcome> openLocalFile(String path) async {
    try {
      final result = await OpenFilex.open(path);
      return switch (result.type) {
        ResultType.done => OpenOutcome.opened,
        ResultType.noAppToOpen => OpenOutcome.noApp,
        ResultType.fileNotFound => OpenOutcome.missing,
        _ => OpenOutcome.failed,
      };
    } catch (_) {
      return OpenOutcome.failed;
    }
  }

  /// Last resort when no installed app handles the file type.
  Future<bool> openInBrowser(String url) async {
    final absolute = AppConfig.resolveUrl(url);
    if (absolute == null) return false;
    final uri = Uri.tryParse(absolute);
    if (uri == null) return false;
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  /// Where the file is saved, and what to tell the user to look for.
  Future<String> downloadsLocationLabel() async {
    final directory = await _downloadsDirectory();
    return Platform.isAndroid ? directory.path : 'Files app';
  }

  Future<Directory> _downloadsDirectory() async {
    Directory base;
    if (Platform.isAndroid) {
      base =
          await getExternalStorageDirectory() ??
          await getApplicationDocumentsDirectory();
    } else {
      base = await getApplicationDocumentsDirectory();
    }

    final directory = Directory(
      '${base.path}${Platform.pathSeparator}$_folder',
    );
    if (!await directory.exists()) await directory.create(recursive: true);
    return directory;
  }

  /// Keeps the extension (viewers pick the app by it) and drops anything that
  /// could escape the downloads folder.
  static String safeFileName(String name) {
    final trimmed = name.trim().split(RegExp(r'[\/]')).last;
    final cleaned = trimmed
        .replaceAll(RegExp(r'[<>:"|?*\x00-\x1F]'), '_')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return cleaned.isEmpty ? 'download' : cleaned;
  }

  String _nameFromUrl(String url) {
    final path = Uri.tryParse(url)?.path ?? '';
    final last = path.split('/').where((s) => s.isNotEmpty).lastOrNull;
    return (last == null || last.isEmpty) ? 'download' : last;
  }

  String _messageFor(Object error) {
    if (error is DioException) {
      final status = error.response?.statusCode;
      if (status == 401 || status == 403) {
        return 'You are not allowed to download this file.';
      }
      if (status == 404) return 'This file is no longer available.';
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.connectionError) {
        return 'Download failed. Please check your internet.';
      }
    }
    return 'Download failed. Please try again.';
  }
}

enum OpenOutcome { opened, noApp, missing, failed }

class FileDownloadException implements Exception {
  final String message;

  const FileDownloadException(this.message);

  @override
  String toString() => message;
}
