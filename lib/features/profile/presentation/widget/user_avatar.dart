import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/cubit/auth_cubit.dart';
import '../../../auth/cubit/auth_state.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final user = state.mapOrNull(authenticated: (value) => value.user);
        final displayName = user == null
            ? null
            : (user.fullName?.trim().isNotEmpty ?? false)
            ? user.fullName!.trim()
            : (user.fullName ?? '').trim().isNotEmpty
            ? (user.fullName ?? '').trim()
            : null;
        final initial = user == null
            ? 'G'
            : ((displayName?.isNotEmpty ?? false)
                  ? displayName!.substring(0, 1).toUpperCase()
                  : user.email.isNotEmpty
                  ? user.email.substring(0, 1).toUpperCase()
                  : 'G');

        return CircleAvatar(
          radius: 18,
          backgroundColor: Colors.orangeAccent,
          backgroundImage: (user?.avatarUrl?.isNotEmpty ?? false)
              ? NetworkImage(user!.avatarUrl!)
              : null,
          child: (user?.avatarUrl?.isNotEmpty ?? false)
              ? null
              : Text(
                  initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        );
      },
    );
  }
}
