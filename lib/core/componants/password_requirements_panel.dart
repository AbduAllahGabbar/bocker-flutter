import 'package:flutter/material.dart';

import '../packages/res_reline/my_responsive.dart';
import '../config/language/language_manager.dart';
import '../utils/password_policy.dart';

/// Live checklist of the backend's password rules.
///
/// Shown under every field that accepts a new password so the requirements are
/// visible before the user submits.
class PasswordRequirementsPanel extends StatelessWidget {
  const PasswordRequirementsPanel({
    super.key,
    required this.password,
    this.visible = true,
  });

  final String password;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    final requirements = PasswordPolicy.requirements(password);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.s, vertical: 12.s),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFFF3CD11).withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'The password must contain:'.tran,
            style: TextStyle(
              color: const Color(0xFFB8860B),
              fontWeight: FontWeight.w700,
              fontSize: 12.s,
            ),
          ),
          SizedBox(height: 8.s),
          ...requirements.map(
            (requirement) => Padding(
              padding: EdgeInsets.only(bottom: 6.s),
              child: Row(
                children: [
                  Icon(
                    requirement.isMet
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    size: 14.r,
                    color: requirement.isMet
                        ? Colors.green
                        : const Color(0xFFB8860B).withValues(alpha: 0.5),
                  ),
                  SizedBox(width: 8.s),
                  Expanded(
                    child: Text(
                      requirement.label,
                      style: TextStyle(
                        fontSize: 12.s,
                        color: requirement.isMet
                            ? Colors.green.shade800
                            : const Color(0xFF8D6E00),
                        fontWeight: requirement.isMet
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
