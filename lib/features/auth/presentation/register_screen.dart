import 'package:flutter/material.dart';
import 'package:tikka/app/router/app_routes.dart';
import 'package:tikka/app/theme/app_theme.dart';
import 'package:tikka/core/widgets/tikka_button.dart';
import 'package:tikka/core/widgets/tikka_text_field.dart';
import 'package:tikka/features/auth/domain/auth_failure.dart';
import 'package:tikka/features/auth/domain/auth_repository.dart';
import 'package:tikka/features/auth/presentation/auth_form_page.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
    required this.repository,
    this.configurationMessage,
  });

  final AuthRepository? repository;
  final String? configurationMessage;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmationController = TextEditingController();

  String? _nameError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;
  String? _confirmationError;
  String? _authError;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  bool _validEmail(String value) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);

  bool _validPhone(String value) {
    final normalized = value.replaceAll(RegExp(r'[()\-\s]'), '');
    return RegExp(r'^\+?[0-9]{7,15}$').hasMatch(normalized);
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirmation = _confirmationController.text;
    final nameError = name.isEmpty ? 'Enter your full name.' : null;
    final emailError = _validEmail(email)
        ? null
        : 'Enter a valid email address.';
    final phoneError = _validPhone(phone)
        ? null
        : 'Enter a valid phone number.';
    final passwordError = password.isEmpty ? 'Enter a password.' : null;
    final confirmationError = confirmation == password
        ? null
        : 'Passwords do not match.';

    setState(() {
      _nameError = nameError;
      _emailError = emailError;
      _phoneError = phoneError;
      _passwordError = passwordError;
      _confirmationError = confirmationError;
      _authError = null;
    });
    if (nameError != null ||
        emailError != null ||
        phoneError != null ||
        passwordError != null ||
        confirmationError != null) {
      return;
    }

    final repository = widget.repository;
    if (repository == null) {
      setState(() {
        _authError =
            widget.configurationMessage ??
            'Authentication is not available yet. Check the app configuration.';
      });
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final needsEmailVerification = await repository.signUp(
        fullName: name,
        email: email,
        phoneNumber: phone,
        password: password,
      );
      if (mounted && needsEmailVerification) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.verifyEmail,
          (route) => route.isFirst,
          arguments: email,
        );
      }
    } on AuthFailure catch (failure) {
      if (mounted) {
        setState(() => _authError = failure.userMessage);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AuthFormPage(
      title: 'Create account',
      description:
          'Create your TIKKA account to request and manage home services.',
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TikkaTextField(
              label: 'Full name',
              hintText: 'Enter your full name',
              controller: _nameController,
              textInputAction: TextInputAction.next,
              autofillHints: const <String>[AutofillHints.name],
              errorText: _nameError,
              onChanged: (_) {
                if (_nameError != null) {
                  setState(() => _nameError = null);
                }
              },
            ),
            const SizedBox(height: AppSpacing.medium),
            TikkaTextField(
              label: 'Email',
              hintText: 'Enter your email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const <String>[
                AutofillHints.username,
                AutofillHints.email,
              ],
              errorText: _emailError,
              onChanged: (_) {
                if (_emailError != null) {
                  setState(() => _emailError = null);
                }
              },
            ),
            const SizedBox(height: AppSpacing.medium),
            TikkaTextField(
              label: 'Phone number',
              hintText: 'Enter your phone number',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              autofillHints: const <String>[AutofillHints.telephoneNumber],
              errorText: _phoneError,
              onChanged: (_) {
                if (_phoneError != null) {
                  setState(() => _phoneError = null);
                }
              },
            ),
            const SizedBox(height: AppSpacing.medium),
            TikkaTextField(
              label: 'Password',
              hintText: 'Create a password',
              controller: _passwordController,
              obscureText: true,
              textInputAction: TextInputAction.next,
              autofillHints: const <String>[AutofillHints.newPassword],
              errorText: _passwordError,
              onChanged: (_) {
                if (_passwordError != null || _confirmationError != null) {
                  setState(() {
                    _passwordError = null;
                    _confirmationError = null;
                  });
                }
              },
            ),
            const SizedBox(height: AppSpacing.medium),
            TikkaTextField(
              label: 'Confirm password',
              hintText: 'Re-enter your password',
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
            if (_authError != null) ...<Widget>[
              const SizedBox(height: AppSpacing.medium),
              Text(
                _authError!,
                style: textTheme.bodySmall?.copyWith(color: AppColors.error),
              ),
            ],
            if (widget.configurationMessage != null) ...<Widget>[
              const SizedBox(height: AppSpacing.medium),
              Text(
                widget.configurationMessage!,
                style: textTheme.bodySmall?.copyWith(color: AppColors.error),
              ),
            ],
            const SizedBox(height: AppSpacing.xLarge),
            TikkaButton(
              label: _isSubmitting ? 'Creating account…' : 'Create account',
              onPressed: _isSubmitting || widget.repository == null
                  ? null
                  : _submit,
              fullWidth: true,
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              'We will send a confirmation link to your email address.',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
