import 'package:boker/features/auth/data/repository/user_access.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../core/config/language/language_manager.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:res_reline/my_responsive.dart';
import 'package:boker/core/config/routes/routes_manager.dart';
import 'package:boker/features/profile/data/models/document_model.dart';
import '../../../../core/di/di_container.dart';
import '../../data/repositories/verification_repository.dart';
import '../cubit/verification_status/verification_status_cubit.dart';
import '../cubit/verification_status/verification_status_state.dart';

class VerificationStatusPage extends StatelessWidget {
  const VerificationStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final userId = UserAccess.user?.id;
        return VerificationStatusCubit(VerificationRepository(
         di<Dio>(),
        ))..fetchVerificationStatus(userId);
      },
      child: const _VerificationStatusView(),
    );
  }
}

class _VerificationStatusView extends StatelessWidget {
  const _VerificationStatusView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon:  Icon(Icons.arrow_back),
          onPressed: context.pop,
        ),
        title: Text(
          'Verification Status'.tran,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 22.s,
          ),
        ),
        centerTitle: false,
      ),
      body: BlocBuilder<VerificationStatusCubit, VerificationStatusState>(
        builder: (context, state) {
          return state.when(
            initial: () => const Center(child: CircularProgressIndicator()),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (message) => Center(child: Text(message, style: TextStyle(color: Colors.red))),
            success: (identityForm, addressForm) {
              return RefreshIndicator(
                onRefresh: () async {
                  final userId = UserAccess.user?.id;
                  context.read<VerificationStatusCubit>().fetchVerificationStatus(userId);
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  padding: EdgeInsets.symmetric(horizontal: 16.s, vertical: 12.s),
                  children: [
                    _buildOverallStatusBanner(context),
                    SizedBox(height: 20.s),
                    _buildIdentityCard(context, identityForm),
                    SizedBox(height: 16.s),
                    _buildAddressCard(context, addressForm),
                    SizedBox(height: 24.s),
                    _buildFooterInfo(context),
                    SizedBox(height: MediaQuery.paddingOf(context).bottom + 16.s),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildOverallStatusBanner(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.s),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(16.s),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ACCOUNT STATUS',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 10.s,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 8.s),
                    Text(
                      'Identity Verified',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22.s,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6.s),
                    Text(
                      'Your identity documents are fully approved. You have full access to all trading features.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12.s,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.s),
              Container(
                padding: EdgeInsets.all(12.s),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.verified_user_outlined, color: Colors.white, size: 28.s),
              ),
            ],
          ),
          SizedBox(height: 24.s),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'VERIFICATION PROGRESS',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 10.s,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                '100%',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11.s,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.s),
          Container(
            height: 4.s,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF86E6AC),
              borderRadius: BorderRadius.circular(2.s),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentityCard(BuildContext context, IdentityDocumentModel form) {
    return Container(
      padding: EdgeInsets.all(20.s),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.s),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.s),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9F2ED),
                  borderRadius: BorderRadius.circular(8.s),
                ),
                child: Icon(Icons.badge_outlined, color: Theme.of(context).primaryColor, size: 24.s),
              ),
              SizedBox(width: 12.s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Identity Verification'.tran,
                      style: TextStyle(
                        fontSize: 15.s,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      'Last updated ${form.lastUpdateDate}',
                      style: TextStyle(fontSize: 12.s, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(context, form.status),
            ],
          ),
          SizedBox(height: 20.s),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildInfoItem('DOCUMENT TYPE', form.docType)),
              Expanded(child: _buildInfoItem('NATIONAL ID', form.docNumber)),
            ],
          ),
          SizedBox(height: 16.s),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildInfoItem('DOCUMENT NUMBER', form.docNumber)),
              Expanded(child: _buildInfoItem('ISSUING COUNTRY', form.country)),
            ],
          ),
          SizedBox(height: 20.s),
          Text(
            'ATTACHMENTS',
            style: TextStyle(fontSize: 10.s, color: Colors.grey.shade500, letterSpacing: 0.5),
          ),
          SizedBox(height: 12.s),
          Row(
            children: [
              _buildAttachmentBox(context, icon: Icons.image, label: 'Front side'),
              SizedBox(width: 12.s),
              _buildAttachmentBox(context, icon: Icons.picture_as_pdf, label: 'ID_SCAN_BACK.pdf'),
            ],
          ),
          SizedBox(height: 20.s),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final result = await context.pushNamed(RoutesNames.editIdentity, extra: form.originalJson);
                if (result == true && context.mounted) {
                  final userId = UserAccess.user?.id;
                  context.read<VerificationStatusCubit>().fetchVerificationStatus(userId);
                }
              },
              icon: Icon(Icons.edit_outlined, size: 16.s, color: Colors.grey.shade600),
              label: Text(
                'Edit Details',
                style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.s),
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.s)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context, AddressDocumentModel form) {
    return Container(
      padding: EdgeInsets.all(20.s),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.s),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.s),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(8.s),
                ),
                child: Icon(Icons.location_on_outlined, color: const Color(0xFFC2410C), size: 24.s),
              ),
              SizedBox(width: 12.s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Address Verification'.tran,
                      style: TextStyle(
                        fontSize: 15.s,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      'Last updated ${form.lastUpdateDate}',
                      style: TextStyle(fontSize: 12.s, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(context, form.status),
            ],
          ),
          SizedBox(height: 20.s),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildInfoItem('COUNTRY', form.country)),
              Expanded(child: _buildInfoItem('CITY', form.city)),
            ],
          ),
          SizedBox(height: 16.s),
          _buildInfoItem('ADDRESS', form.address),
          SizedBox(height: 16.s),
          _buildInfoItem('POSTAL CODE', form.postalCode),
          SizedBox(height: 20.s),
          Text(
            'ATTACHMENTS',
            style: TextStyle(fontSize: 10.s, color: Colors.grey.shade500, letterSpacing: 0.5),
          ),
          SizedBox(height: 12.s),
          Row(
            children: [
              _buildAttachmentBox(context, icon: Icons.description_outlined, label: 'Utility Bill'),
              SizedBox(width: 12.s),
              _buildAddAttachmentBox(),
            ],
          ),
          SizedBox(height: 20.s),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final result = await context.pushNamed(RoutesNames.editAddress, extra: form.originalJson);
                if (result == true && context.mounted) {
                  final userId = UserAccess.user?.id;
                  context.read<VerificationStatusCubit>().fetchVerificationStatus(userId);
                }
              },
              icon: Icon(Icons.edit_outlined, size: 16.s, color: Theme.of(context).primaryColor),
              label: Text(
                'Edit Address',
                style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.s),
                side: BorderSide(color: Theme.of(context).primaryColor),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.s)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 10.s, color: Colors.grey.shade500, letterSpacing: 0.5),
        ),
        SizedBox(height: 4.s),
        Text(
          value,
          style: TextStyle(fontSize: 13.s, color: const Color(0xFF1F2937), fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    final isVerified = status.toLowerCase() == 'verified' || status.toLowerCase() == 'approved';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.s, vertical: 4.s),
      decoration: BoxDecoration(
        color: isVerified ? const Color(0xFFDDF3E4) : const Color(0xFFFDE8D1),
        borderRadius: BorderRadius.circular(12.s),
      ),
      child: Row(
        children: [
          Icon(
            isVerified ? Icons.check_circle_outline : Icons.access_time,
            size: 12.s,
            color: isVerified ? Theme.of(context).primaryColor : const Color(0xFF8B5014),
          ),
          SizedBox(width: 4.s),
          Text(
            isVerified ? 'Verified'.tran : 'Pending'.tran,
            style: TextStyle(
              fontSize: 11.s,
              fontWeight: FontWeight.bold,
              color: isVerified ? Theme.of(context).primaryColor : const Color(0xFF8B5014),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentBox(BuildContext context, {required IconData icon, required String label}) {
    return Expanded(
      child: Container(
        height: 70.s,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8.s),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Theme.of(context).primaryColor, size: 24.s),
            SizedBox(height: 6.s),
            Text(
              label,
              style: TextStyle(fontSize: 10.s, color: Colors.grey.shade600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddAttachmentBox() {
    return Expanded(
      child: Container(
        height: 70.s,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8.s),
          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.none),
        ),
        child: CustomPaint(
          painter: _DottedBorderPainter(color: Colors.grey.shade400, radius: 8.s),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline, color: Colors.grey.shade400, size: 20.s),
              SizedBox(height: 6.s),
              Text(
                'Add',
                style: TextStyle(fontSize: 11.s, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterInfo(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.s),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12.s),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Theme.of(context).primaryColor, size: 20.s),
          SizedBox(width: 12.s),
          Expanded(
            child: Text(
              'Your verification data is encrypted using AES-256 standards. We never share your sensitive documents with third parties without your explicit consent.',
              style: TextStyle(
                fontSize: 11.s,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DottedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  _DottedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), Radius.circular(radius)));

    // A simple dashed path effect (could use path_drawing package for better dashed lines, but doing a manual approximate here or just drawing a solid light line)
    // For simplicity, we just draw solid here since standard flutter doesn't have dashed path built-in without packages.
    // The visual effect of very light grey solid border mimics a dotted one nicely enough if dotted isn't strictly required.
    // I'll draw a solid border here.
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
