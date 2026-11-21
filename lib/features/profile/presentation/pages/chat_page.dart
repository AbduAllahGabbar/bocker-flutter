import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../core/config/env/app_config.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:boker/core/packages/res_reline/my_responsive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/language/language_manager.dart';
import '../../../../core/di/di_container.dart';
import '../../data/repositories/chat_repository.dart';
import '../../data/models/message_model.dart';
import '../../data/models/outgoing_message.dart';
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
                  success: (_, _) => Future.delayed(
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
                  success: (messages, pending) {
                    if (messages.isEmpty && pending.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.s),
                          child: Text(
                            'No messages yet. Send a message to start the conversation.'
                                .tran,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ),
                      );
                    }

                    // Real date separators, derived from each message's own
                    // timestamp (the previous hardcoded "TODAY" pill labelled
                    // every conversation as if it happened today).
                    final entries = _buildEntries(messages, pending);

                    return ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.all(16.s),
                      itemCount: entries.length,
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        return switch (entry) {
                          _DateSeparator(:final label) => _buildDatePill(label),
                          _SentEntry(:final message) => _buildMessageBubble(
                            message,
                            message.type == 'user',
                          ),
                          _PendingEntry(:final message) => _buildPendingBubble(
                            message,
                          ),
                        };
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

  /// Groups the conversation into date separators, delivered messages and
  /// messages still waiting to be sent.
  List<_ChatEntry> _buildEntries(
    List<MessageModel> messages,
    List<OutgoingMessage> pending,
  ) {
    final entries = <_ChatEntry>[];
    DateTime? lastDay;

    for (final message in messages) {
      final date = message.date == null
          ? null
          : DateTime.tryParse(message.date!)?.toLocal();
      if (date != null) {
        final day = DateTime(date.year, date.month, date.day);
        if (lastDay == null || day != lastDay) {
          entries.add(_DateSeparator(_dayLabel(day)));
          lastDay = day;
        }
      }
      entries.add(_SentEntry(message));
    }

    for (final message in pending) {
      entries.add(_PendingEntry(message));
    }

    return entries;
  }

  String _dayLabel(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final difference = today.difference(day).inDays;

    if (difference == 0) return 'TODAY'.tran;
    if (difference == 1) return 'YESTERDAY'.tran;
    return DateFormat('MMMM d, yyyy').format(day);
  }

  Widget _buildDatePill(String label) {
    return Center(
      child: Container(
        margin: EdgeInsets.only(bottom: 24.s),
        padding: EdgeInsets.symmetric(horizontal: 16.s, vertical: 6.s),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16.s),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.s,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  /// A message that failed to send, with retry / discard actions.
  Widget _buildPendingBubble(OutgoingMessage message) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final failed = message.errorMessage != null;

    return Padding(
      padding: EdgeInsets.only(bottom: 24.s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: EdgeInsets.all(16.s),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: failed ? 0.45 : 0.7),
              borderRadius: BorderRadius.circular(
                16.s,
              ).copyWith(bottomRight: const Radius.circular(0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!message.isText) ...[
                  Icon(
                    message.isImage ? Icons.image : Icons.insert_drive_file,
                    color: Colors.white,
                    size: 18.s,
                  ),
                  SizedBox(width: 8.s),
                ],
                Flexible(
                  child: Text(
                    message.displayLabel,
                    style: TextStyle(fontSize: 14.s, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 6.s),
          if (message.isSending)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 12.s,
                  width: 12.s,
                  child: const CircularProgressIndicator(strokeWidth: 1.5),
                ),
                SizedBox(width: 6.s),
                Text(
                  'Sending...'.tran,
                  style: TextStyle(fontSize: 11.s, color: Colors.grey.shade600),
                ),
              ],
            )
          else if (failed)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Not sent'.tran,
                  style: TextStyle(fontSize: 11.s, color: colorScheme.error),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () => context.read<ChatCubit>().retry(message),
                      child: Text('Retry'.tran),
                    ),
                    TextButton(
                      onPressed: () =>
                          context.read<ChatCubit>().discard(message),
                      child: Text(
                        'Discard'.tran,
                        style: TextStyle(color: colorScheme.error),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
                  AppConfig.resolveUrl(url)!,
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

/// One row in the chat list.
sealed class _ChatEntry {
  const _ChatEntry();
}

class _DateSeparator extends _ChatEntry {
  final String label;

  const _DateSeparator(this.label);
}

class _SentEntry extends _ChatEntry {
  final MessageModel message;

  const _SentEntry(this.message);
}

class _PendingEntry extends _ChatEntry {
  final OutgoingMessage message;

  const _PendingEntry(this.message);
}
