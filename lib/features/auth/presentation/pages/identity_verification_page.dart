import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:res_reline/my_responsive.dart';

import '../../../../core/componants/async_dropdownmenu.dart';
import '../../../../core/componants/my_elevated_button.dart';
import '../../../../core/componants/toast.dart';
import '../../../../core/config/language/language_manager.dart';
import '../../../../core/config/routes/routes_manager.dart';
import '../../../../core/network/shared_services/country_api_services.dart';
import '../../cubit/auth_cubit.dart';
import '../../cubit/auth_state.dart';
import '../auth_widgets.dart';

class IdentityVerificationPage extends StatefulWidget {
  final String? email;
  final String? password;

  const IdentityVerificationPage({super.key, this.email, this.password});

  @override
  State<IdentityVerificationPage> createState() =>
      _IdentityVerificationPageState();
}

class _IdentityVerificationPageState extends State<IdentityVerificationPage> {
  bool? _hasExpirationDate;
  String? _documentType;
  final _documentNoController = TextEditingController();
  CountryModel? _selectedCountry;
  final CountryApiServices _countryServices = CountryApiServices();

  String? _frontSidePath;
  String? _backSidePath;
  String? _otherDocPath;

  CountryModel? _addressCountry;
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _postalCodeController = TextEditingController();
  String? _addressDocPath;

  @override
  void dispose() {
    _documentNoController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _pickFile({
    required Function(String path) onPicked,
    FileType type = FileType.any,
  }) async {
    try {
      final result = await FilePicker.pickFiles(
        type: type,
        allowMultiple: false,
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          onPicked(result.files.single.path!);
        });
      }
    } catch (e) {
      if (mounted) {
        ToastState.error.snackBar(context, 'Failed to pick file'.tran);
      }
    }
  }

  /// Shows a bottom-sheet letting the user choose between Camera and Gallery.
  Future<void> _pickImage({
    required Function(String path) onPicked,
  }) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _ImageSourceSheet(),
    );
    if (source == null) return;

    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: source,
        imageQuality: 90,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (file != null) {
        setState(() => onPicked(file.path));
      }
    } catch (e) {
      if (mounted) {
        ToastState.error.snackBar(context, 'Failed to pick image'.tran);
      }
    }
  }

  void _handleSubmit() {
    if (_hasExpirationDate == null) {
      ToastState.error.snackBar(
        context,
        'Please select if document has expiration date'.tran,
      );
      return;
    }
    if (_documentType == null) {
      ToastState.error.snackBar(context, 'Please select document type'.tran);
      return;
    }
    if (_documentNoController.text.trim().isEmpty) {
      ToastState.error.snackBar(context, 'Please enter document number'.tran);
      return;
    }
    if (_selectedCountry == null) {
      ToastState.error.snackBar(context, 'Please select issuing country'.tran);
      return;
    }
    if (_addressCountry == null) {
      ToastState.error.snackBar(context, 'Please select address country'.tran);
      return;
    }
    if (_cityController.text.trim().isEmpty) {
      ToastState.error.snackBar(context, 'Please enter city'.tran);
      return;
    }
    if (_addressController.text.trim().isEmpty) {
      ToastState.error.snackBar(context, 'Please enter address'.tran);
      return;
    }
    if (_postalCodeController.text.trim().isEmpty) {
      ToastState.error.snackBar(context, 'Please enter postal code'.tran);
      return;
    }

    if (widget.email == null || widget.email!.trim().isEmpty) {
      ToastState.error.snackBar(
        context,
        'Email is missing. Please restart registration.'.tran,
      );
      return;
    }

    if (widget.password == null || widget.password!.trim().isEmpty) {
      ToastState.error.snackBar(
        context,
        'Password is missing. Please restart registration.'.tran,
      );
      return;
    }
    if(_frontSidePath==null){
      ToastState.error.snackBar(context, _documentType == 'Passport' ? 'Please upload passport document'.tran : 'Please upload front side of document'.tran);
      return;
    }

    context.read<AuthCubit>().submitIdentityVerification(
      email: widget.email!,
      password: widget.password!,
      docType: _documentType == 'Passport' ? 'passport' : 'national-id',
      docExpiry: _hasExpirationDate == true ? 'yes' : 'no',
      docNumber: _documentNoController.text.trim(),
      countryIssue: _selectedCountry?.toJson() ?? {},
      frontSidePath: _frontSidePath!,
      backSidePath: _backSidePath,
      otherDocPath: _otherDocPath,
      addressCountry: _addressCountry?.toJson(),
      city: _cityController.text.trim(),
      address: _addressController.text.trim(),
      postalCode: _postalCodeController.text.trim(),
      addressDocPath: _addressDocPath,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final res = MyRes.of(context);

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        state.maybeWhen(
          identitySubmitted: () {
            ToastState.success.snackBar(
              context,
              'Identity verification submitted successfully!'.tran,
            );
            Router.neglect(context, () => context.goNamed(RoutesNames.signIn));
          },
          error: (message) {
            ToastState.error.snackBar(context, message);
          },
          orElse: () {},
        );
      },
      builder: (context, state) {
        final isLoading = state.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );

        return Scaffold(
          backgroundColor: colorScheme.surfaceContainerLowest,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
              onPressed: () => context.pop(),
            ),
            title: Text(
              'Identity verification'.tran,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            centerTitle: false,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionTitle('DOES THE DOCUMENT HAVE AN EXPIRATION DATE?'),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      _buildRadioOption(
                        label: 'No',
                        value: false,
                        groupValue: _hasExpirationDate,
                        onChanged: (val) =>
                            setState(() => _hasExpirationDate = val),
                      ),
                      SizedBox(width: 24.w),
                      _buildRadioOption(
                        label: 'Yes',
                        value: true,
                        groupValue: _hasExpirationDate,
                        onChanged: (val) =>
                            setState(() => _hasExpirationDate = val),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),

                  _buildSectionTitle('DOCUMENT TYPE'),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      _buildRadioOption(
                        label: 'Passport',
                        value: 'Passport',
                        groupValue: _documentType,
                        onChanged: (val) => setState(() => _documentType = val),
                      ),
                      SizedBox(width: 24.w),
                      _buildRadioOption(
                        label: 'National ID',
                        value: 'National ID',
                        groupValue: _documentType,
                        onChanged: (val) => setState(() => _documentType = val),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),

                  _buildSectionTitle('DOCUMENT NO.'),
                  SizedBox(height: 8.h),
                  AuthTextField(
                    label: '',
                    hintText: 'Enter Document No'.tran,
                    controller: _documentNoController,
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: 24.h),

                  _buildSectionTitle('ISSUING COUNTRY'),
                  SizedBox(height: 8.h),
                  DropdownButtonSearch<CountryModel>(
                    label: 'Select country'.tran,
                    value: _selectedCountry,
                    asyncItems: () async {
                      return await _countryServices.fetchCountries();
                    },
                    onView: (value) => value?.name,
                    onChanged: (v) => setState(() => _selectedCountry = v),
                  ),
                  SizedBox(height: 24.h),

                  // Warning box
                  Container(
                    padding: EdgeInsets.all(16.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2312), // Dark amber background
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFF3CD11).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: const Color(0xFFF3CD11),
                          size: 20.h,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            'The document owner must take a clear selfie while holding all the required documents. Submissions without a selfie may be rejected.'
                                .tran,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFFE5D599),
                              fontSize: 13.h,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),

                  _buildSectionTitle(_documentType == 'Passport' ? 'PASSPORT' : 'FRONT SIDE'),
                  SizedBox(height: 12.h),
                  _buildUploadBox(
                    context: context,
                    label: _documentType == 'Passport' ? 'Tap to upload passport photo' : 'Tap to upload front photo',
                    icon: Icons.camera_alt_outlined,
                    filePath: _frontSidePath,
                    isImage: true,
                    onTap: () => _pickImage(
                      onPicked: (path) => _frontSidePath = path,
                    ),
                    onRemove: () => setState(() => _frontSidePath = null),
                  ),
                  SizedBox(height: 24.h),

                  if (_documentType != 'Passport') ...[
                    _buildSectionTitle('BACK SIDE (IF ANY)', isRequired: false),
                    SizedBox(height: 12.h),
                    _buildUploadBox(
                      context: context,
                      label: 'Tap to upload back photo',
                      icon: Icons.camera_alt_outlined,
                      filePath: _backSidePath,
                      isImage: true,
                      onTap: () => _pickImage(
                        onPicked: (path) => _backSidePath = path,
                      ),
                      onRemove: () => setState(() => _backSidePath = null),
                    ),
                    SizedBox(height: 24.h),
                  ],

                  _buildSectionTitle('OTHER DOCUMENT', isRequired: false),
                  SizedBox(height: 12.h),
                  _buildUploadBox(
                    context: context,
                    label: 'Add supporting document',
                    icon: Icons.add,
                    filePath: _otherDocPath,
                    onTap: () => _pickFile(
                      type: FileType.any,
                      onPicked: (path) => _otherDocPath = path,
                    ),
                    onRemove: () => setState(() => _otherDocPath = null),
                  ),
                  SizedBox(height: 28.h),

                  Divider(color: colorScheme.outlineVariant),
                  SizedBox(height: 16.h),
                  Text(
                    'ADDRESS DETAILS'.tran,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                      fontSize: 16.h,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  _buildSectionTitle('ADDRESS COUNTRY'),
                  SizedBox(height: 8.h),
                  DropdownButtonSearch<CountryModel>(
                    label: 'Select address country'.tran,
                    value: _addressCountry,
                    asyncItems: () async {
                      return await _countryServices.fetchCountries();
                    },
                    onView: (value) => value?.name,
                    onChanged: (v) => setState(() => _addressCountry = v),
                  ),
                  SizedBox(height: 24.h),

                  _buildSectionTitle('CITY'),
                  SizedBox(height: 8.h),
                  AuthTextField(
                    label: '',
                    hintText: 'Enter City'.tran,
                    controller: _cityController,
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: 24.h),

                  _buildSectionTitle('ADDRESS'),
                  AuthTextField(
                    label: '',
                    hintText: 'Enter Address'.tran,
                    controller: _addressController,
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: 24.h),

                  _buildSectionTitle('POSTAL CODE'),
                  AuthTextField(
                    label: '',
                    hintText: 'Enter Postal Code'.tran,
                    controller: _postalCodeController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                  ),
                  SizedBox(height: 24.h),

                  _buildSectionTitle('PROOF OF ADDRESS DOCUMENT', isRequired: false),
                  _buildUploadBox(
                    context: context,
                    label: 'Add proof of address document',
                    icon: Icons.add,
                    filePath: _addressDocPath,
                    onTap: () => _pickFile(
                      type: FileType.any,
                      onPicked: (path) => _addressDocPath = path,
                    ),
                    onRemove: () => setState(() => _addressDocPath = null),
                  ),
                  SizedBox(height: 32.h),

                  MyElevatedButton(
                    maximumSize: Size.fromHeight(50.h),
                    minimumSize: Size.fromHeight(50.h),
                    label: 'Submit Verification'.tran,
                    isLoading: isLoading,
                    suffix: Padding(
                      padding: EdgeInsets.only(left: 8.w),
                      child: Icon(
                        Icons.send_outlined,
                        size: 20.h,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    onPressed: isLoading ? null : _handleSubmit,
                    res: res,
                    backgroundColor: const Color(0xFF98B2FB),
                    foregroundColor: const Color(0xFF0F172A),
                  ),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, {bool isRequired = true}) {
    return Row(
      children: [
        if (isRequired)
          Text(
            '* ',
            style: TextStyle(
              color: const Color(0xFFF3CD11),
              fontSize: 12.h,
              fontWeight: FontWeight.bold,
            ),
          ),
        Text(
          title.tran,
          style: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 11.h,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _buildRadioOption<T>({
    required String label,
    required T value,
    required T? groupValue,
    required ValueChanged<T?> onChanged,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Radio<T>(
            value: value,
            groupValue: groupValue,
            onChanged: onChanged,
            activeColor: const Color(0xFF6366F1),
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          SizedBox(width: 8.w),
          Text(
            label.tran,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
              fontSize: 14.h,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadBox({
    required BuildContext context,
    required String label,
    required IconData icon,
    required String? filePath,
    required VoidCallback onTap,
    required VoidCallback onRemove,
    bool isImage = false,
  }) {
    final theme = Theme.of(context);

    final fileName = filePath != null
        ? filePath.split(Platform.pathSeparator).last
        : null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 140.h,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: filePath != null
                ? const Color(0xFF6366F1)
                : theme.colorScheme.outlineVariant.withOpacity(0.5),
            width: filePath != null ? 1.5 : 1.0,
          ),
        ),
        child: filePath != null
            ? (isImage
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.file(
                            File(filePath),
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: 40.h,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withOpacity(0.6),
                                  Colors.transparent,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 8.h,
                          left: 8.w,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.65),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 12.h,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  'Tap to change'.tran,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.h,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4.h,
                          right: 4.w,
                          child: IconButton(
                            icon: Container(
                              padding: EdgeInsets.all(4.h),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16.h,
                              ),
                            ),
                            onPressed: onRemove,
                          ),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.all(12.h),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_circle_outline,
                            color: const Color(0xFF6366F1),
                            size: 24.h,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fileName ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.h,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'Tap to change file'.tran,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontSize: 11.h,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: theme.colorScheme.error,
                            size: 20.h,
                          ),
                          onPressed: onRemove,
                        ),
                      ],
                    ),
                  ))
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(12.h),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 20.h,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    label.tran,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 13.h,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Bottom-sheet for selecting image source (camera or gallery).
class _ImageSourceSheet extends StatelessWidget {
  const _ImageSourceSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Choose Image Source',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Camera option
            _SourceTile(
              icon: Icons.camera_alt_outlined,
              label: 'Take Photo',
              subtitle: 'Use the camera',
              color: const Color(0xFF6366F1),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            const SizedBox(height: 12),
            // Gallery option
            _SourceTile(
              icon: Icons.photo_library_outlined,
              label: 'Choose from Gallery',
              subtitle: 'Pick an existing photo',
              color: const Color(0xFF0EA5E9),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: colorScheme.outlineVariant.withOpacity(0.4),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
