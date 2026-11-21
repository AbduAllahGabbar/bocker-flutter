import 'package:boker/core/packages/res_reline/my_responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/routes/routes_manager.dart';
import '../../../../core/di/di_container.dart';
import '../../../notifications/data/models/notification_model.dart';
import '../../../notifications/presentation/cubit/notification_counters_cubit.dart';

/// Notification bell with a live unread badge.
///
/// The count comes from `POST /api/notifications/summary` and is kept current
/// by the `activity/stream` SSE connection while the app is in the foreground.
class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<NotificationCountersCubit, NotificationSummary>(
      bloc: DI.initNotificationCounters(),
      builder: (context, summary) {
        final unread = summary.unreadNotifications;

        return InkWell(
          onTap: () => context.pushNamed(RoutesNames.notifications),
          customBorder: const CircleBorder(),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(8.r),
                child: Icon(
                  unread > 0
                      ? Icons.notifications_active
                      : Icons.notifications_none,
                  color: colorScheme.onSurface,
                ),
              ),
              if (unread > 0)
                PositionedDirectional(
                  top: -2,
                  end: -2,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: unread > 9 ? 5.r : 0,
                    ),
                    constraints: BoxConstraints(minWidth: 18.r),
                    height: 18.r,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colorScheme.error,
                      shape: unread > 9 ? BoxShape.rectangle : BoxShape.circle,
                      borderRadius: unread > 9
                          ? BorderRadius.circular(9.r)
                          : null,
                      border: Border.all(
                        color: colorScheme.surface,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      unread > 99 ? '99+' : '$unread',
                      style: TextStyle(
                        color: colorScheme.onError,
                        fontSize: 10.s,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
