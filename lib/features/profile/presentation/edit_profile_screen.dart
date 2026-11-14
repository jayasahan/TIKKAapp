import 'package:flutter/material.dart';
import 'package:tikka/app/theme/app_theme.dart';
import 'package:tikka/core/widgets/tikka_button.dart';
import 'package:tikka/core/widgets/tikka_states.dart';
import 'package:tikka/core/widgets/tikka_text_field.dart';
import 'package:tikka/features/profile/domain/customer_profile.dart';
import 'package:tikka/features/profile/domain/profile_failure.dart';
import 'package:tikka/features/profile/domain/profile_repository.dart';
import 'package:tikka/features/profile/domain/profile_validators.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    required this.repository,
    this.initialProfile,
  });

  final ProfileRepository repository;
  final CustomerProfile? initialProfile;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  String? _nameError;
  String? _phoneError;
  String? _addressError;
  String? _formError;
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final profile = widget.initialProfile;
    _nameController = TextEditingController(text: profile?.fullName);
    _phoneController = TextEditingController(text: profile?.phoneNumber);
    _addressController = TextEditingController(text: profile?.savedAddress);
    if (profile == null) {
      _loadProfile();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final profile = await widget.repository.getCurrentProfile();
      if (!mounted) return;
      _nameController.text = profile.fullName;
      _phoneController.text = profile.phoneNumber ?? '';
      _addressController.text = profile.savedAddress ?? '';
    } on ProfileFailure catch (failure) {
      if (mounted) setState(() => _formError = failure.userMessage);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    final nameError = ProfileValidators.fullName(_nameController.text);
    final phoneError = ProfileValidators.phoneNumber(_phoneController.text);
    final addressError = ProfileValidators.savedAddress(
      _addressController.text,
    );
    setState(() {
      _nameError = nameError;
      _phoneError = phoneError;
      _addressError = addressError;
      _formError = null;
    });
    if (nameError != null || phoneError != null || addressError != null) return;

    setState(() => _isSaving = true);
    try {
      await widget.repository.updateCurrentProfile(
        fullName: _nameController.text,
        phoneNumber: _phoneController.text,
        savedAddress: _addressController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully.')),
      );
      Navigator.of(context).pop();
    } on ProfileFailure catch (failure) {
      if (mounted) setState(() => _formError = failure.userMessage);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: TikkaLoadingState(message: 'Loading profile…')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
        ),
        title: const Text('Edit profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TikkaTextField(
                  label: 'Full name',
                  hintText: 'Enter your full name',
                  controller: _nameController,
                  errorText: _nameError,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => setState(() => _nameError = null),
                ),
                const SizedBox(height: AppSpacing.medium),
                TikkaTextField(
                  label: 'Phone number',
                  hintText: 'Enter your phone number',
                  controller: _phoneController,
                  errorText: _phoneError,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => setState(() => _phoneError = null),
                ),
                const SizedBox(height: AppSpacing.medium),
                TikkaTextField(
                  label: 'Address',
                  hintText: 'Enter your saved address',
                  controller: _addressController,
                  errorText: _addressError,
                  maxLines: 3,
                  height: 110,
                  textInputAction: TextInputAction.done,
                  onChanged: (_) => setState(() => _addressError = null),
                ),
                if (_formError != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.medium),
                  Text(
                    _formError!,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: AppColors.error),
                  ),
                ],
                const SizedBox(height: AppSpacing.large),
                TikkaButton(
                  label: _isSaving ? 'Saving…' : 'Save changes',
                  onPressed: _isSaving ? null : _save,
                  fullWidth: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
