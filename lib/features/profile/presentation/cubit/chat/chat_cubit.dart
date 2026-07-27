import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../data/models/message_model.dart';
import 'package:boker/core/services/upload_files_services/upload_files_services.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _repository;

  ChatCubit(this._repository) : super(const ChatState.initial());

  List<MessageModel> _messages = [];

  Future<void> fetchMessages() async {
    emit(const ChatState.loading());
    try {
      _messages = await _repository.fetchMessages();
      emit(ChatState.success(_messages));
    } catch (e) {
      emit(ChatState.error(e.toString()));
    }
  }

  Future<void> sendTextMessage(String text) async {
    if (text.trim().isEmpty) return;
    
    // Optimistic UI update or just wait for response
    // For simplicity, wait for API
    try {
      final newMessage = await _repository.addMessage({
        "messageType": "text",
        "message": text,
      });
      _messages = List.from(_messages)..add(newMessage);
      emit(ChatState.success(_messages));
    } catch (e) {
      // Revert or show error
      emit(ChatState.error("Failed to send message: ${e.toString()}"));
      emit(ChatState.success(_messages));
    }
  }

  Future<void> sendFileMessage(String filePath, {required bool isImage}) async {
    try {
      final uploadResult = isImage 
          ? await UploadFilesServices.uploadImage(filePath)
          : await UploadFilesServices.uploadFile(filePath);
          
      uploadResult.fold(
        (failure) {
          emit(ChatState.error("Upload failed: ${failure.message}"));
          emit(ChatState.success(_messages));
        },
        (fileData) async {
          final newMessage = await _repository.addMessage({
            "messageType": isImage ? "image" : "file",
            "message": fileData,
          });
          _messages = List.from(_messages)..add(newMessage);
          emit(ChatState.success(_messages));
        }
      );
    } catch (e) {
      emit(ChatState.error("Failed to send file: ${e.toString()}"));
      emit(ChatState.success(_messages));
    }
  }
}
