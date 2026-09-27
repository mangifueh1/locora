import 'package:flutter/material.dart';

import 'package:locora/shared/theme/app_colors.dart';
import 'package:locora/shared/theme/app_text_sizes.dart';
import 'package:locora/shared/widgets/buttons.dart';

class ContactForm extends StatefulWidget {
  const ContactForm({super.key});

  @override
  State<ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _businessController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _businessController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Thanks. We will be in touch shortly.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 900;
    return Container(
      padding: compact
          ? const EdgeInsets.fromLTRB(16, 16, 16, 14)
          : EdgeInsets.fromLTRB(25, 20, 25, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 420;
                final fields = [
                  _ContactField(
                    label: 'Full Name',
                    hint: 'Your full name',
                    controller: _nameController,
                    validator: _requiredValidator,
                  ),
                  _ContactField(
                    label: 'Email Address',
                    hint: 'you@company.com',
                    controller: _emailController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      if (!value.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  _ContactField(
                    label: 'Business Name',
                    hint: 'Acme Logistics, Retail Co., etc.',
                    controller: _businessController,
                    optional: true,
                  ),
                  const _InquiryTypeField(),
                ];

                if (isCompact) {
                  return Column(
                    children: fields
                        .map(
                          (field) => Padding(
                            padding: EdgeInsets.only(bottom: 14),
                            child: field,
                          ),
                        )
                        .toList(),
                  );
                }

                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  // mainAxisSpacing: 10,
                  childAspectRatio: 4.7,
                  children: fields,
                );
              },
            ),
            SizedBox(height: 6),
            _ContactField(
              label: 'Message',
              hint: 'Tell us about your delivery workflow and what you need...',
              controller: _messageController,
              validator: _requiredValidator,
              maxLines: 5,
            ),
            SizedBox(height: 17),
            compact
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule_outlined,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'We typically respond within 2–4 business hours.',
                              style: TextStyle(
                                fontSize: AppTextSizes.small,
                                height: 1.3,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      PrimaryButton(
                        height: 44,
                        label: 'Send Message',
                        onPressed: _submit,
                        suffixIcon: const Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: AppColors.onPrimary,
                        ),
                      ),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.schedule_outlined,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'We typically respond within 2–4 business hours.',
                          style: TextStyle(
                            fontSize: AppTextSizes.small,
                            height: 1.2,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      PrimaryButton(
                        width: 104,
                        height: 32,
                        label: 'Send Message',
                        labelSize: 8,
                        onPressed: _submit,
                        suffixIcon: Icon(
                          Icons.arrow_forward,
                          size: 12,
                          color: AppColors.onPrimary,
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    return value == null || value.trim().isEmpty ? 'Required' : null;
  }
}

class _ContactField extends StatelessWidget {
  const _ContactField({
    required this.label,
    required this.hint,
    required this.controller,
    this.validator,
    this.optional = false,
    this.maxLines = 1,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool optional;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: AppTextSizes.small,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            SizedBox(width: 3),
            Text(
              optional ? 'Optional' : '*',
              style: TextStyle(
                fontSize: 8,
                color: optional
                    ? AppColors.onSurfaceVariant
                    : AppColors.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: 5),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          style: TextStyle(
            fontSize: AppTextSizes.body,
            color: AppColors.onSurface,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: AppTextSizes.body,
              color: AppColors.outline,
            ),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 10,
              vertical: maxLines > 1 ? 11 : 12,
            ),
            border: _fieldBorder,
            enabledBorder: _fieldBorder,
            focusedBorder: _fieldBorder.copyWith(
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            errorBorder: _fieldBorder.copyWith(
              borderSide: const BorderSide(color: AppColors.error),
            ),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder get _fieldBorder => OutlineInputBorder(
    borderRadius: BorderRadius.circular(2),
    borderSide: BorderSide(
      color: AppColors.outlineVariant.withValues(alpha: 0.38),
    ),
  );
}

class _InquiryTypeField extends StatelessWidget {
  const _InquiryTypeField();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Subject',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            SizedBox(width: 3),
            Text('*', style: TextStyle(fontSize: 8, color: AppColors.primary)),
          ],
        ),
        SizedBox(height: 5),
        DropdownButtonFormField<String>(
          isExpanded: true,
          initialValue: null,
          validator: (value) => value == null ? 'Required' : null,
          items: const [
            DropdownMenuItem(
              value: 'integration',
              child: Text('Integration help'),
            ),
            DropdownMenuItem(
              value: 'business',
              child: Text('Business inquiry'),
            ),
            DropdownMenuItem(value: 'support', child: Text('Support')),
          ],
          onChanged: (_) {},
          style: TextStyle(fontSize: 9, color: AppColors.onSurface),
          decoration: InputDecoration(
            hintText: 'Select an inquiry type',
            hintStyle: TextStyle(
              fontSize: 9,
              color: AppColors.onSurfaceVariant,
            ),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2),
              borderSide: BorderSide(
                color: AppColors.outlineVariant.withValues(alpha: 0.38),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
