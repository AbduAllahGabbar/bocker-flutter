import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:boker/core/services/upload_files_services/upload_files_services.dart';
import '../../../data/repositories/tickets_repository.dart';
import 'tickets_state.dart';

class TicketsCubit extends Cubit<TicketsState> {
  final TicketsRepository _repository;

  TicketsCubit(this._repository) : super(const TicketsState.initial());

  Future<void> fetchTickets(bool isOpen) async {
    emit(const TicketsState.loading());
    try {
      final status = isOpen ? 'open' : 'closed';
      final tickets = await _repository.fetchTickets(status);
      emit(TicketsState.success(tickets));
    } catch (e) {
      emit(TicketsState.error(e.toString()));
    }
  }

  Future<void> createTicket({
    required Map<String, dynamic> category,
    required String title,
    required String desc,
    String? filePath,
    bool isImage = false,
  }) async {
    emit(const TicketsState.createLoading());
    try {
      Map<String, dynamic> payload = {
        "category": category,
        "title": title,
        "desc": desc,
      };

      if (filePath != null) {
        final uploadResult = isImage
            ? await UploadFilesServices.uploadImage(filePath)
            : await UploadFilesServices.uploadFile(filePath);

        uploadResult.fold(
          (failure) {
            emit(TicketsState.createError("Upload failed: ${failure.message}"));
          },
          (fileData) {
            payload["file"] = fileData;
          },
        );

        if (state.maybeWhen(createError: (_) => true, orElse: () => false)) return;
      }

      await _repository.addTicket(payload);
      emit(const TicketsState.createSuccess());
    } catch (e) {
      emit(TicketsState.createError("Failed to create ticket: ${e.toString()}"));
    }
  }
}
