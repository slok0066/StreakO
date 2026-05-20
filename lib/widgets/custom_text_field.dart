import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String? placeholder;
  final TextEditingController controller;
  final bool isNumeric;
  final String? errorText;
  final int maxLines;
  final FocusNode? focusNode;

  const CustomTextField({
    Key? key,
    required this.label,
    this.placeholder,
    required this.controller,
    this.isNumeric = false,
    this.errorText,
    this.maxLines = 1,
    this.focusNode,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late FocusNode _internalFocusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _internalFocusNode = widget.focusNode ?? FocusNode();
    _internalFocusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _internalFocusNode.removeListener(_handleFocusChange);
    if (widget.focusNode == null) {
      _internalFocusNode.dispose();
    }
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _internalFocusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final labelColor = widget.errorText != null
        ? AppColors.accent
        : (_isFocused
            ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
            : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary));

    final bottomBorderColor = widget.errorText != null
        ? AppColors.accent
        : (_isFocused
            ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
            : (isDark ? AppColors.darkBorderVisible : AppColors.lightBorderVisible));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          widget.label.toUpperCase(),
          style: GoogleFonts.spaceMono(
            color: labelColor,
            fontSize: 11.0,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.08 * 11.0,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        // Input text field
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: bottomBorderColor,
                width: 1.0,
              ),
            ),
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _internalFocusNode,
            keyboardType: widget.isNumeric ? TextInputType.number : TextInputType.text,
            maxLines: widget.maxLines,
            style: GoogleFonts.spaceMono(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              fontSize: 16.0,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              hintText: widget.placeholder,
              hintStyle: GoogleFonts.spaceGrotesk(
                color: isDark ? AppColors.darkTextDisabled : AppColors.lightTextDisabled,
                fontSize: 16.0,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
              isDense: true,
            ),
          ),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            widget.errorText!,
            style: GoogleFonts.spaceMono(
              color: AppColors.accent,
              fontSize: 11.0,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ],
    );
  }
}
