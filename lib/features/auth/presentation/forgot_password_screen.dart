import 'package:flutter/material.dart';
import 'package:tikka/app/router/app_routes.dart';
import 'package:tikka/app/theme/app_theme.dart';
import 'package:tikka/core/widgets/tikka_button.dart';
import 'package:tikka/core/widgets/tikka_text_field.dart';
import 'package:tikka/features/auth/domain/auth_failure.dart';
import 'package:tikka/features/auth/domain/auth_repository.dart';
import 'package:tikka/features/auth/presentation/auth_form_page.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({
    super.key,
    required this.repository,
    this.configurationMessage,
  });

  final AuthRepository? repository;
  final String? configurationMessage;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  String? _emailError;
  String? _error;
  bool _isSending = false;
  bool _requestSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final validEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    setState(() {
      _emailError = validEmail ? null : 'Enter a valid email address.';
      _error = null;
    });
    if (!validEmail) {
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

    setState(() => _isSending = true);
    try {
      await repository.requestPasswordRecovery(email);
      if (mounted) {
        setState(() => _requestSent = true);
      }
    } on AuthFailure catch (failure) {
      if (mounted) {
        setState(() => _error = failure.userMessage);
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AuthFormPage(
      title: 'Forgot password',
      description: 'Enter the email address associated with your account. We will send a password reset link if an account matches.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TikkaTextField(
            label: 'Email',
            hintText: 'Enter your email',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            errorText: _emailError,
            onChanged: (_) {
              if (_emailError != null || _error != null) {
                setState(() {
                  _emailError = null;
                  _error = null;
                });
              }
            },
            onSubmitted: (_) => _submit(),
          ),
          if (_requestSent) ...<Widget>[
            const SizedBox(height: AppSpacing.medium),
            Text(
              'If an account exists for this email, password reset instructions will arrive shortly.',
              style: textTheme.bodySmall?.copyWith(color: AppColors.success),
            ),
          ],
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
            label: _isSending ? 'Sending…' : 'Send reset link',
            onPressed: _isSending || widget.repository == null ? null : _submit,
            fullWidth: true,
          ),
          const SizedBox(height: AppSpacing.small),
          TikkaButton(
            label: 'Back to sign in',
            onPressed: () =>
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(AppRoutes.login, (route) => false),
            style: TikkaButtonStyle.text,
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}
