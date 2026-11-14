import 'package:flutter/material.dart';
import 'package:tikka/app/router/app_routes.dart';
import 'package:tikka/app/theme/app_theme.dart';
import 'package:tikka/core/widgets/tikka_app_bar.dart';
import 'package:tikka/core/widgets/tikka_button.dart';
import 'package:tikka/core/widgets/tikka_states.dart';
import 'package:tikka/features/auth/domain/auth_repository.dart';
import 'package:tikka/features/bookings/domain/booking_draft.dart';
import 'package:tikka/features/services/domain/service.dart';
import 'package:tikka/features/services/domain/services_repository.dart';

class BookingFormScreen extends StatefulWidget {
  const BookingFormScreen({
    super.key,
    required this.serviceId,
    required this.servicesRepository,
    this.authRepository,
    this.initialDraft,
  });

  final String serviceId;
  final ServicesRepository servicesRepository;
  final AuthRepository? authRepository;
  final BookingDraft? initialDraft;

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _problemController;
  late TextEditingController _addressController;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  Service? _service;
  bool _isLoading = true;
  String? _errorMessage;

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedTime = '10:00 AM';
  String? _attachedPhotoName;

  static const _availableTimeSlots = <String>[
    '09:00 AM',
    '10:00 AM',
    '11:30 AM',
    '02:00 PM',
    '04:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    final draft = widget.initialDraft;
    _problemController = TextEditingController(
      text: draft?.problemDescription ?? '',
    );
    _addressController = TextEditingController(
      text: draft?.serviceAddress ?? 'Matara, Sri Lanka',
    );

    final userEmail = widget.authRepository?.currentSnapshot?.email;
    final defaultName = userEmail != null && userEmail.contains('@')
        ? userEmail.split('@').first
        : 'Customer';

    _nameController = TextEditingController(
      text: draft?.contactName.isNotEmpty == true
          ? draft!.contactName
          : defaultName,
    );
    _phoneController = TextEditingController(
      text: draft?.contactPhone.isNotEmpty == true
          ? draft!.contactPhone
          : '077 123 4567',
    );

    if (draft != null) {
      _selectedDate = draft.preferredDate;
      _selectedTime = draft.preferredTime;
      _attachedPhotoName = draft.localPhotoPath;
    }

    _loadService();
  }

  @override
  void dispose() {
    _problemController.dispose();
    _addressController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadService() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final service = await widget.servicesRepository.getServiceById(
        widget.serviceId,
      );
      if (!mounted) return;
      setState(() {
        _service = service;
        _isLoading = false;
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Could not load service information.';
        _isLoading = false;
      });
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(now) ? now : _selectedDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.textPrimary,
              onPrimary: AppColors.surface,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _onContinue() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final serviceName = _service?.name ?? 'Service';
    final draft = BookingDraft(
      serviceId: widget.serviceId,
      serviceName: serviceName,
      serviceDescription: _service?.description,
      problemDescription: _problemController.text.trim(),
      serviceAddress: _addressController.text.trim(),
      contactName: _nameController.text.trim(),
      contactPhone: _phoneController.text.trim(),
      preferredDate: _selectedDate,
      preferredTime: _selectedTime,
      localPhotoPath: _attachedPhotoName,
    );

    Navigator.of(context)
        .pushNamed(AppRoutes.bookingConfirmation, arguments: draft);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        appBar: TikkaAppBar(eyebrow: 'TIKKA', title: 'Request Service'),
        body: Center(child: TikkaLoadingState(message: 'Loading service…')),
      );
    }

    if (_errorMessage != null || _service == null) {
      return Scaffold(
        appBar: const TikkaAppBar(eyebrow: 'TIKKA', title: 'Request Service'),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: TikkaEmptyState(
              title: 'Service not found',
              message: _errorMessage ?? 'Invalid service selected.',
            ),
          ),
        ),
      );
    }

    final service = _service!;
    final dateFormatted =
        '${_selectedDate.day} ${_monthName(_selectedDate.month)} ${_selectedDate.year}';

    return Scaffold(
      appBar: TikkaAppBar(
        eyebrow: 'Step 1 of 2',
        title: 'Request ${service.name}',
        onBackPressed: () => Navigator.of(context).maybePop(),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.page,
              vertical: AppSpacing.large,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Yellow Selected Service Card (Figma Screen 06)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.large),
                      decoration: BoxDecoration(
                        color: AppColors.brandYellow,
                        borderRadius: BorderRadius.circular(AppRadii.card),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            service.name,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.xSmall),
                          Text(
                            service.description,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xLarge),

                    // Problem / Job Description (Required)
                    Text(
                      'Problem / job description',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.small),
                    TextFormField(
                      controller: _problemController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'e.g. Leaking kitchen tap under the sink, needs urgent fix',
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadii.input),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadii.input),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadii.input),
                          borderSide: const BorderSide(
                            color: AppColors.brandYellow,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter problem or job details';
                        }
                        if (value.trim().length < 5) {
                          return 'Please describe the problem in more detail (min 5 chars)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.large),

                    // Service Address (Required)
                    Text(
                      'Address',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.small),
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        hintText: 'Enter service address',
                        prefixIcon: const Icon(
                          Icons.location_on_outlined,
                          color: AppColors.textSecondary,
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadii.input),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadii.input),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadii.input),
                          borderSide: const BorderSide(
                            color: AppColors.brandYellow,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter service location address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.large),

                    // Preferred Date & Preferred Time Row (Figma Screen 06)
                    Row(
                      children: <Widget>[
                        // Date Picker Card
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Preferred date',
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.small),
                              InkWell(
                                onTap: _pickDate,
                                borderRadius: BorderRadius.circular(
                                  AppRadii.input,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.medium,
                                    vertical: AppSpacing.large,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(
                                      AppRadii.input,
                                    ),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(
                                        dateFormatted,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      const Icon(
                                        Icons.calendar_today_outlined,
                                        size: 18,
                                        color: AppColors.textSecondary,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.medium),

                        // Time Slot Dropdown
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Preferred time',
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.small),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.medium,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(
                                    AppRadii.input,
                                  ),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedTime,
                                    isExpanded: true,
                                    items: _availableTimeSlots
                                        .map(
                                          (slot) => DropdownMenuItem(
                                            value: slot,
                                            child: Text(
                                              slot,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() => _selectedTime = val);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.large),

                    // Contact Details
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Contact name',
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.small),
                              TextFormField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AppColors.surface,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppRadii.input,
                                    ),
                                    borderSide: const BorderSide(
                                      color: AppColors.border,
                                    ),
                                  ),
                                ),
                                validator: (v) => v == null || v.trim().isEmpty
                                    ? 'Name required'
                                    : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.medium),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Phone number',
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.small),
                              TextFormField(
                                controller: _phoneController,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AppColors.surface,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppRadii.input,
                                    ),
                                    borderSide: const BorderSide(
                                      color: AppColors.border,
                                    ),
                                  ),
                                ),
                                validator: (v) => v == null || v.trim().isEmpty
                                    ? 'Phone required'
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.large),

                    // Optional Photo (Figma: "Optional photo" / "+ Add photo")
                    Text(
                      'Optional photo',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Add one photo to help us understand the job.',
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.small),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _attachedPhotoName = _attachedPhotoName == null
                              ? 'job_photo_attached.jpg'
                              : null;
                        });
                      },
                      borderRadius: BorderRadius.circular(AppRadii.input),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.large,
                          vertical: AppSpacing.medium,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadii.input),
                          border: Border.all(
                            color: _attachedPhotoName != null
                                ? AppColors.success
                                : AppColors.border,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              _attachedPhotoName != null
                                  ? Icons.check_circle_outline
                                  : Icons.add_photo_alternate_outlined,
                              color: _attachedPhotoName != null
                                  ? AppColors.success
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: AppSpacing.medium),
                            Expanded(
                              child: Text(
                                _attachedPhotoName ?? '+ Add photo',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: _attachedPhotoName != null
                                          ? AppColors.success
                                          : AppColors.textPrimary,
                                    ),
                              ),
                            ),
                            if (_attachedPhotoName != null)
                              IconButton(
                                icon: const Icon(Icons.close, size: 18),
                                onPressed: () {
                                  setState(() => _attachedPhotoName = null);
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xLarge),

                    // Continue Button
                    TikkaButton(
                      label: 'Continue',
                      fullWidth: true,
                      onPressed: _onContinue,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
