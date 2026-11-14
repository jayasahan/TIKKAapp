import 'package:flutter/material.dart';
import 'package:tikka/app/theme/app_theme.dart';
import 'package:tikka/core/widgets/tikka_button.dart';
import 'package:tikka/core/widgets/tikka_text_field.dart';
import 'package:tikka/features/auth/domain/auth_failure.dart';
import 'package:tikka/features/auth/domain/auth_repository.dart';
import 'package:tikka/features/auth/presentation/auth_form_page.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({
    super.key,
    required this.repository,
    this.configurationMessage,
  });

  final AuthRepository? repository;
  final String? configurationMessage;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmationController = TextEditingController();
  String? _passwordError;
  String? _confirmationError;
  String? _error;
  bool _isSaving = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final password = _passwordController.text;
    final confirmation = _confirmationController.text;
    final passwordError = password.isEmpty ? 'Enter a new password.' : null;
    final confirmationError = confirmation == password
        ? null
        : 'Passwords do not match.';
    setState(() {
      _passwordError = passwordError;
      _confirmationError = confirmationError;
      _error = null;
    });
    if (passwordError != null || confirmationError != null) {
      return;
    }

    final repository = widget.repository;
    if (repository == null) {
      setState(() {
        _error =
            widget.configurationMessage ??
            'Authentication is not available yet. Check the app configuration.';
      });
      return;
    }

    setState(() => _isSaving = true);
    try {
      await repository.updatePassword(password);
    } on AuthFailure catch (failure) {
      if (mounted) {
        setState(() => _error = failure.userMessage);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AuthFormPage(
      title: 'Reset password',
      description: 'Choose a new password for your TIKKA account.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TikkaTextField(
            label: 'New password',
            hintText: 'Enter a new password',
            controller: _passwordController,
            obscureText: true,
            textInputAction: TextInputAction.next,
            autofillHints: const <String>[AutofillHints.newPassword],
            errorText: _passwordError,
            onChanged: (_) {
              if (_passwordError != null || _error != null) {
                setState(() {
                  _passwordError = null;
                  _error = null;
                });
              }
            },
          ),
          const SizedBox(height: AppSpacing.medium),
          TikkaTextField(
            label: 'Confirm new password',
            hintText: 'Re-enter your new password',
            controller: _confirmationController,
            obscureText: true,
            textInputAction: TextInputAction.done,
            autofillHints: const <String>[AutofillHints.newPassword],
            errorText: _confirmationError,
            onChanged: (_) {
              if (_confirmationError != null) {
                setState(() => _confirmationError = null);
              }
            },
            onSubmitted: (_) => _submit(),
          ),
          if (_error != null ||
              widget.configurationMessage != null) ...<Widget>[
            const SizedBox(height: AppSpacing.medium),
            Text(
              _error ?? widget.configurationMessage!,
              style: textTheme.bodySmall?.copyWith(color: AppColors.error),
            ),
          ],
          const SizedBox(height: AppSpacing.xLarge),
          TikkaButton(
            label: _isSaving ? 'Saving…' : 'Update password',
            onPressed: _isSaving || widget.repository == null ? null : _submit,
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}
