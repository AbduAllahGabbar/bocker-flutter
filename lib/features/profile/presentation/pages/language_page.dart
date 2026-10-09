import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jiffy/jiffy.dart';
import 'package:res_reline/my_responsive.dart';
import 'package:boker/features/app/app_cubit.dart';


import '../../../../core/componants/my_elevated_button.dart';
import '../../../../core/config/language/language_manager.dart';
import '../../../../core/di/di_container.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  LanguageType? _selectedLanguage;

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppCubit>().state;
    _selectedLanguage = LanguageType.fromValue(appState.languageCode);
  }

  void _applyChanges() {
    if (_selectedLanguage == null) return;
    
    context.setLocale(_selectedLanguage!.locale);
    Jiffy.setLocale(_selectedLanguage!.value);
    di<AppCubit>().changeLanguage(_selectedLanguage!);
    context.pop(true);

  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final res = MyRes.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: Colors.black87, size: 24.h),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Language'.tran,
          style: theme.textTheme.titleLarge?.copyWith(
            color: const Color(0xFF1D3A99),
            fontWeight: FontWeight.w700,
            fontSize: 20.h,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16.h),
              children: [
                _buildLanguageCard(
                  res: res,
                  theme: theme,
                  languageType: LanguageType.english,
                  title: 'English'.tran,
                  subtitle: 'English',
                ),
                SizedBox(height: 16.h),
                _buildLanguageCard(
                  res: res,
                  theme: theme,
                  languageType: LanguageType.arabic,
                  title: 'Arabic'.tran,
                  subtitle: 'العربية',
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.h),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              child: MyElevatedButton(
                res: res,
                label: 'Apply Changes'.tran,
                onPressed: _applyChanges,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageCard({
    required ResHelper res,
    required ThemeData theme,
    required LanguageType languageType,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedLanguage == languageType;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLanguage = languageType;
        });
      },
      child: Container(
        padding: EdgeInsets.all(16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.h),
          border: Border.all(
            color: isSelected ? const Color(0xFF1D3A99) : Colors.transparent,
            width: isSelected ? 1.5 : 0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 16.h,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade500,
                      fontSize: 14.h,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check,
                color: const Color(0xFF1D3A99),
                size: 24.h,
              ),
          ],
        ),
      ),
    );
  }
}
