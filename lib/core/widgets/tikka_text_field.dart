import 'package:flutter/material.dart';
import 'package:tikka/app/theme/app_theme.dart';

class TikkaTextField extends StatefulWidget {
  const TikkaTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.controller,
    this.focusNode,
    this.errorText,
    this.enabled = true,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.autofillHints,
    this.maxLines = 1,
    this.height = 72,
    this.onSubmitted,
  });

  final String label;
  final String hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? errorText;
  final bool enabled;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final Iterable<String>? autofillHints;
  final int maxLines;
  final double height;
  final ValueChanged<String>? onSubmitted;

  @override
  State<TikkaTextField> createState() => _TikkaTextFieldState();
}

class _TikkaTextFieldState extends State<TikkaTextField> {
  bool _hasFocus = false;

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;
    final borderColor = !widget.enabled
        ? AppColors.border
        : hasError
        ? AppColors.error
        : _hasFocus
        ? AppColors.textPrimary
        : AppColors.border;
    final textTheme = Theme.of(context).textTheme;
    final labelColor = !widget.enabled
        ? AppColors.textSecondary
        : hasError
        ? AppColors.error
        : AppColors.textSecondary;

    return Semantics(
      label: widget.label,
      hint: widget.errorText ?? widget.hintText,
      textField: true,
      liveRegion: hasError,
      child: SizedBox(
        height: widget.height,
        child: Focus(
          onFocusChange: (hasFocus) {
            if (_hasFocus != hasFocus) {
              setState(() => _hasFocus = hasFocus);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: widget.enabled
                  ? AppColors.surface
                  : AppColors.disabledField,
              borderRadius: BorderRadius.circular(AppRadii.input),
              border: Border.all(
                color: borderColor,
                width: _hasFocus && !hasError && widget.enabled ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  widget.label,
                  style: textTheme.bodySmall?.copyWith(color: labelColor),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    focusNode: widget.focusNode,
                    enabled: widget.enabled,
                    obscureText: widget.obscureText,
                    keyboardType: widget.keyboardType,
                    textInputAction: widget.textInputAction,
                    onChanged: widget.onChanged,
                    onSubmitted: widget.onSubmitted,
                    autofillHints: widget.autofillHints,
                    maxLines: widget.obscureText ? 1 : widget.maxLines,
                    textAlignVertical: TextAlignVertical.top,
                    style: textTheme.bodyMedium?.copyWith(
                      color: widget.enabled
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                    decoration: InputDecoration.collapsed(
                      hintText: widget.errorText ?? widget.hintText,
                      hintStyle: textTheme.bodyMedium?.copyWith(
                        color: hasError || !widget.enabled
                            ? labelColor
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
