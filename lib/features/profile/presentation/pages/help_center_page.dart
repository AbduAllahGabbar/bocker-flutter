import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:res_reline/my_responsive.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/language/language_manager.dart';
import '../../../../core/config/routes/routes_manager.dart';
import '../../../../core/di/di_container.dart';
import '../../data/repositories/tickets_repository.dart';
import '../cubit/tickets/tickets_cubit.dart';
import '../cubit/tickets/tickets_state.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TicketsCubit(TicketsRepository(
        dio: di<Dio>(),
      ))..fetchTickets(true),
      child: const _HelpCenterView(),
    );
  }
}

class _HelpCenterView extends StatefulWidget {
  const _HelpCenterView();

  @override
  State<_HelpCenterView> createState() => _HelpCenterViewState();
}

class _HelpCenterViewState extends State<_HelpCenterView> {
  bool _isOpenTab = true;

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr).toLocal();
      final now = DateTime.now();
      
      final datePart = (date.year == now.year && date.month == now.month && date.day == now.day)
          ? 'Today'
          : DateFormat('MMM dd, yyyy').format(date);
          
      final timePart = DateFormat('hh:mm a').format(date);
      
      return '$datePart • $timePart';
    } catch (e) {
      return 'Unknown';
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
          icon: Icon(Icons.arrow_back, color: Theme.of(context).primaryColor),
          onPressed: context.pop,
        ),
        title: Text(
          'Help Center'.tran,
          style: TextStyle(
            color: const Color(0xFF1F2937),
            fontWeight: FontWeight.w500,
            fontSize: 20.s,
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 16.s),
          Center(
            child: Container(
              height: 48.s,
              margin: EdgeInsets.symmetric(horizontal: 16.s),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24.s),
              ),
              padding: EdgeInsets.all(4.s),
              child: Row(
                children: [
                  Expanded(child: _buildTab('Open Tickets'.tran, true)),
                  Expanded(child: _buildTab('Closed Tickets'.tran, false)),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.s),
          Expanded(
            child: BlocBuilder<TicketsCubit, TicketsState>(
              builder: (context, state) {
                return state.maybeWhen(
                  initial: () => Center(child: CircularProgressIndicator()),
                  loading: () => Center(child: CircularProgressIndicator()),
                  error: (message) => Center(child: Text(message, style: TextStyle(color: Colors.red))),
                  success: (tickets) {
                    if (tickets.isEmpty) {
                      return Center(
                        child: Text(
                          'No ${_isOpenTab ? "open" : "closed"} tickets.',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<TicketsCubit>().fetchTickets(_isOpenTab);
                      },
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        padding: EdgeInsets.symmetric(horizontal: 16.s, vertical: 8.s).copyWith(bottom: 80.s),
                        itemCount: tickets.length,
                        separatorBuilder: (context, index) => SizedBox(height: 16.s),
                        itemBuilder: (context, index) {
                          final item = tickets[index] as Map<String, dynamic>;
                          return _buildTicketCard(item);
                        },
                      ),
                    );
                  },
                  orElse: () => const SizedBox.shrink(),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await context.pushNamed(RoutesNames.createTicket);
          if (result == true && mounted) {
            context.read<TicketsCubit>().fetchTickets(_isOpenTab);
          }
        },
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 2,
        child: Icon(Icons.add, color: Colors.white, size: 28.s),
      ),
    );
  }

  Widget _buildTab(String label, bool isForOpenTab) {
    final isSelected = _isOpenTab == isForOpenTab;
    return GestureDetector(
      onTap: () {
        if (_isOpenTab != isForOpenTab) {
          setState(() {
            _isOpenTab = isForOpenTab;
          });
          context.read<TicketsCubit>().fetchTickets(isForOpenTab);
        }
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20.s),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.s,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? const Color(0xFF1F2937) : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildTicketCard(Map<String, dynamic> item) {
    final categoryName = item['category']?['name']?.toString() ?? 'SUPPORT';
    final title = item['title']?.toString() ?? 'Ticket';
    final code = item['code']?.toString() ?? 'TK-0000';
    final status = item['status']?.toString().toLowerCase() ?? 'open';
    final dateStr = item['date']?.toString() ?? '';
    final formattedDate = _formatDate(dateStr);
    final isReplied = item['isReplied'] == true;
    final repliesCount = isReplied ? 1 : 0; // Using a dummy count based on isReplied as per plan

    final isOpen = status == 'open';
    final ticketId = item['id'] as int?;

    return GestureDetector(
      onTap: () {
        context.pushNamed(RoutesNames.ticketDetails, extra: item);
      },
      child: Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                categoryName.toUpperCase(),
                style: TextStyle(
                  fontSize: 11.s,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.s, vertical: 4.s),
                decoration: BoxDecoration(
                  color: isOpen ? const Color(0xFFE6F4EA) : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12.s),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isOpen ? Icons.radio_button_unchecked : Icons.check_circle_outline,
                      size: 12.s,
                      color: isOpen ? Theme.of(context).primaryColor : Colors.grey.shade600,
                    ),
                    SizedBox(width: 4.s),
                    Text(
                      isOpen ? 'Open'.tran : 'Closed',
                      style: TextStyle(
                        fontSize: 12.s,
                        fontWeight: FontWeight.w600,
                        color: isOpen ? Theme.of(context).primaryColor : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8.s),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15.s,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1F2937),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.s),
                    Text(
                      code.startsWith('#') ? code : '#$code',
                      style: TextStyle(
                        fontSize: 12.s,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.s),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.s, vertical: 4.s),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8.s),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.chat_bubble_outline, size: 14.s, color: Colors.grey.shade700),
                    SizedBox(width: 6.s),
                    Text(
                      repliesCount.toString(),
                      style: TextStyle(
                        fontSize: 12.s,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.s),
          Divider(color: Colors.grey.shade100, height: 1),
          SizedBox(height: 12.s),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Updated $formattedDate',
                style: TextStyle(
                  fontSize: 11.s,
                  color: Colors.grey.shade600,
                ),
              ),
              if (isOpen && ticketId != null)
                _CloseTicketButton(
                  ticketId: ticketId,
                  onClosed: () {
                    context.read<TicketsCubit>().fetchTickets(_isOpenTab);
                  },
                )
              else
                Icon(Icons.chevron_right, size: 20.s, color: Colors.grey.shade400),
            ],
          ),
        ],
      ),
    ));
  }
}

class _CloseTicketButton extends StatefulWidget {
  final int ticketId;
  final VoidCallback onClosed;

  const _CloseTicketButton({required this.ticketId, required this.onClosed});

  @override
  State<_CloseTicketButton> createState() => _CloseTicketButtonState();
}

class _CloseTicketButtonState extends State<_CloseTicketButton> {
  bool _isLoading = false;

  Future<void> _handleClose() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) =>
          AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: const Text(
                'Close Ticket', style: TextStyle(fontWeight: FontWeight.w600)),
            content: const Text(
                'Are you sure you want to close this ticket? This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(
                    'Cancel', style: TextStyle(color: Colors.grey.shade600)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: const Text('Close Ticket'),
              ),
            ],
          ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isLoading = true);

    final success = await context.read<TicketsCubit>().closeTicket(
        widget.ticketId);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Ticket closed successfully'),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
      widget.onClosed();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to close ticket. Please try again.'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.red.shade400,
        ),
      );
    }
    return GestureDetector(
      onTap: _handleClose,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.close_rounded, size: 13, color: Colors.red.shade500),
            const SizedBox(width: 4),
            Text(
              'Close Ticket',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.red.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }


}