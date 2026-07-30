import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:res_reline/my_responsive.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/config/language/language_manager.dart';
import '../../../../core/di/di_container.dart';
import '../../data/repositories/agreements_repository.dart';
import '../cubit/agreements/agreements_cubit.dart';
import '../cubit/agreements/agreements_state.dart';

class AgreementsPage extends StatelessWidget {
  const AgreementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AgreementsCubit(AgreementsRepository(di<Dio>()))..fetchAgreements(),
      child: const _AgreementsView(),
    );
  }
}

class _AgreementsView extends StatefulWidget {
  const _AgreementsView();

  @override
  State<_AgreementsView> createState() => _AgreementsViewState();
}

class _AgreementsViewState extends State<_AgreementsView> {
  int _selectedTabIndex = 0;

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM yyyy').format(date);
    } catch (e) {
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: context.pop,
        ),
        centerTitle: true,
        title: Text(
          'Agreements'.tran,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 18.s,
          ),
        ),
      ),
      body: BlocBuilder<AgreementsCubit, AgreementsState>(
        builder: (context, state) {
          return state.when(
            initial: () => Center(child: CircularProgressIndicator()),
            loading: () => Center(child: CircularProgressIndicator()),
            error: (message) => Center(
              child: Text(message, style: TextStyle(color: Colors.red)),
            ),
            success: (agreements) {
              if (agreements.isEmpty) {
                return Center(child: Text('No agreements found.'.tran));
              }
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<AgreementsCubit>().fetchAgreements();
                },
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.s,
                    vertical: 8.s,
                  ),
                  itemCount: agreements.length,
                  separatorBuilder: (context, index) =>
                      SizedBox(height: 12.s),
                  itemBuilder: (context, index) {
                    final item =
                        agreements[index] as Map<String, dynamic>;
                    return _buildAgreementCard(item);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }


  Widget _buildAgreementCard(Map<String, dynamic> item) {
    final name = item['name']?.toString() ?? 'Agreement';
    final addUserInfo = item['addUserInfo'] as Map<String, dynamic>?;
    final file = item['file'] as Map<String, dynamic>?;

    final dateStr = addUserInfo?['date']?.toString() ?? '';
    final formattedDate = _formatDate(dateStr);

    final size = file?['size'] as int? ?? 0;
    final formattedSize = _formatSize(size);

    final fileUrl = file?['url']?.toString();

    return Container(
      padding: EdgeInsets.all(16.s),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.s),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.s),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(10.s),
            ),
            child: Icon(Icons.description, color: Colors.white, size: 24.s),
          ),
          SizedBox(width: 12.s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14.s,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.s),
                Text(
                  'Last updated $formattedDate • $formattedSize',
                  style: TextStyle(fontSize: 11.s, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.s),
          IconButton(
            onPressed: () async {
              if (fileUrl != null) {
                final uri = Uri.parse('https://boker.egytag.com$fileUrl');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              }
            },
            icon: Icon(
              Icons.download_outlined,
              color: Theme.of(context).primaryColor,
              size: 22.s,
            ),
          ),
          SizedBox(width: 4.s),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () async {
                if (fileUrl != null) {
                  final uri = Uri.parse('https://boker.egytag.com$fileUrl');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Could not open file'.tran),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                }
              },
              icon: Text(
                'Open'.tran,
                style: TextStyle(
                  fontSize: 12.s,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              label: Icon(Icons.open_in_new, size: 14.s, color: Colors.white),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: 12.s, vertical: 8.s),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.s),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
