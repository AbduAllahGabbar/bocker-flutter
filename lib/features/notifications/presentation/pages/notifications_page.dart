import 'package:boker/core/packages/res_reline/my_responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/config/language/language_manager.dart';
import '../../data/models/notification_model.dart';
import '../cubit/notifications_cubit.dart';
import '../cubit/notifications_state.dart';
import '../notification_navigator.dart';

class NotificationsPageView extends StatefulWidget {
  const NotificationsPageView({super.key});

  @override
  State<NotificationsPageView> createState() => _NotificationsPageViewState();
}

class _NotificationsPageViewState extends State<NotificationsPageView> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<NotificationsCubit>().load();
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      context.read<NotificationsCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('Notifications'.tran),
        centerTitle: true,
        actions: [
          BlocBuilder<NotificationsCubit, NotificationsState>(
            builder: (context, state) {
              final cubit = context.read<NotificationsCubit>();
              return PopupMenuButton<String>(
                enabled: !state.isMutating,
                onSelected: (value) async {
                  switch (value) {
                    case 'mark-all':
                      await cubit.markAllAsRead();
                    case 'delete-all':
                      final confirmed = await _confirmDeleteAll(context);
                      if (confirmed) await cubit.deleteAll();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'mark-all',
                    enabled: state.unread > 0,
                    child: Text('Mark all as read'.tran),
                  ),
                  PopupMenuItem(
                    value: 'delete-all',
                    enabled: state.items.isNotEmpty,
                    child: Text('Delete all'.tran),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(theme),
          Expanded(
            child: BlocConsumer<NotificationsCubit, NotificationsState>(
              listenWhen: (previous, current) =>
                  current.errorMessage != null &&
                  previous.errorMessage != current.errorMessage,
              listener: (context, state) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
              },
              builder: (context, state) {
                if (state.status == NotificationsStatus.loading &&
                    state.items.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.status == NotificationsStatus.failure &&
                    state.items.isEmpty) {
                  return _buildError(state);
                }

                if (state.isEmpty) return _buildEmpty(state);

                return RefreshIndicator(
                  onRefresh: () =>
                      context.read<NotificationsCubit>().load(refresh: true),
                  child: ListView.separated(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: EdgeInsets.fromLTRB(16.s, 8.s, 16.s, 24.s),
                    itemCount:
                        state.items.length + (state.isLoadingMore ? 1 : 0),
                    separatorBuilder: (_, _) => SizedBox(height: 8.s),
                    itemBuilder: (context, index) {
                      if (index >= state.items.length) {
                        return Padding(
                          padding: EdgeInsets.all(16.s),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      return _NotificationTile(
                        notification: state.items[index],
                        onTap: () => _openNotification(state.items[index]),
                        onDelete: () => context
                            .read<NotificationsCubit>()
                            .deleteOne(state.items[index]),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.s, 12.s, 16.s, 4.s),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: context.read<NotificationsCubit>().search,
            decoration: InputDecoration(
              hintText: 'Search notifications'.tran,
              prefixIcon: const Icon(Icons.search),
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
          SizedBox(height: 8.s),
          BlocBuilder<NotificationsCubit, NotificationsState>(
            builder: (context, state) {
              return Row(
                children: [
                  FilterChip(
                    label: Text('Unread only'.tran),
                    selected: state.unreadOnly,
                    onSelected: context
                        .read<NotificationsCubit>()
                        .toggleUnreadOnly,
                  ),
                  const Spacer(),
                  if (state.unread > 0)
                    Text(
                      '${state.unread} ${'unread'.tran}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(NotificationsState state) {
    return LayoutBuilder(
      builder: (context, constraints) => RefreshIndicator(
        onRefresh: () => context.read<NotificationsCubit>().load(refresh: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: constraints.maxHeight * 0.25),
            Icon(
              Icons.notifications_none,
              size: 56.r,
              color: Theme.of(context).colorScheme.outline,
            ),
            SizedBox(height: 12.s),
            Center(
              child: Text(
                state.search.isNotEmpty || state.unreadOnly
                    ? 'No notifications match this filter'.tran
                    : 'You have no notifications yet'.tran,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(NotificationsState state) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.s),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              state.errorMessage ?? 'Something went wrong'.tran,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            SizedBox(height: 16.s),
            ElevatedButton(
              onPressed: () => context.read<NotificationsCubit>().load(),
              child: Text('Retry'.tran),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openNotification(NotificationModel notification) async {
    final cubit = context.read<NotificationsCubit>();
    // 1. Mark as read, 2. resolve + validate the destination, 3. navigate.
    await cubit.markAsRead(notification);
    if (!mounted) return;

    final navigated = await NotificationNavigator.navigate(
      context,
      notification,
    );
    if (!navigated && mounted && (notification.body?.isNotEmpty ?? false)) {
      // No safe destination - show the full text instead of going nowhere.
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(notification.title ?? 'Notification'.tran),
          content: Text(notification.body!),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'.tran),
            ),
          ],
        ),
      );
    }
  }

  Future<bool> _confirmDeleteAll(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete all notifications'.tran),
        content: Text(
          'All of your notifications will be permanently deleted. This cannot be undone.'
              .tran,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'.tran),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete all'.tran,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isUnread = !notification.seen;

    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: EdgeInsets.symmetric(horizontal: 20.s),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Icon(Icons.delete_outline, color: colorScheme.error),
      ),
      onDismissed: (_) => onDelete(),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          padding: EdgeInsets.all(14.s),
          decoration: BoxDecoration(
            color: isUnread
                ? colorScheme.primaryContainer.withValues(alpha: 0.25)
                : colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 8.r,
                height: 8.r,
                margin: EdgeInsetsDirectional.only(top: 6.s, end: 10.s),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isUnread ? colorScheme.primary : Colors.transparent,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (notification.title?.isNotEmpty ?? false)
                      Text(
                        notification.title!,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: isUnread
                              ? FontWeight.w800
                              : FontWeight.w600,
                        ),
                      ),
                    if (notification.body?.isNotEmpty ?? false) ...[
                      SizedBox(height: 4.s),
                      Text(
                        notification.body!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (notification.createdAt != null) ...[
                      SizedBox(height: 6.s),
                      Text(
                        DateFormat(
                          'MMM dd, yyyy  •  hh:mm a',
                        ).format(notification.createdAt!.toLocal()),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
