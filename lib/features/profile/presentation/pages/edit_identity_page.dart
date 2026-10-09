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
import '../../../../core/network/shared_services/country_api_services.dart';
import '../cubit/edit_form/edit_form_cubit.dart';
import '../cubit/edit_form/edit_form_state.dart';

class EditIdentityPage extends StatefulWidget {
  final Map<String, dynamic> initialForm;
  
  const EditIdentityPage({super.key, required this.initialForm});

  @override
  State<EditIdentityPage> createState() => _EditIdentityPageState();
}

class _EditIdentityPageState extends State<EditIdentityPage> {
  bool? _hasExpirationDate;
  String? _documentType;
  late TextEditingController _documentNoController;
  CountryModel? _selectedCountry;
  final CountryApiServices _countryServices = CountryApiServices();

  String? _frontSidePath;
  String? _backSidePath;
  String? _otherDocPath;

  @override
  void initState() {
    super.initState();
    _documentNoController = TextEditingController(text: widget.initialForm['docNumber']?.toString() ?? '');
    
    _hasExpirationDate = widget.initialForm['docExpiry'] == 'yes';
    
    final dt = widget.initialForm['docType']?.toString();
    if (dt == 'passport') {
      _documentType = 'Passport';
    } else if (dt == 'national-id') _documentType = 'National ID';

    if (widget.initialForm['countryIssue'] != null) {
      _selectedCountry = CountryModel.fromJson(widget.initialForm['countryIssue']);
    }

    if (widget.initialForm['imageFrontSide'] != null && widget.initialForm['imageFrontSide']['url'] != null) {
      _frontSidePath = widget.initialForm['imageFrontSide']['url'];
    }
    if (widget.initialForm['imageBackSide'] != null && widget.initialForm['imageBackSide']['url'] != null) {
      _backSidePath = widget.initialForm['imageBackSide']['url'];
    }
    if (widget.initialForm['file'] != null && widget.initialForm['file']['url'] != null) {
      _otherDocPath = widget.initialForm['file']['url'];
    }
  }

  @override
  void dispose() {
    _documentNoController.dispose();
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
      if (result.isNotEmpty && result.first.path != null) {
        setState(() {
          onPicked(result.first.path!);
        });
      }
    } catch (e) {
      if (mounted) {
        ToastState.error.snackBar(context, 'Failed to pick file'.tran);
      }
    }
  }

  Future<void> _pickImage({
    required Function(String path) onPicked,
  }) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        padding: EdgeInsets.all(20.s),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text('Camera'.tran),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text('Gallery'.tran),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: source,
        imageQuality: 90,
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
      ToastState.error.snackBar(context, 'Please select if document has expiration date'.tran);
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
    if (_frontSidePath == null || _frontSidePath!.isEmpty) {
      ToastState.error.snackBar(context, _documentType == 'Passport' ? 'Please upload passport document'.tran : 'Please upload front side of document'.tran);
      return;
    }

    context.read<EditFormCubit>().updateIdentityForm(
      docType: _documentType == 'Passport' ? 'passport' : 'national-id',
      docExpiry: _hasExpirationDate == true ? 'yes' : 'no',
      docNumber: _documentNoController.text.trim(),
      countryIssue: _selectedCountry?.toJson() ?? {},
      frontSidePath: _frontSidePath!,
      backSidePath: _backSidePath,
      otherDocPath: _otherDocPath,
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
    final fileName = filePath?.split(Platform.pathSeparator).last;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 140.s,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: filePath != null ? const Color(0xFF6366F1) : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
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
                          child: filePath.startsWith('/x-api') 
                            ? Image.network('https://boker.egytag.com$filePath', fit: BoxFit.cover) 
                            : Image.file(File(filePath), fit: BoxFit.cover),
                        ),
                        Positioned(
                          top: 0, left: 0, right: 0, height: 40.s,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent],
                                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 8.s, right: 8.s,
                          child: InkWell(
                            onTap: onRemove,
                            child: Container(
                              padding: EdgeInsets.all(4.s),
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: Icon(Icons.delete, color: Colors.red, size: 20.s),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, size: 40.s, color: const Color(0xFF6366F1)),
                        SizedBox(height: 8.s),
                        Text(fileName ?? 'Document attached', textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF6366F1), fontWeight: FontWeight.w500)),
                        TextButton(onPressed: onRemove, child: Text('Remove'.tran, style: TextStyle(color: Colors.red))),
                      ],
                    ),
                  ))
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 40.s, color: theme.colorScheme.onSurfaceVariant),
                    SizedBox(height: 8.s),
                    Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(top: 16.s, bottom: 8.s),
      child: Text(
        title.tran,
        style: TextStyle(
          fontSize: 12.s,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildRadioOption({
    required String label,
    required bool value,
    required bool? groupValue,
    required ValueChanged<bool?> onChanged,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<bool>(
          value: value,
          groupValue: groupValue,
          onChanged: onChanged,
          activeColor: Theme.of(context).primaryColor,
        ),
        Text(label.tran, style: TextStyle(fontSize: 14.s)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Edit Identity'.tran,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
      body: BlocConsumer<EditFormCubit, EditFormState>(
        listener: (context, state) {
          state.maybeWhen(
            success: () {
              ToastState.success.snackBar(context, 'Identity updated successfully!'.tran);
              context.pop(true);
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

          return SingleChildScrollView(
            padding: EdgeInsets.all(20.s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSectionTitle('DOES THE DOCUMENT HAVE AN EXPIRATION DATE?'),
                Row(
                  children: [
                    _buildRadioOption(
                      label: 'No',
                      value: false,
                      groupValue: _hasExpirationDate,
                      onChanged: (val) => setState(() => _hasExpirationDate = val),
                    ),
                    SizedBox(width: 24.s),
                    _buildRadioOption(
                      label: 'Yes',
                      value: true,
                      groupValue: _hasExpirationDate,
                      onChanged: (val) => setState(() => _hasExpirationDate = val),
                    ),
                  ],
                ),
                SizedBox(height: 16.s),

                _buildSectionTitle('DOCUMENT TYPE'),
                DropdownButtonFormField<String>(
                  initialValue: _documentType,
                  hint: Text('Select Document Type'.tran),
                  items: ['Passport', 'National ID'].map((e) => DropdownMenuItem(value: e, child: Text(e.tran))).toList(),
                  onChanged: (val) {
                    setState(() {
                      _documentType = val;
                      _frontSidePath = null;
                      _backSidePath = null;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.s)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.s, vertical: 12.s),
                  ),
                ),
                SizedBox(height: 16.s),

                _buildSectionTitle('DOCUMENT NUMBER'),
                TextFormField(
                  controller: _documentNoController,
                  decoration: InputDecoration(
                    hintText: 'Enter Document Number'.tran,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.s)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.s, vertical: 12.s),
                  ),
                ),
                SizedBox(height: 16.s),

                _buildSectionTitle('COUNTRY OF ISSUE'),
                DropdownButtonSearch<CountryModel>(
                  asyncItems: () async => await _countryServices.fetchCountries(),
                  onView: (c) => c?.name,
                  onChanged: (country) => setState(() => _selectedCountry = country),
                  label: 'Select country'.tran,
                  value: _selectedCountry,
                ),
                SizedBox(height: 24.s),

                if (_documentType != null) ...[
                  _buildSectionTitle(_documentType == 'Passport' ? 'PASSPORT DOCUMENT' : 'FRONT SIDE OF DOCUMENT'),
                  _buildUploadBox(
                    context: context,
                    label: _documentType == 'Passport' ? 'Upload Passport'.tran : 'Upload Front Side'.tran,
                    icon: Icons.camera_alt,
                    isImage: true,
                    filePath: _frontSidePath,
                    onTap: () => _pickImage(onPicked: (p) => _frontSidePath = p),
                    onRemove: () => setState(() => _frontSidePath = null),
                  ),
                  SizedBox(height: 16.s),

                  if (_documentType != 'Passport') ...[
                    _buildSectionTitle('BACK SIDE OF DOCUMENT'),
                    _buildUploadBox(
                      context: context,
                      label: 'Upload Back Side'.tran,
                      icon: Icons.camera_alt,
                      isImage: true,
                      filePath: _backSidePath,
                      onTap: () => _pickImage(onPicked: (p) => _backSidePath = p),
                      onRemove: () => setState(() => _backSidePath = null),
                    ),
                    SizedBox(height: 16.s),
                  ],

                  _buildSectionTitle('OTHER DOCUMENT (OPTIONAL)'),
                  _buildUploadBox(
                    context: context,
                    label: 'Upload Other Document'.tran,
                    icon: Icons.attach_file,
                    filePath: _otherDocPath,
                    onTap: () => _pickFile(onPicked: (p) => _otherDocPath = p),
                    onRemove: () => setState(() => _otherDocPath = null),
                  ),
                  SizedBox(height: 32.s),
                ],

                MyElevatedButton(
                  label: 'Save Changes'.tran,
                  onPressed: isLoading ? null : _handleSubmit,
                  isLoading: isLoading,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
