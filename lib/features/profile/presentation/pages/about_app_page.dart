import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:res_reline/my_responsive.dart';
import '../../../../core/config/language/language_manager.dart';
import '../../../../core/config/routes/routes_manager.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(
            Icons.arrow_back_rounded,
            color: Colors.black87,
            size: 24.r,
          ),
        ),
        title: Text(
          'About App'.tran,
          style: theme.textTheme.titleLarge?.copyWith(
            color: const Color(0xFF1B2651),
            fontWeight: FontWeight.w700,
            fontSize: 20.h,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 20.h),
        children: [
          _buildMenuCard(
            context: context,
            title: 'About Us'.tran,
            icon: Icons.info_outline_rounded,
            onTap: (){},
          ),
          _buildMenuCard(
            context: context,
            title: 'Contact Us'.tran,
            icon: Icons.contact_support_outlined,
            onTap: (){},          ),
          _buildMenuCard(
            context: context,
            title: 'Legal'.tran,
            icon: Icons.gavel_outlined,
            onTap: (){},          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200, width: 1.r),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 16.h),
          child: Row(
            children: [
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.black87,
                  size: 20.r,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                    fontSize: 16.h,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey.shade400,
                size: 20.r,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
