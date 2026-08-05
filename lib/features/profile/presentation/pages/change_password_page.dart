import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:res_reline/my_responsive.dart';
import 'package:boker/core/componants/toast.dart';
import 'package:boker/core/config/language/language_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:boker/core/componants/my_from_field.dart';
import 'package:boker/features/profile/presentation/cubit/account_cubit.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final result = await context.read<AccountCubit>().updatePasswordProfile(
      oldPassword: _oldPasswordController.text,
      newPassword: _newPasswordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    setState(() => _isLoading = false);

    result.fold(
      (failure) {
        ToastState.error.snackBar(context, failure.message);
      },
      (success) {
        ToastState.success.snackBar(context, 'Password changed successfully'.tran);
        context.pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password'.tran),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.s),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPasswordField(
                controller: _oldPasswordController,
                label: 'Old Password'.tran,
                obscureText: _obscureOld,
                onToggle: () => setState(() => _obscureOld = !_obscureOld),
                validator: (val) => val == null || val.isEmpty ? 'Required'.tran : null,
              ),
              SizedBox(height: 16.s),
              _buildPasswordField(
                controller: _newPasswordController,
                label: 'New Password'.tran,
                obscureText: _obscureNew,
                onToggle: () => setState(() => _obscureNew = !_obscureNew),
                validator: (val) => val == null || val.isEmpty ? 'Required'.tran : null,
              ),
              SizedBox(height: 16.s),
              _buildPasswordField(
                controller: _confirmPasswordController,
                label: 'Confirm Password'.tran,
                obscureText: _obscureConfirm,
                onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required'.tran;
                  if (val != _newPasswordController.text) return 'Passwords do not match'.tran;
                  return null;
                },
              ),
              SizedBox(height: 32.s),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.s),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.s),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20.s,
                        width: 20.s,
                        child: CircularProgressIndicator(strokeWidth: 2.s),
                      )
                    : Text(
                        'Submit'.tran,
                        style: TextStyle(fontSize: 16.s, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return MyTextFormField(
      controller: controller,
      isPassword: obscureText,
      validator: validator,
      labelText: label,
      suffixIcon: obscureText ? Icons.visibility_off : Icons.visibility,
      suffixOnPressed: onToggle,
    );
  }
}
