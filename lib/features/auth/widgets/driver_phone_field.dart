import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:locora/shared/theme/app_colors.dart';
import 'package:locora/shared/theme/app_text_sizes.dart';

class DriverPhoneField extends StatelessWidget {
  const DriverPhoneField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.textInputAction,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final TextInputAction? textInputAction;

  void _onCountryChanged(Country country) {
    final number = controller.text;
    onChanged(number.isEmpty ? '' : '+${country.fullCountryCode}$number');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6,
        children: [
          Text(
            'Phone Number',
            style: TextStyle(
              fontSize: AppTextSizes.label,
              fontWeight: FontWeight.w600,
              color: AppColors.tertiary,
            ),
          ),
          IntlPhoneField(
            controller: controller,
            initialCountryCode: 'CM',
            textInputAction: textInputAction,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            disableLengthCheck: true,
            onChanged: (phone) => onChanged(phone.completeNumber),
            onCountryChanged: _onCountryChanged,
            pickerDialogStyle: PickerDialogStyle(
              backgroundColor: AppColors.surfaceContainerLowest,
              countryNameStyle: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
              ),
              countryCodeStyle: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
              listTilePadding: const EdgeInsets.symmetric(horizontal: 12),
              listTileDivider: Divider(
                height: 1,
                color: AppColors.outlineVariant,
              ),
              padding: const EdgeInsets.all(16),
              searchFieldCursorColor: AppColors.primary,
              searchFieldPadding: const EdgeInsets.only(bottom: 8),
              searchFieldInputDecoration: InputDecoration(
                hintText: 'Search country',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: AppColors.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: AppColors.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(14),
              hintText: '600 000 001',
              hintStyle: TextStyle(color: AppColors.outlineVariant),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: AppColors.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: AppColors.outlineVariant),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
