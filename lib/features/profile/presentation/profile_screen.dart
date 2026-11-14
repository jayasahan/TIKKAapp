import 'package:flutter/material.dart';
import 'package:tikka/app/router/app_routes.dart';
import 'package:tikka/app/theme/app_theme.dart';
import 'package:tikka/core/widgets/tikka_button.dart';
import 'package:tikka/core/widgets/tikka_states.dart';
import 'package:tikka/features/auth/domain/auth_repository.dart';
import 'package:tikka/features/auth/presentation/profile_logout_action.dart';
import 'package:tikka/features/profile/domain/customer_profile.dart';
import 'package:tikka/features/profile/domain/profile_failure.dart';
import 'package:tikka/features/profile/domain/profile_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.repository,
    required this.authRepository,
  });

  final ProfileRepository repository;
  final AuthRepository authRepository;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  CustomerProfile? _profile;
  String? _error;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final profile = await widget.repository.getCurrentProfile();
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } on ProfileFailure catch (failure) {
      if (!mounted) return;
      setState(() {
        _error = failure.userMessage;
        _isLoading = false;
      });
    }
  }

  Future<void> _editProfile() async {
    await Navigator.of(context)
        .pushNamed(AppRoutes.editProfile, arguments: _profile);
    if (mounted) {
      _loadProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: TikkaLoadingState(message: 'Loading profile…'),
      );
    }
    if (_error != null) {
      return Center(
        child: TikkaErrorState(message: _error!, onRetry: _loadProfile),
      );
    }
    final profile = _profile;
    if (profile == null) {
      return const Center(
        child: TikkaEmptyState(
          title: 'Profile unavailable',
          message: 'We could not find your profile.',
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.large),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _ProfileSummary(
                profile: profile,
                email: widget.authRepository.currentSnapshot?.email,
              ),
              const SizedBox(height: AppSpacing.large),
              TikkaButton(
                label: 'Edit Profile',
                onPressed: _editProfile,
                fullWidth: true,
              ),
              const SizedBox(height: AppSpacing.large),
              _ProfileRow(
                icon: Icons.notifications_none,
                label: 'Notifications',
              ),
              _ProfileRow(
                icon: Icons.language,
                label: 'Language',
                value: 'English',
              ),
              _ProfileRow(icon: Icons.help_outline, label: 'Help & Support'),
              _ProfileRow(icon: Icons.lock_outline, label: 'Privacy'),
              const SizedBox(height: AppSpacing.medium),
              ProfileLogoutAction(repository: widget.authRepository),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileSummary extends StatelessWidget {
  const _ProfileSummary({required this.profile, this.email});

  final CustomerProfile profile;
  final String? email;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.brandYellow,
              child: Text(
                profile.fullName.trim().isEmpty
                    ? '?'
                    : profile.fullName.trim()[0].toUpperCase(),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: AppSpacing.medium),
            Text(
              profile.fullName,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (email != null) ...<Widget>[
              const SizedBox(height: AppSpacing.xSmall),
              Text(email!, style: Theme.of(context).textTheme.bodyMedium),
            ],
            const SizedBox(height: AppSpacing.large),
            _Detail(
              label: 'Phone number',
              value: profile.phoneNumber ?? 'Not added',
            ),
            _Detail(
              label: 'Saved address',
              value: profile.savedAddress ?? 'Not added',
            ),
          ],
        ),
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: AppSpacing.medium),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xSmall),
        Text(value, style: Theme.of(context).textTheme.bodyLarge),
      ],
    ),
  );
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.icon, required this.label, this.value});

  final IconData icon;
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon),
    title: Text(label),
    trailing: value == null ? const Icon(Icons.chevron_right) : Text(value!),
  );
}
