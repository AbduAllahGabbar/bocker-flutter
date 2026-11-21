import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:boker/core/packages/res_reline/my_responsive.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/language/language_manager.dart';
import '../../../../core/di/di_container.dart';
import '../../../../core/services/files/file_download_service.dart';
import '../../data/repositories/agreements_repository.dart';
import '../cubit/agreements/agreements_cubit.dart';
import '../cubit/agreements/agreements_state.dart';

class AgreementsPage extends StatelessWidget {
  const AgreementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AgreementsCubit(AgreementsRepository(di<Dio>()))..fetchAgreements(),
      child: const _AgreementsView(),
    );
  }
}

class _AgreementsView extends StatelessWidget {
  const _AgreementsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: context.pop,
        ),
        centerTitle: true,
        title: Text(
          'Agreements'.tran,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 18.s,
          ),
        ),
      ),
      body: BlocBuilder<AgreementsCubit, AgreementsState>(
        builder: (context, state) {
          return state.when(
            initial: () => Center(child: CircularProgressIndicator()),
            loading: () => Center(child: CircularProgressIndicator()),
            error: (message) => Center(
              child: Text(message, style: TextStyle(color: Colors.red)),
            ),
            success: (agreements) {
              if (agreements.isEmpty) {
                return Center(child: Text('No agreements found.'.tran));
              }
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<AgreementsCubit>().fetchAgreements();
                },
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.s,
                    vertical: 8.s,
                  ),
                  itemCount: agreements.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12.s),
                  itemBuilder: (context, index) {
                    final item = agreements[index] as Map<String, dynamic>;
                    return _AgreementCard(agreement: item);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// One agreement: download it to the device, or hand it to the viewer app.
class _AgreementCard extends StatefulWidget {
  const _AgreementCard({required this.agreement});

  final Map<String, dynamic> agreement;

  @override
  State<_AgreementCard> createState() => _AgreementCardState();
}

class _AgreementCardState extends State<_AgreementCard> {
  final FileDownloadService _files = FileDownloadService.instance;

  /// null = idle, otherwise 0..1, or -1 for a download of unknown length.
  double? _progress;
  bool _opening = false;

  bool get _busy => _progress != null || _opening;

  Map<String, dynamic>? get _file =>
      widget.agreement['file'] as Map<String, dynamic>?;

  String? get _fileUrl {
    final url = _file?['url']?.toString().trim();
    return (url == null || url.isEmpty) ? null : url;
  }

  String get _name => widget.agreement['name']?.toString() ?? 'Agreement';

  /// The name the file is saved under: the backend's own, falling back to the
  /// agreement's title plus the extension from the url.
  String get _downloadName {
    final original = _file?['name']?.toString().trim();
    if (original != null && original.isNotEmpty) return original;

    final path = Uri.tryParse(_fileUrl ?? '')?.path ?? '';
    final dot = path.lastIndexOf('.');
    final extension = dot == -1 ? '' : path.substring(dot);
    return '$_name$extension';
  }

  String _formatSize(int bytes) {
    if (bytes <= 0) return '';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(String dateStr) {
    try {
      return DateFormat('MMM yyyy').format(DateTime.parse(dateStr));
    } catch (e) {
      return 'Unknown';
    }
  }

  void _notify(String message, {SnackBarAction? action}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          action: action,
        ),
      );
  }

  /// Fetches the file unless it is already on the device.
  Future<String?> _ensureDownloaded({bool force = false}) async {
    final url = _fileUrl;
    if (url == null) {
      _notify('This agreement has no file attached.'.tran);
      return null;
    }

    if (!force) {
      final existing = await _files.existingFile(_downloadName);
      if (existing != null) return existing;
    }

    setState(() => _progress = -1);
    try {
      final path = await _files.download(
        url: url,
        fileName: _downloadName,
        onProgress: (received, total) {
          if (!mounted || total <= 0) return;
          setState(() => _progress = received / total);
        },
      );
      return path;
    } on FileDownloadException catch (e) {
      _notify(e.message.tran);
      return null;
    } finally {
      if (mounted) setState(() => _progress = null);
    }
  }

  Future<void> _onDownload() async {
    if (_busy) return;
    final path = await _ensureDownloaded(force: true);
    if (path == null || !mounted) return;

    final location = await _files.downloadsLocationLabel();
    _notify(
      '${'Saved to'.tran} $location',
      action: SnackBarAction(
        label: 'Open'.tran,
        onPressed: () => _openFile(path),
      ),
    );
  }

  Future<void> _onOpen() async {
    if (_busy) return;
    final path = await _ensureDownloaded();
    if (path == null) return;
    await _openFile(path);
  }

  Future<void> _openFile(String path) async {
    if (_opening) return;
    setState(() => _opening = true);
    try {
      final outcome = await _files.openLocalFile(path);
      if (!mounted) return;

      switch (outcome) {
        case OpenOutcome.opened:
          break;
        case OpenOutcome.noApp:
          // Nothing installed handles this type: let the browser try.
          final launched = await _files.openInBrowser(_fileUrl ?? '');
          if (!launched) {
            _notify('No app on this device can open this file.'.tran);
          }
        case OpenOutcome.missing:
          _notify('The downloaded file could not be found.'.tran);
        case OpenOutcome.failed:
          _notify('Could not open file'.tran);
      }
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final addUserInfo =
        widget.agreement['addUserInfo'] as Map<String, dynamic>?;
    final formattedDate = _formatDate(addUserInfo?['date']?.toString() ?? '');
    final formattedSize = _formatSize((_file?['size'] as num?)?.toInt() ?? 0);
    final subtitle = [
      '${'Last updated'.tran} $formattedDate',
      if (formattedSize.isNotEmpty) formattedSize,
    ].join(' • ');

    return Container(
      padding: EdgeInsets.all(16.s),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.s),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.s),
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(10.s),
            ),
            child: Icon(Icons.description, color: Colors.white, size: 24.s),
          ),
          SizedBox(width: 12.s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _name,
                  style: TextStyle(
                    fontSize: 14.s,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.s),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11.s, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.s),
          _buildDownloadButton(primary),
          SizedBox(width: 4.s),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _busy ? null : _onOpen,
              icon: Text(
                'Open'.tran,
                style: TextStyle(
                  fontSize: 12.s,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              label: _opening
                  ? SizedBox(
                      width: 14.s,
                      height: 14.s,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(Icons.open_in_new, size: 14.s, color: Colors.white),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: primary.withValues(alpha: 0.5),
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: 12.s, vertical: 8.s),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.s),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadButton(Color primary) {
    final progress = _progress;
    if (progress == null) {
      return IconButton(
        tooltip: 'Download'.tran,
        onPressed: _busy ? null : _onDownload,
        icon: Icon(Icons.download_outlined, color: primary, size: 22.s),
      );
    }

    return SizedBox(
      width: 40.s,
      height: 40.s,
      child: Center(
        child: SizedBox(
          width: 22.s,
          height: 22.s,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: primary,
            // A server that sends no content-length gives no percentage.
            value: progress < 0 ? null : progress,
          ),
        ),
      ),
    );
  }
}
