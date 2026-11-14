import 'package:flutter/material.dart';
import 'package:tikka/app/theme/app_theme.dart';
import 'package:tikka/core/widgets/tikka_button.dart';
import 'package:tikka/features/auth/domain/auth_failure.dart';
import 'package:tikka/features/auth/domain/auth_repository.dart';

class ProfileLogoutAction extends StatefulWidget {
  const ProfileLogoutAction({super.key, required this.repository});

  final AuthRepository repository;

  @override
  State<ProfileLogoutAction> createState() => _ProfileLogoutActionState();
}

class _ProfileLogoutActionState extends State<ProfileLogoutAction> {
  bool _isSigningOut = false;
  String? _error;

  Future<void> _signOut() async {
    setState(() {
      _isSigningOut = true;
      _error = null;
    });
    try {
      await widget.repository.signOut();
    } on AuthFailure catch (failure) {
      if (mounted) {
        setState(() => _error = failure.userMessage);
      }
    } finally {
      if (mounted) {
        setState(() => _isSigningOut = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TikkaButton(
          label: _isSigningOut ? 'Signing out…' : 'Log out',
          onPressed: _isSigningOut ? null : _signOut,
          style: TikkaButtonStyle.secondary,
          fullWidth: true,
        ),
        if (_error != null) ...<Widget>[
          const SizedBox(height: AppSpacing.small),
          Text(
            _error!,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: AppColors.error),
          ),
        ],
      ],
    );
  }
}
