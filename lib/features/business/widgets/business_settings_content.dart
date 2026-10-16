import 'package:flutter/material.dart';

import 'package:locora/features/business/models/business_profile.dart';
import 'package:locora/features/business/widgets/business_api_key_panel.dart';

class BusinessSettingsContent extends StatefulWidget {
  const BusinessSettingsContent({
    super.key,
    required this.profile,
    required this.onRegenerateApiKey,
    this.onMenuTap,
  });

  final BusinessProfile? profile;
  final Future<String> Function() onRegenerateApiKey;
  final VoidCallback? onMenuTap;

  @override
  State<BusinessSettingsContent> createState() =>
      _BusinessSettingsContentState();
}

class _BusinessSettingsContentState extends State<BusinessSettingsContent> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  String? _category;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _applyProfile(widget.profile);
    _addressController.addListener(_markChanged);
  }

  @override
  void didUpdateWidget(covariant BusinessSettingsContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile?.id != widget.profile?.id ||
        oldWidget.profile?.name != widget.profile?.name ||
        oldWidget.profile?.email != widget.profile?.email) {
      _applyProfile(widget.profile);
    }
  }

  void _applyProfile(BusinessProfile? profile) {
    if (profile == null) return;
    _nameController.text = profile.name;
    _emailController.text = profile.email;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController
      ..removeListener(_markChanged)
      ..dispose();
    super.dispose();
  }

  void _markChanged() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  void _discardChanges() {
    _applyProfile(widget.profile);
    _addressController.clear();
    setState(() {
      _category = null;
      _hasChanges = false;
    });
  }

  void _saveChanges() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Profile editing is not connected to a save service yet.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final wide = MediaQuery.sizeOf(context).width >= 920;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.onMenuTap != null) ...[
              IconButton(
                tooltip: 'Open navigation sidebar',
                onPressed: widget.onMenuTap,
                icon: const Icon(Icons.menu_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: colors.surfaceContainerLowest,
                  foregroundColor: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                      ),
                      children: [
                        const TextSpan(text: 'OPERATIONS  ›  '),
                        TextSpan(
                          text: 'SETTINGS',
                          style: TextStyle(color: colors.primary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    'Business Settings & Profile',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Manage your organization details and API credentials.',
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: colors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        LayoutBuilder(
          builder: (context, constraints) {
            final showSideBySide = wide && constraints.maxWidth >= 700;
            final identity = _OrganizationIdentityCard(
              profile: widget.profile,
              nameController: _nameController,
              emailController: _emailController,
              addressController: _addressController,
              category: _category,
              onCategoryChanged: (value) {
                setState(() {
                  _category = value;
                  _hasChanges = true;
                });
              },
            );
            final credentials = BusinessApiKeyPanel(
              businessId: widget.profile?.id,
              onRegenerate: widget.onRegenerateApiKey,
            );

            if (!showSideBySide) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [identity, const SizedBox(height: 16), credentials],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 7, child: identity),
                const SizedBox(width: 20),
                Expanded(flex: 4, child: credentials),
              ],
            );
          },
        ),
        const SizedBox(height: 18),
        Wrap(
          alignment: WrapAlignment.end,
          spacing: 10,
          runSpacing: 10,
          children: [
            OutlinedButton.icon(
              onPressed: _hasChanges ? _discardChanges : null,
              icon: const Icon(Icons.undo_rounded, size: 18),
              label: const Text('Discard Changes'),
            ),
            FilledButton.icon(
              onPressed: _hasChanges ? _saveChanges : null,
              icon: const Icon(Icons.settings_rounded, size: 18),
              label: const Text('Save Changes'),
            ),
          ],
        ),
      ],
    );
  }
}

class _OrganizationIdentityCard extends StatelessWidget {
  const _OrganizationIdentityCard({
    required this.profile,
    required this.nameController,
    required this.emailController,
    required this.addressController,
    required this.category,
    required this.onCategoryChanged,
  });

  final BusinessProfile? profile;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController addressController;
  final String? category;
  final ValueChanged<String?> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final width = MediaQuery.sizeOf(context).width;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.business_outlined, color: colors.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Organization Identity',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Business details shown to your customers and delivery team.',
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                if (profile?.emailVerified == true) ...[
                  const SizedBox(width: 8),
                  Tooltip(
                    message: 'Business email verified',
                    child: Icon(
                      Icons.verified_rounded,
                      size: 18,
                      color: colors.secondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Divider(height: 1, color: colors.surfaceContainer),
          Padding(
            padding: const EdgeInsets.all(20),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final twoColumns = width >= 700 && constraints.maxWidth >= 480;
                final fieldWidth = twoColumns
                    ? (constraints.maxWidth - 14) / 2
                    : constraints.maxWidth;

                return Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: [
                    SizedBox(
                      width: fieldWidth,
                      child: _SettingsTextField(
                        label: 'BUSINESS OPERATING NAME',
                        hint: 'Enter your business name',
                        controller: nameController,
                        readOnly: true,
                      ),
                    ),
                    SizedBox(
                      width: fieldWidth,
                      child: _SettingsTextField(
                        label: 'SUPPORT DISPATCH EMAIL',
                        hint: 'dispatch@yourbusiness.com',
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.mail_outline_rounded,
                        readOnly: true,
                      ),
                    ),
                    // SizedBox(
                    //   width: constraints.maxWidth,
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       const _FieldLabel(label: 'PRIMARY BUSINESS CATEGORY'),
                    //       const SizedBox(height: 6),
                    //       DropdownButtonFormField<String>(
                    //         initialValue: category,
                    //         isExpanded: true,
                    //         hint: const Text('Select a business category'),
                    //         items: const [
                    //           DropdownMenuItem(
                    //             value: 'Courier & logistics',
                    //             child: Text('Courier & logistics'),
                    //           ),
                    //           DropdownMenuItem(
                    //             value: 'E-commerce',
                    //             child: Text('E-commerce'),
                    //           ),
                    //           DropdownMenuItem(
                    //             value: 'Retail',
                    //             child: Text('Retail'),
                    //           ),
                    //           DropdownMenuItem(
                    //             value: 'Other',
                    //             child: Text('Other'),
                    //           ),
                    //         ],
                    //         onChanged: onCategoryChanged,
                    //         decoration: _fieldDecoration(context),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // SizedBox(
                    //   width: constraints.maxWidth,
                    //   child: _SettingsTextField(
                    //     label: 'HEAD OFFICE / DISPATCH DEPOT ADDRESS',
                    //     hint: 'Enter your business address',
                    //     controller: addressController,
                    //     prefixIcon: Icons.location_on_outlined,
                    //   ),
                    // ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTextField extends StatelessWidget {
  const _SettingsTextField({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.prefixIcon,
    this.readOnly = false,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label: label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          decoration: _fieldDecoration(
            context,
            hint: hint,
            prefixIcon: prefixIcon,
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Text(
      label,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: colors.onSurfaceVariant,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
      ),
    );
  }
}

InputDecoration _fieldDecoration(
  BuildContext context, {
  String? hint,
  IconData? prefixIcon,
}) {
  final colors = Theme.of(context).colorScheme;
  return InputDecoration(
    hintText: hint,
    prefixIcon: prefixIcon == null
        ? null
        : Icon(prefixIcon, size: 18, color: colors.onSurfaceVariant),
    isDense: true,
    filled: true,
    fillColor: colors.surfaceContainerLow,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide: BorderSide(color: colors.outlineVariant),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide: BorderSide(color: colors.outlineVariant),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide: BorderSide(color: colors.primary, width: 1.4),
    ),
  );
}
