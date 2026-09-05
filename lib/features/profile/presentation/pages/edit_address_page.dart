import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:res_reline/my_responsive.dart';

import 'dart:io';
import '../../../../core/componants/async_dropdownmenu.dart';
import '../../../../core/componants/my_elevated_button.dart';
import '../../../../core/componants/toast.dart';
import '../../../../core/config/language/language_manager.dart';
import '../../../../core/network/shared_services/country_api_services.dart';
import '../cubit/edit_form/edit_form_cubit.dart';
import '../cubit/edit_form/edit_form_state.dart';

class EditAddressPage extends StatefulWidget {
  final Map<String, dynamic> initialForm;

  const EditAddressPage({super.key, required this.initialForm});

  @override
  State<EditAddressPage> createState() => _EditAddressPageState();
}

class _EditAddressPageState extends State<EditAddressPage> {
  CountryModel? _addressCountry;
  final CountryApiServices _countryServices = CountryApiServices();

  late TextEditingController _cityController;
  late TextEditingController _addressController;
  late TextEditingController _postalCodeController;
  String? _addressDocPath;

  @override
  void initState() {
    super.initState();
    _cityController = TextEditingController(text: widget.initialForm['city']?.toString() ?? '');
    _addressController = TextEditingController(text: widget.initialForm['address']?.toString() ?? '');
    _postalCodeController = TextEditingController(text: widget.initialForm['postalCode']?.toString() ?? '');

    if (widget.initialForm['country'] != null) {
      _addressCountry = CountryModel.fromJson(widget.initialForm['country']);
    }

    if (widget.initialForm['document'] != null && widget.initialForm['document']['url'] != null) {
      _addressDocPath = widget.initialForm['document']['url'];
    }
  }

  @override
  void dispose() {
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

  void _handleSubmit() {
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

    context.read<EditFormCubit>().updateAddressForm(
      country: _addressCountry!.toJson(),
      city: _cityController.text.trim(),
      address: _addressController.text.trim(),
      postalCode: _postalCodeController.text.trim(),
      addressDocPath: _addressDocPath,
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
        height: 140.s,
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
                          child: filePath.startsWith('/x-api') 
                            ? Image.network('https://boker.egytag.com${filePath}', fit: BoxFit.cover) 
                            : Image.file(File(filePath), fit: BoxFit.cover),
                        ),
                        Positioned(
                          top: 0, left: 0, right: 0, height: 40.s,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.black.withOpacity(0.6), Colors.transparent],
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
                        Text(
                          fileName ?? 'Document attached',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF6366F1), fontWeight: FontWeight.w500),
                        ),
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
                    Text(
                      label,
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
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
          'Edit Address'.tran,
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
              ToastState.success.snackBar(context, 'Address updated successfully!'.tran);
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
                _buildSectionTitle('COUNTRY OF RESIDENCE'),
                DropdownButtonSearch<CountryModel>(
                  asyncItems: () async => await _countryServices.fetchCountries(),
                  onView: (c) => c?.name,
                  onChanged: (country) => setState(() => _addressCountry = country),
                  label: 'Select country'.tran,
                  value: _addressCountry,
                ),
                SizedBox(height: 16.s),

                _buildSectionTitle('CITY'),
                TextFormField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    hintText: 'Enter City'.tran,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.s)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.s, vertical: 12.s),
                  ),
                ),
                SizedBox(height: 16.s),

                _buildSectionTitle('ADDRESS'),
                TextFormField(
                  controller: _addressController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Enter Full Address'.tran,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.s)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.s, vertical: 12.s),
                  ),
                ),
                SizedBox(height: 16.s),

                _buildSectionTitle('POSTAL CODE'),
                TextFormField(
                  controller: _postalCodeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Enter Postal Code'.tran,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.s)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.s, vertical: 12.s),
                  ),
                ),
                SizedBox(height: 24.s),

                _buildSectionTitle('PROOF OF RESIDENCE (OPTIONAL)'),
                _buildUploadBox(
                  context: context,
                  label: 'Upload Proof of Residence'.tran,
                  icon: Icons.attach_file,
                  filePath: _addressDocPath,
                  onTap: () => _pickFile(onPicked: (p) => _addressDocPath = p),
                  onRemove: () => setState(() => _addressDocPath = null),
                ),
                SizedBox(height: 32.s),

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
