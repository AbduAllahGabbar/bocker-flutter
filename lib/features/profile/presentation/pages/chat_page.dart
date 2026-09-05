import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:res_reline/my_responsive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/language/language_manager.dart';
import '../../../../core/di/di_container.dart';
import '../../data/repositories/chat_repository.dart';
import '../../data/models/message_model.dart';
import '../cubit/chat/chat_cubit.dart';
import '../cubit/chat/chat_state.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ChatCubit(ChatRepository(dio: di<Dio>()))..fetchMessages(),
      child: const _ChatView(),
    );
  }
}

class _ChatView extends StatefulWidget {
  const _ChatView();

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && mounted) {
      context.read<ChatCubit>().sendFileMessage(pickedFile.path, isImage: true);
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles();
    if (result.isNotEmpty && result.first.path != null && mounted) {
      context.read<ChatCubit>().sendFileMessage(
        result.first.path!,
        isImage: false,
      );
    }
  }

  String _formatMessageTime(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return DateFormat('hh:mm a').format(date);
    } catch (e) {
      return '';
    }
  }

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
          'Support'.tran,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 18.s,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<ChatCubit, ChatState>(
              listener: (context, state) {
                state.maybeWhen(
                  success: (_) => Future.delayed(
                    const Duration(milliseconds: 100),
                    _scrollToBottom,
                  ),
                  error: (msg) => ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(msg))),
                  orElse: () {},
                );
              },
              builder: (context, state) {
                return state.maybeWhen(
                  initial: () => Center(child: CircularProgressIndicator()),
                  loading: () => Center(child: CircularProgressIndicator()),
                  success: (messages) {
                    return ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.all(16.s),
                      itemCount: messages.length + 1, // +1 for the TODAY pill
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Center(
                            child: Container(
                              margin: EdgeInsets.only(bottom: 24.s),
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.s,
                                vertical: 6.s,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(16.s),
                              ),
                              child: Text(
                                'TODAY',
                                style: TextStyle(
                                  fontSize: 11.s,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          );
                        }

                        final msg = messages[index - 1];
                        final isUser = msg.type == 'user';

                        return _buildMessageBubble(msg, isUser);
                      },
                    );
                  },
                  orElse: () => const SizedBox.shrink(),
                );
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel msg, bool isUser) {
    final messageType = msg.messageType;
    final dateStr = msg.date;
    final timeStr = _formatMessageTime(dateStr);

    Widget contentWidget;

    if (messageType == MessageType.text) {
      contentWidget = Text(
        msg.textContent ?? '',
        style: TextStyle(
          fontSize: 14.s,
          color: isUser ? Colors.white : const Color(0xFF1F2937),
        ),
      );
    } else if (messageType == MessageType.image) {
      final url = msg.fileContent?.url;
      contentWidget = url != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8.s),
              child: Container(
                color: Colors.white,
                child: Image.network(
                  'https://boker.egytag.com$url',
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.image_not_supported_outlined,
                    size: 150.s,
                    color: Colors.grey,
                  ),

                  fit: BoxFit.cover,
                  height: 150.s,
                ),
              ),
            )
          : Icon(Icons.image, size: 50, color: Colors.grey);
    } else {
      // file
      final fileName = msg.fileContent?.name ?? 'File attachment';
      contentWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.insert_drive_file,
            color: isUser ? Colors.white : Theme.of(context).primaryColor,
          ),
          SizedBox(width: 8.s),
          Flexible(
            child: Text(
              fileName,
              style: TextStyle(
                color: isUser ? Colors.white : const Color(0xFF1F2937),
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 24.s),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16.s,
              backgroundColor: Theme.of(context).primaryColor,
              child: Icon(Icons.support_agent, size: 20.s, color: Colors.white),
            ),
            SizedBox(width: 12.s),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(16.s),
                  decoration: BoxDecoration(
                    color: isUser
                        ? Theme.of(context).primaryColor
                        : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.s),
                      topRight: Radius.circular(16.s),
                      bottomLeft: Radius.circular(isUser ? 16.s : 0),
                      bottomRight: Radius.circular(isUser ? 0 : 16.s),
                    ),
                    border: isUser
                        ? null
                        : Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: contentWidget,
                ),
                SizedBox(height: 6.s),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      timeStr,
                      style: TextStyle(
                        fontSize: 11.s,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (isUser) ...[
                      SizedBox(width: 4.s),
                      Icon(
                        Icons.done_all,
                        size: 14.s,
                        color: Theme.of(context).primaryColor,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (isUser) SizedBox(width: 28.s),
          // To balance the avatar width on the left
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.s, vertical: 12.s),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.add_circle_outline,
                color: const Color(0xFF1F2937),
                size: 28.s,
              ),
              onPressed: _pickFile,
            ),
            IconButton(
              icon: Icon(
                Icons.image_outlined,
                color: const Color(0xFF1F2937),
                size: 28.s,
              ),
              onPressed: _pickImage,
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(24.s),
                ),
                child: TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14.s,
                    ),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (text) {
                    if (text.isNotEmpty) {
                      context.read<ChatCubit>().sendTextMessage(text);
                      _textController.clear();
                    }
                  },
                ),
              ),
            ),
            SizedBox(width: 12.s),
            GestureDetector(
              onTap: () {
                final text = _textController.text;
                if (text.isNotEmpty) {
                  context.read<ChatCubit>().sendTextMessage(text);
                  _textController.clear();
                }
              },
              child: Container(
                padding: EdgeInsets.all(12.s),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.send, color: Colors.white, size: 20.s),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
