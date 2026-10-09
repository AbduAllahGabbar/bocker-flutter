import 'package:flutter/material.dart';
import 'package:res_reline/my_responsive.dart';
import 'package:flutter/services.dart';
import '../../data/models/payment_method_model.dart';

class PaymentDetailsWidget extends StatefulWidget {
  final PaymentMethodModel? paymentMethod;

  const PaymentDetailsWidget({super.key, required this.paymentMethod});

  @override
  State<PaymentDetailsWidget> createState() => _PaymentDetailsWidgetState();
}

class _PaymentDetailsWidgetState extends State<PaymentDetailsWidget> {
  int _selectedIndex = 0;

  @override
  void didUpdateWidget(PaymentDetailsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.paymentMethod?.code != widget.paymentMethod?.code) {
      _selectedIndex = 0;
    }
  }

  String _formatKey(String key) {
    // Convert camelCase to Title Case (e.g., walletAddress -> Wallet Address)
    final RegExp exp = RegExp(r'(?<=[a-z])[A-Z]');
    return key
        .replaceAllMapped(exp, (m) => ' ${m.group(0)}')
        .replaceFirstMapped(RegExp(r'^[a-z]'), (m) => m.group(0)!.toUpperCase());
  }

  @override
  Widget build(BuildContext context) {
    if (widget.paymentMethod == null || widget.paymentMethod!.list.isEmpty) {
      return const SizedBox.shrink();
    }

    final list = widget.paymentMethod!.list;
    final colorScheme = Theme.of(context).colorScheme;
    final detailIndex = _selectedIndex < list.length ? _selectedIndex : 0;
    final detail = list[detailIndex];
    
    // Filter out internal fields or empty values
    final validEntries = detail.entries.where((e) {
      if (e.key == 'paymentMethod' || e.key == 'id' || e.key == 'code' || e.key == 'date') return false;
      if (e.value == null || e.value.toString().trim().isEmpty) return false;
      return true;
    }).toList();
    
    if (validEntries.isEmpty && list.length <= 1) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(top: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Text(
              'PAYMENT DETAILS',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
            ),
          ),
          if (list.length > 1) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                border: Border.all(color: colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: detailIndex,
                  icon: Icon(Icons.keyboard_arrow_down, color: colorScheme.onSurfaceVariant),
                  items: List.generate(list.length, (index) {
                    final itemDetail = list[index];
                    String name = 'Option ${index + 1}';
                    if (itemDetail.containsKey('network')) {
                      name = itemDetail['network'].toString();
                    } else if (itemDetail.containsKey('bankName')) name = itemDetail['bankName'].toString();
                    else if (itemDetail.containsKey('apiName')) name = itemDetail['apiName'].toString();
                    else if (itemDetail.containsKey('currency')) name = itemDetail['currency'].toString();
                    
                    return DropdownMenuItem(
                      value: index,
                      child: Text(
                        name,
                        style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
                      ),
                    );
                  }),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedIndex = val);
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: 16.h),
          ],
          if (validEntries.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                border: Border.all(color: colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: validEntries.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    thickness: 1,
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                  itemBuilder: (context, index) {
                    final e = validEntries[index];
                    final valueString = e.value.toString();
                    return Padding(
                      padding: EdgeInsets.all(16.r),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.r),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(
                              Icons.info_outline,
                              size: 16.r,
                              color: colorScheme.primary,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _formatKey(e.key),
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  valueString,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.copy, size: 20.r, color: colorScheme.primary),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: valueString));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${_formatKey(e.key)} copied to clipboard')),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
