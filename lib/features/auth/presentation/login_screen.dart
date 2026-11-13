import 'package:flutter/material.dart';
import 'package:tikka/app/router/app_routes.dart';
import 'package:tikka/app/theme/app_theme.dart';
import 'package:tikka/core/widgets/tikka_button.dart';
import 'package:tikka/core/widgets/tikka_text_field.dart';
import 'package:tikka/features/auth/domain/auth_failure.dart';
import 'package:tikka/features/auth/domain/auth_repository.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.repository,
    this.configurationMessage,
  });

  final AuthRepository? repository;
  final String? configurationMessage;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _emailError;
  String? _passwordError;
  String? _authError;
  String? _verificationMessage;
  bool _isSubmitting = false;
  bool _isResendingVerification = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final emailError = _validEmail(email)
        ? null
        : 'Enter a valid email address.';
    final passwordError = password.isEmpty ? 'Enter your password.' : null;

    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
      _authError = null;
      _verificationMessage = null;
    });
    if (emailError != null || passwordError != null) {
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
      await repository.signIn(email: email, password: password);
    } on AuthFailure catch (failure) {
      if (mounted) {
        setState(() {
          _authError = failure.userMessage;
          _verificationMessage = null;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  bool _validEmail(String value) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);

  Future<void> _resendVerification() async {
    final email = _emailController.text.trim();
    if (!_validEmail(email)) {
      setState(() => _emailError = 'Enter a valid email address first.');
      return;
    }
    final repository = widget.repository;
    if (repository == null) {
      setState(() {
        _verificationMessage =
            widget.configurationMessage ?? 'Authentication is not available.';
      });
      return;
    }

    setState(() {
      _isResendingVerification = true;
      _verificationMessage = null;
    });
    try {
      await repository.resendSignupVerification(email);
      if (mounted) {
        setState(
          () =>
              _verificationMessage = 'A new confirmation email has been sent.',
        );
      }
    } on AuthFailure catch (failure) {
      if (mounted) {
        setState(() => _verificationMessage = failure.userMessage);
      }
    } finally {
      if (mounted) {
        setState(() => _isResendingVerification = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 56, 16, 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight > 72
                          ? constraints.maxHeight - 72
                          : 0,
                    ),
                    child: AutofillGroup(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Welcome to TIKKA',
                            style: textTheme.headlineLarge,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Sign in to request trusted local services.',
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 36),
                          TikkaTextField(
                            label: 'Email',
                            hintText: 'Enter email',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const <String>[
                              AutofillHints.username,
                              AutofillHints.email,
                            ],
                            height: 68,
                            errorText: _emailError,
                            onChanged: (_) {
                              if (_emailError != null ||
                                  _authError != null ||
                                  _verificationMessage != null) {
                                setState(() {
                                  _emailError = null;
                                  _authError = null;
                                  _verificationMessage = null;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          TikkaTextField(
                            label: 'Password',
                            hintText: 'Enter password',
                            controller: _passwordController,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            autofillHints: const <String>[
                              AutofillHints.password,
                            ],
                            height: 68,
                            errorText: _passwordError,
                            onChanged: (_) {
                              if (_passwordError != null ||
                                  _authError != null ||
                                  _verificationMessage != null) {
                                setState(() {
                                  _passwordError = null;
                                  _authError = null;
                                  _verificationMessage = null;
                                });
                              }
                            },
                            onSubmitted: (_) => _submit(),
                          ),
                          const SizedBox(height: 16),
                          TikkaButton(
                            label: _isSubmitting ? 'Signing in…' : 'Login',
                            onPressed:
                                _isSubmitting || widget.repository == null
                                ? null
                                : _submit,
                            fullWidth: true,
                          ),
                          if (_authError != null) ...<Widget>[
                            const SizedBox(height: 8),
                            Text(
                              _authError!,
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ],
                          if (_authError?.contains('confirm your email') ==
                              true) ...<Widget>[
                            TextButton(
                              onPressed: _isResendingVerification
                                  ? null
                                  : _resendVerification,
                              child: Text(
                                _isResendingVerification
                                    ? 'Sending confirmation…'
                                    : 'Resend confirmation email',
                              ),
                            ),
                            if (_verificationMessage != null)
                              Text(
                                _verificationMessage!,
                                style: textTheme.bodySmall?.copyWith(
                                  color:
                                      _verificationMessage!.startsWith(
                                        'A new confirmation',
                                      )
                                      ? AppColors.success
                                      : AppColors.error,
                                ),
                              ),
                          ],
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context)
                                    .pushNamed(AppRoutes.forgotPassword);
                              },
                              style: TextButton.styleFrom(
                                minimumSize: Size.zero,
                                padding: EdgeInsets.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                alignment: Alignment.centerLeft,
                                textStyle: AppTheme.buttonLabel.copyWith(
                                  fontSize: 13,
                                ),
                              ),
                              child: const Text('Forgot password?'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: <Widget>[
                              const Expanded(child: Divider()),
                              const SizedBox(width: 8),
                              Text(
                                'OR',
                                style: textTheme.bodySmall?.copyWith(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const TikkaButton(
                            label: 'Continue with Google',
                            onPressed: null,
                            style: TikkaButtonStyle.secondary,
                            fullWidth: true,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: <Widget>[
                              Text(
                                'New to TIKKA?',
                                style: textTheme.bodySmall?.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pushNamed(AppRoutes.register);
                                },
                                style: TextButton.styleFrom(
                                  minimumSize: Size.zero,
                                  padding: const EdgeInsets.only(left: 4),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  textStyle: AppTheme.buttonLabel.copyWith(
                                    fontSize: 13,
                                  ),
                                ),
                                child: const Text('Create account'),
                              ),
                            ],
                          ),
                          if (widget.configurationMessage != null) ...<Widget>[
                            const SizedBox(height: 20),
                            Text(
                              widget.configurationMessage!,
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
