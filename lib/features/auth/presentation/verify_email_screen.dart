import 'package:flutter/material.dart';
import 'package:tikka/app/router/app_routes.dart';
import 'package:tikka/app/theme/app_theme.dart';
import 'package:tikka/core/widgets/tikka_button.dart';
import 'package:tikka/features/auth/domain/auth_failure.dart';
import 'package:tikka/features/auth/domain/auth_repository.dart';
import 'package:tikka/features/auth/presentation/auth_form_page.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({
    super.key,
    required this.email,
    required this.repository,
    this.configurationMessage,
  });

  final String? email;
  final AuthRepository? repository;
  final String? configurationMessage;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _isResending = false;
  String? _message;
  String? _error;

  Future<void> _resend() async {
    final email = widget.email?.trim();
    if (email == null || email.isEmpty || widget.repository == null) {
      setState(() {
        _error =
            widget.configurationMessage ??
            'Return to sign in and check the app configuration.';
      });
      return;
    }

    setState(() {
      _isResending = true;
      _message = null;
      _error = null;
    });
    try {
      await widget.repository!.resendSignupVerification(email);
      if (mounted) {
        setState(() => _message = 'A new confirmation email has been sent.');
      }
    } on AuthFailure catch (failure) {
      if (mounted) {
        setState(() => _error = failure.userMessage);
      }
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final email = widget.email?.trim();
    final description = email == null || email.isEmpty
        ? 'Open the confirmation link in your email to activate your account.'
        : 'A confirmation link was sent to $email. Open it to activate your account.';

    return AuthFormPage(
      title: 'Verify your email',
      description: description,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (_message != null) ...<Widget>[
            Text(
              _message!,
              style: textTheme.bodySmall?.copyWith(color: AppColors.success),
            ),
            const SizedBox(height: AppSpacing.medium),
          ],
          if (_error != null ||
              widget.configurationMessage != null) ...<Widget>[
            Text(
              _error ?? widget.configurationMessage!,
              style: textTheme.bodySmall?.copyWith(color: AppColors.error),
            ),
            const SizedBox(height: AppSpacing.medium),
          ],
          TikkaButton(
            label: _isResending ? 'Sending…' : 'Resend confirmation email',
            onPressed: _isResending ? null : _resend,
            style: TikkaButtonStyle.secondary,
            fullWidth: true,
          ),
          const SizedBox(height: AppSpacing.small),
          TikkaButton(
            label: 'Back to sign in',
            onPressed: () {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
            },
            style: TikkaButtonStyle.text,
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}
