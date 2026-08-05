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
      emit(TicketDetailsState.error(_ticket, "Failed to load ticket details: ${e.toString()}"));
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

      Map<String, dynamic> payload = {
        "id": ticketId,
        "desc": desc,
      };

      Map<String, dynamic>? uploadedFileMap;

      if (filePath != null) {
        final uploadResult = isImage
            ? await UploadFilesServices.uploadImage(filePath)
            : await UploadFilesServices.uploadFile(filePath);

        uploadResult.fold(
          (failure) {
            emit(TicketDetailsState.error(_ticket, "Upload failed: ${failure.message}"));
          },
          (fileData) {
            uploadedFileMap = fileData;
            payload["file"] = fileData;
          },
        );

        if (state.maybeWhen(error: (_, __) => true, orElse: () => false)) return;
      }

      await _repository.replyTicket(payload);

      // Optimistically update the ticket
      final replies = List<dynamic>.from(_ticket['replyList'] ?? []);
      replies.add({
        "desc": desc,
        "date": DateTime.now().toIso8601String(),
        "user": {"name": "Me"}, // simple mock for UI
        if (uploadedFileMap != null) "file": uploadedFileMap,
      });
      _ticket['replyList'] = replies;
      _ticket['isReplied'] = true;

      emit(TicketDetailsState.success(_ticket));
    } catch (e) {
      emit(TicketDetailsState.error(_ticket, "Failed to send reply: ${e.toString()}"));
      emit(TicketDetailsState.success(_ticket));
    }
  }
}
