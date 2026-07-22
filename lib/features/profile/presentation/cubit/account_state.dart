import 'package:boker/features/auth/data/models/user_model.dart';

const Object _sentinel = Object();

class AccountState {
  final UserModel? user;
  final bool isSigningOut;

  const AccountState({
    required this.user,
    this.isSigningOut = false,
  });

  factory AccountState.initial(UserModel? user) {
    return AccountState(user: user);
  }

  AccountState copyWith({
    Object? user = _sentinel,
    bool? isSigningOut,
  }) {
    return AccountState(
      user: identical(user, _sentinel) ? this.user : user as UserModel?,
      isSigningOut: isSigningOut ?? this.isSigningOut,
    );
  }

  bool get isGuest => user == null;

  String get displayName {
    final currentUser = user;
    if (currentUser == null) {
      return 'Guest';
    }

    final fullName = currentUser.fullName?.trim();
    if (fullName != null && fullName.isNotEmpty) {
      return fullName;
    }


    final emailName = currentUser.email.split('@').first.trim();
    return emailName.isEmpty ? 'User' : emailName;
  }

  String get emailLabel =>
      user?.email ?? 'Sign in to view your orders and saved details';

  String get initials {
    final currentUser = user;
    if (currentUser == null) {
      return 'G';
    }

    final parts = displayName
        .split(' ')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .take(2)
        .toList();
    if (parts.isNotEmpty) {
      return parts.map((part) => part[0].toUpperCase()).join();
    }

    if (currentUser.email.isNotEmpty) {
      return currentUser.email[0].toUpperCase();
    }

    return 'U';
  }

  bool get showProBadge {
    final currentUser = user;
    if (currentUser == null) {
      return false;
    }
    return currentUser.hasAccount == true || currentUser.emailVerified;
  }

  int get voucherCount =>
      _readInt(['vouchers', 'voucher_count', 'vouchers_count']);

  String get walletBalanceLabel {
    final balance = _readNum([
      'wallet_balance',
      'talabat_pay_balance',
      'balance',
    ]);
    return 'AED ${balance.toStringAsFixed(2)}';
  }

  String get rewardPointsLabel {
    final points = _readNum(['reward_points', 'points', 'rewards_points']);
    if (points >= 1000) {
      return '${(points / 1000).toStringAsFixed(1)}k pts';
    }
    return '${points.toStringAsFixed(points.truncateToDouble() == points ? 0 : 1)} pts';
  }

  String? get addressCountLabel {
    final count = user?.addresses?.length ?? 0;
    if (count == 0) {
      return null;
    }
    return '$count saved';
  }

  int _readInt(List<String> keys) {
    final rawValue = _readMetadataValue(keys);
    if (rawValue is int) {
      return rawValue;
    }
    if (rawValue is num) {
      return rawValue.toInt();
    }
    if (rawValue is String) {
      return int.tryParse(rawValue) ?? 0;
    }
    return 0;
  }

  double _readNum(List<String> keys) {
    final rawValue = _readMetadataValue(keys);
    if (rawValue is num) {
      return rawValue.toDouble();
    }
    if (rawValue is String) {
      return double.tryParse(rawValue) ?? 0;
    }
    return 0;
  }

  Object? _readMetadataValue(List<String> keys) {
    final metadata = user?.metadata;
    if (metadata == null) {
      return null;
    }

    for (final key in keys) {
      if (metadata.containsKey(key)) {
        return metadata[key];
      }
    }

    return null;
  }
}
