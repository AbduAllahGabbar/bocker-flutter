import 'package:boker/core/packages/res_reline/my_responsive.dart';
import 'package:flutter/material.dart';

import '../../../../core/config/language/language_manager.dart';
import '../cubit/add_transaction_cubit.dart';
import '../cubit/add_transaction_state.dart';

/// Attachment picker for a manual deposit's proof of payment.
///
/// The picked file is uploaded through the shared upload service and the
/// resulting file object is sent in the transaction's `file` field.
class DepositProofField extends StatelessWidget {
  const DepositProofField({
    super.key,
    required this.state,
    required this.onPickFile,
    required this.onPickCamera,
    required this.onRemove,
  });

  final AddTransactionState state;
  final VoidCallback onPickFile;
  final VoidCallback onPickCamera;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        border: Border.all(
          color: state.attachmentStatus == AttachmentStatus.failure
              ? colorScheme.error
              : colorScheme.outlineVariant,
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          switch (state.attachmentStatus) {
            AttachmentStatus.uploading => _uploading(context),
            AttachmentStatus.ready => _ready(context),
            _ => _picker(context),
          },
          if (state.attachmentErrorMessage != null) ...[
            SizedBox(height: 10.h),
            Text(
              state.attachmentErrorMessage!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.error,
              ),
            ),
          ],
          SizedBox(height: 10.h),
          Text(
            '${'Accepted'.tran}: '
            '${AddTransactionCubit.allowedAttachmentExtensions.join(', ')} '
            '· ${'Max'.tran} '
            '${AddTransactionCubit.maxAttachmentBytes ~/ (1024 * 1024)} MB',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _picker(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onPickFile,
            icon: const Icon(Icons.attach_file),
            label: Text('Choose file'.tran),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onPickCamera,
            icon: const Icon(Icons.photo_camera_outlined),
            label: Text('Camera'.tran),
          ),
        ),
      ],
    );
  }

  Widget _uploading(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              height: 18.r,
              width: 18.r,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                '${'Uploading'.tran} ${state.attachmentName ?? ''}',
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: const LinearProgressIndicator(minHeight: 4),
        ),
      ],
    );
  }

  Widget _ready(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(Icons.check_circle, color: Colors.green, size: 22.r),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.attachmentName ?? 'Receipt attached'.tran,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Uploaded'.tran,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Replace'.tran,
          icon: const Icon(Icons.swap_horiz),
          onPressed: onPickFile,
        ),
        IconButton(
          tooltip: 'Remove'.tran,
          icon: Icon(Icons.delete_outline, color: colorScheme.error),
          onPressed: onRemove,
        ),
      ],
    );
  }
}
