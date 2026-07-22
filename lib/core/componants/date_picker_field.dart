import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'my_from_field.dart';

class DatePickerField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;

  const DatePickerField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.prefixIcon = Icons.calendar_today_outlined,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
        ],
        MyTextFormField(
          controller: controller,
          hintText: hintText,
          prefixIcon: prefixIcon,
          validator: validator,
          readOnly: true,
          fillColor: colorScheme.surface,
          onTap: () async {
            final initialDate = controller.text.isNotEmpty
                ? _parseDate(controller.text) ?? DateTime.now()
                : DateTime.now();
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: initialDate,
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (pickedDate != null) {
              final formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
              controller.text = formattedDate;
            }
          },
        ),
      ],
    );
  }

  DateTime? _parseDate(String dateStr) {
    try {
      return DateFormat('yyyy-MM-dd').parse(dateStr);
    } catch (_) {
      return null;
    }
  }
}
