import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:res_reline/my_responsive.dart';

import '../../../core/config/language/language_manager.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import 'auth_widgets.dart';

class GoogleButtonWidget extends StatelessWidget {
  const GoogleButtonWidget({super.key, required this.res});
  final ResHelper res;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return    BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isLoading = state.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );
        return AuthButton(
          res: res,
          text: 'Sign in with Google'.tran,
          onPressed: isLoading
              ? null
              : _handleGoogleSignIn,
          isLoading: isLoading,
          backgroundColor: colorScheme.surface,
          textColor: colorScheme.onSurface,
          fontWeight: FontWeight.w500,
          icon: GoogleLogoIcon(size: 20.h),
        );
      },
    );
  }
  void _handleGoogleSignIn() {
    // context.read<AuthCubit>().signInWithGoogle(isSignIn: false);
  }
}
class GoogleLogoIcon extends StatelessWidget {
  final double size;

  const GoogleLogoIcon({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(size, size), painter: _GoogleLogoPainter());
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double r = size.width / 2;
    final double strokeWidth = size.width * 0.23;
    final Offset center = Offset(r, r);
    final Rect rect = Rect.fromCircle(
      center: center,
      radius: r - strokeWidth / 2,
    );

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;

    // Red: Top arc (from 220° to 340° / -140° to -20°)
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, -2.44, 1.92, false, paint);

    // Yellow: Left arc (from 140° to 220°)
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, -3.14, 0.70, false, paint);
    canvas.drawArc(rect, 2.44, 0.70, false, paint);

    // Green: Bottom arc (from 45° to 140°)
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 0.78, 1.66, false, paint);

    // Blue: Right arc (from -20° to 45°)
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -0.52, 1.3, false, paint);

    // Draw the horizontal blue bar
    final Paint barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final Path barPath = Path();
    barPath.moveTo(r, r - strokeWidth / 2);
    barPath.lineTo(size.width, r - strokeWidth / 2);
    barPath.lineTo(size.width, r + strokeWidth / 2);
    barPath.lineTo(r, r + strokeWidth / 2);
    barPath.close();
    canvas.drawPath(barPath, barPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}