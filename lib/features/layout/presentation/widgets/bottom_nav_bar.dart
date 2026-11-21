import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:boker/core/packages/res_reline/my_responsive.dart';
import '../../../../core/config/language/language_manager.dart';
import '../../../../core/di/di_container.dart';
import '../../../../features/auth/data/repository/user_access.dart';
import '../../../../features/notifications/data/models/notification_model.dart';
import '../../../../features/notifications/presentation/cubit/notification_counters_cubit.dart';

/// Dark navy color matching the UI design

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color activeColor;

  final Color inActiveColor;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.activeColor = const Color(0xff22409A),
    this.inActiveColor = const Color(0xff14265C),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      margin: EdgeInsets.fromLTRB(
        8.h,
        0,
        8.h,
        bottomPadding > 0 ? bottomPadding : 16.h,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(28.h),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 4.h, vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: 'Home'.tran,
            isSelected: currentIndex == 0,
            onTap: () => onTap(0),
            activeColor: activeColor,
          ),

          _NavItem(
            icon: Icons.account_balance_wallet_outlined,
            activeIcon: Icons.account_balance_wallet,
            label: 'Accounts'.tran,
            isSelected: currentIndex == 1,
            onTap: () => onTap(1),
            activeColor: activeColor,
          ),

          // Unread support messages live under My Account, so the tab carries
          // their badge. The count comes from the same counters cubit the
          // bell and the drawer use - no extra stream, no second counter.
          BlocBuilder<NotificationCountersCubit, NotificationSummary>(
            bloc: DI.initNotificationCounters(),
            builder: (context, summary) => _NavItem(
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
              label: 'My Account'.tran,
              isSelected: currentIndex == 2,
              onTap: () => onTap(2),
              activeColor: activeColor,
              badgeCount: summary.unreadMessages,
            ),
          ),
          if (UserAccess.user?.isIb == true)
            _NavItem(
              icon: Icons.dashboard_outlined,
              activeIcon: Icons.dashboard_rounded,
              label: 'Dashboard'.tran,
              isSelected: currentIndex == 3,
              onTap: () => onTap(3),
              activeColor: activeColor,
            ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color activeColor;

  /// Unread items shown as a badge over the icon; 0 hides it.
  final int badgeCount;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.activeColor,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inActiveColor = isDark
        ? const Color(0xff14265C)
        : const Color(0xff22409A);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64.h,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: Icon(
                    isSelected ? activeIcon : icon,
                    key: ValueKey(isSelected),
                    color: isSelected ? activeColor : inActiveColor,
                    size: 24.h,
                  ),
                ),
                if (badgeCount > 0)
                  PositionedDirectional(
                    top: -4,
                    end: -6,
                    child: _NavBadge(count: badgeCount),
                  ),
              ],
            ),
            SizedBox(height: 4.h),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: isSelected ? activeColor : inActiveColor,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 10.h,
              ),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The small red counter drawn over a nav icon.
class _NavBadge extends StatelessWidget {
  const _NavBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isWide = count > 9;
    final label = count > 99 ? '99+' : '$count';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isWide ? 4.r : 0),
      constraints: BoxConstraints(minWidth: 16.r),
      height: 16.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colorScheme.error,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E1E1E)
              : Colors.white,
          width: 1.5,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colorScheme.onError,
          fontSize: 9.s,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}
