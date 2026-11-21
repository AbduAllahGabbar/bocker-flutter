import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:boker/core/services/upload_files_services/upload_files_services.dart';
import '../../../data/repositories/tickets_repository.dart';
import 'ticket_details_state.dart';

class TicketDetailsCubit extends Cubit<TicketDetailsState> {
  final TicketsRepository _repository;
  late Map<String, dynamic> _ticket;

  TicketDetailsCubit(this._repository, Map<String, dynamic> initialTicket)
    : super(TicketDetailsState.initial(initialTicket)) {
    _ticket = Map<String, dynamic>.from(initialTicket);
    fetchTicketDetails();
  }

  Future<void> fetchTicketDetails() async {
    try {
      emit(TicketDetailsState.loading(_ticket));
      final ticketId = int.parse(_ticket['id'].toString());
      final fullTicket = await _repository.viewTicket(ticketId);
      _ticket = Map<String, dynamic>.from(fullTicket);
      emit(TicketDetailsState.success(_ticket));
    } catch (e) {
      emit(
        TicketDetailsState.error(
          _ticket,
          _describe(e, "Failed to load ticket details"),
        ),
      );
      emit(TicketDetailsState.success(_ticket)); // revert back to old data UI
    }
  }

  Future<void> replyToTicket({
    required String desc,
    String? filePath,
    bool isImage = false,
  }) async {
    emit(TicketDetailsState.loading(_ticket));
    try {
      final ticketId = int.parse(_ticket['id'].toString());

      Map<String, dynamic> payload = {"id": ticketId, "desc": desc};

      if (filePath != null) {
        final uploadResult = isImage
            ? await UploadFilesServices.uploadImage(filePath)
            : await UploadFilesServices.uploadFile(filePath);

        uploadResult.fold(
          (failure) {
            emit(
              TicketDetailsState.error(
                _ticket,
                "Upload failed: ${failure.message}",
              ),
            );
          },
          (fileData) {
            payload["file"] = fileData;
          },
        );

        if (state.maybeWhen(error: (_, _) => true, orElse: () => false)) return;
      }

      await _repository.replyTicket(payload);

      // Re-read the ticket so the thread shows the reply exactly as the
      // backend stored it, instead of a locally fabricated entry.
      await fetchTicketDetails();
    } catch (e) {
      emit(
        TicketDetailsState.error(_ticket, _describe(e, "Failed to send reply")),
      );
      emit(TicketDetailsState.success(_ticket));

      // The reply may have been refused because the ticket was closed while
      // the page was open: re-read it so the thread and the composer match
      // the ticket's real state.
      if (_looksClosed(e)) unawaited(fetchTicketDetails());
    }
  }

  /// The backend's own wording when it sent one, without the `Exception: `
  /// wrapper Dart adds.
  String _describe(Object error, String fallback) {
    var text = error.toString().trim();
    if (text.startsWith('Exception:')) {
      text = text.substring('Exception:'.length).trim();
    }
    return text.isEmpty ? fallback : text;
  }

  bool _looksClosed(Object error) =>
      error.toString().toLowerCase().contains('closed');
}
