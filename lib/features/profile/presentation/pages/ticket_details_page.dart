import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../core/config/language/language_manager.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:res_reline/my_responsive.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../../../core/di/di_container.dart';
import '../../data/repositories/tickets_repository.dart';
import '../cubit/ticket_details/ticket_details_cubit.dart';
import '../cubit/ticket_details/ticket_details_state.dart';

class TicketDetailsPage extends StatelessWidget {
  final Map<String, dynamic> ticket;

  const TicketDetailsPage({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          TicketDetailsCubit(TicketsRepository(dio: di<Dio>()), ticket),
      child: const _TicketDetailsView(),
    );
  }
}

class _TicketDetailsView extends StatefulWidget {
  const _TicketDetailsView();

  @override
  State<_TicketDetailsView> createState() => _TicketDetailsViewState();
}

class _TicketDetailsViewState extends State<_TicketDetailsView> {
  final TextEditingController _replyController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _selectedFilePath;
  bool _isImage = false;

  @override
  void dispose() {
    _replyController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return DateFormat('MMMM dd, yyyy').format(date);
    } catch (e) {
      return '';
    }
  }

  String _formatTime(String dateStr) {
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return DateFormat('hh:mm a').format(date);
    } catch (e) {
      return '';
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _pickAttachment() async {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.image),
                title: Text('Pick Image'.tran.tran),
                onTap: () async {
                  Navigator.pop(ctx);
                  final picker = ImagePicker();
                  final pickedFile = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (pickedFile != null) {
                    setState(() {
                      _selectedFilePath = pickedFile.path;
                      _isImage = true;
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.insert_drive_file),
                title: Text('Pick Document'.tran.tran),
                onTap: () async {
                  Navigator.pop(ctx);
                  final result = await FilePicker.pickFiles();
                  if (result.isNotEmpty && result.first.path != null) {
                    setState(() {
                      _selectedFilePath = result.first.path;
                      _isImage = false;
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _sendReply(BuildContext context) {
    if (_replyController.text.trim().isEmpty && _selectedFilePath == null)
      return;

    context.read<TicketDetailsCubit>().replyToTicket(
      desc: _replyController.text.trim(),
      filePath: _selectedFilePath,
      isImage: _isImage,
    );

    _replyController.clear();
    setState(() {
      _selectedFilePath = null;
    });
    _scrollToBottom();
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
        title: BlocBuilder<TicketDetailsCubit, TicketDetailsState>(
          builder: (context, state) {
            final ticket = state.ticket;
            final code = ticket['code']?.toString() ?? '';
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ticket Details'.tran,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 18.s,
                  ),
                ),
                Text(
                  code.startsWith('#') ? code : '#$code',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w400,
                    fontSize: 12.s,
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).primaryColor,
              size: 24.s,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocConsumer<TicketDetailsCubit, TicketDetailsState>(
        listener: (context, state) {
          state.maybeWhen(
            error: (_, msg) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(msg)));
            },
            success: (_) {
              _scrollToBottom();
            },
            orElse: () {},
          );
        },
        builder: (context, state) {
          final ticket = state.ticket;
          return Column(
            children: [
              _buildHeaderCard(ticket),
              Expanded(child: _buildChatList(ticket)),
              _buildInputArea(
                context,
                state.maybeWhen(loading: (_) => true, orElse: () => false),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(Map<String, dynamic> ticket) {
    final categoryName = ticket['category']?['name']?.toString() ?? 'SUPPORT';
    final title = ticket['title']?.toString() ?? 'Ticket';
    final status = ticket['status']?.toString().toLowerCase() ?? 'open';
    final dateStr = ticket['date']?.toString() ?? '';
    final formattedDate = _formatDate(dateStr);
    final isOpen = status == 'open';

    return Container(
      margin: EdgeInsets.all(16.s),
      padding: EdgeInsets.all(16.s),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.s),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.s, vertical: 4.s),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F4EA),
                  borderRadius: BorderRadius.circular(12.s),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.money,
                      size: 12.s,
                      color: Theme.of(context).primaryColor,
                    ),
                    SizedBox(width: 4.s),
                    Text(
                      categoryName,
                      style: TextStyle(
                        fontSize: 12.s,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.s),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.s, vertical: 4.s),
                decoration: BoxDecoration(
                  color: isOpen
                      ? const Color(0xFFFFF3CD)
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12.s),
                ),
                child: Row(
                  children: [
                    Icon(
                      isOpen
                          ? Icons.radio_button_unchecked
                          : Icons.check_circle_outline,
                      size: 12.s,
                      color: isOpen
                          ? Theme.of(context).colorScheme.secondary
                          : Colors.grey.shade600,
                    ),
                    SizedBox(width: 4.s),
                    Text(
                      isOpen ? 'Open'.tran : 'Closed'.tran,
                      style: TextStyle(
                        fontSize: 12.s,
                        fontWeight: FontWeight.w600,
                        color: isOpen
                            ? Theme.of(context).colorScheme.secondary
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.s),
          Text(
            title,
            style: TextStyle(
              fontSize: 18.s,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
          SizedBox(height: 8.s),
          Text(
            'Created on $formattedDate',
            style: TextStyle(fontSize: 13.s, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList(Map<String, dynamic> ticket) {
    final desc = ticket['desc']?.toString() ?? '';
    final dateStr = ticket['date']?.toString() ?? '';
    final replies = List<dynamic>.from(ticket['replyList'] ?? []);

    return ListView(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 16.s),
      children: [
        // System Greeting mock if there are no replies yet to match design
        _buildAgentMessage(
          "Hello! We've received your request. Our support team is currently reviewing it. We appreciate your patience as we investigate this further.",
          dateStr,
        ),
        // Original ticket description (from user)
        if (desc.isNotEmpty) _buildUserMessage(desc, null, dateStr),
        // Actual replies
        ...replies.map((reply) {
          final isUser =
              reply['user'] == null ||
              reply['user']['id'] == ticket['user']?['id'] ||
              reply['user']['name'] == 'Me';
          final text = reply['desc']?.toString() ?? '';
          final date = reply['date']?.toString() ?? '';
          final file = reply['file'];
          if (isUser) {
            return _buildUserMessage(text, file, date);
          } else {
            return _buildAgentMessage(text, date);
          }
        }).toList(),
        SizedBox(height: 20.s),
      ],
    );
  }

  Widget _buildAgentMessage(String text, String dateStr) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12.s,
                backgroundColor: const Color(0xFFFDE68A),
                child: Icon(
                  Icons.support_agent,
                  size: 14.s,
                  color: const Color(0xFFB45309),
                ),
              ),
              SizedBox(width: 8.s),
              Text(
                'BrokerPro Support'.tran,
                style: TextStyle(
                  fontSize: 12.s,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF4B5563),
                ),
              ),
              Text(
                '  •  2 hours ago', // Mock time like UI
                style: TextStyle(fontSize: 11.s, color: Colors.grey.shade500),
              ),
            ],
          ),
          SizedBox(height: 8.s),
          Container(
            padding: EdgeInsets.all(16.s),
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(
                16.s,
              ).copyWith(topLeft: const Radius.circular(4)),
            ),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.s,
                color: const Color(0xFF374151),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserMessage(String text, dynamic fileMap, String dateStr) {
    final companyName = "My Company";
    return Padding(
      padding: EdgeInsets.only(bottom: 24.s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'منذ 38 ثانية  •  $companyName', // Mock time like UI
                style: TextStyle(fontSize: 11.s, color: Colors.grey.shade500),
              ),
              SizedBox(width: 8.s),
              CircleAvatar(
                radius: 12.s,
                backgroundColor: Theme.of(context).primaryColor,
                child: Icon(Icons.person, size: 14.s, color: Colors.white),
              ),
            ],
          ),
          SizedBox(height: 8.s),
          Container(
            padding: EdgeInsets.all(16.s),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(
                16.s,
              ).copyWith(topRight: const Radius.circular(4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (text.isNotEmpty)
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 14.s,
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                if (fileMap != null) ...[
                  if (text.isNotEmpty) SizedBox(height: 12.s),
                  _buildAttachmentBubble(fileMap),
                ],
              ],
            ),
          ),
          SizedBox(height: 4.s),
          Text(
            _formatDate(dateStr),
            style: TextStyle(fontSize: 10.s, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentBubble(dynamic fileMap) {
    final name = fileMap['name']?.toString() ?? 'Attachment';
    final url = fileMap['url']?.toString();
    final path = fileMap['path']?.toString();

    return Container(
      width: 240.s,
      height: 140.s,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.s),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.s),
              child: url != null
                  ? Image.network(
                      'https://boker.egytag.com$url',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.broken_image, color: Colors.white),
                    )
                  : (path != null
                        ? Image.file(File(path), fit: BoxFit.cover)
                        : const Icon(
                            Icons.insert_drive_file,
                            color: Colors.white,
                          )),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.s, vertical: 8.s),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.9),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12.s),
                  bottomRight: Radius.circular(12.s),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(color: Colors.white, fontSize: 11.s),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.download, color: Colors.white, size: 16.s),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(BuildContext context, bool isLoading) {
    return Container(
      padding: EdgeInsets.only(
        left: 16.s,
        right: 16.s,
        top: 12.s,
        bottom: 24.s,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_selectedFilePath != null)
            Padding(
              padding: EdgeInsets.only(bottom: 8.s),
              child: Chip(
                label: Text(
                  _selectedFilePath!.split(Platform.pathSeparator).last,
                  style: TextStyle(fontSize: 12.s),
                ),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  setState(() {
                    _selectedFilePath = null;
                  });
                },
              ),
            ),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.attach_file,
                  color: Theme.of(context).primaryColor,
                  size: 24.s,
                ),
                onPressed: isLoading ? null : _pickAttachment,
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(24.s),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextField(
                    controller: _replyController,
                    decoration: InputDecoration(
                      hintText: 'Type your reply...'.tran,
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14.s,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.s),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: isLoading
                      ? SizedBox(
                          width: 20.s,
                          height: 20.s,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(Icons.send, color: Colors.white, size: 20.s),
                  onPressed: isLoading ? null : () => _sendReply(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
