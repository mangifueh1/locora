import 'package:flutter/material.dart';
import 'package:locora/shared/theme/app_colors.dart';

class PickerConfirmationPanel extends StatelessWidget {
  const PickerConfirmationPanel({
    super.key,
    required this.formKey,
    required this.descriptionController,
    required this.notesController,
    required this.coordinates,
    required this.isLoading,
    required this.isPreview,
    required this.isWide,
    required this.onConfirm,
    this.scrollController,
    this.onHandleTap,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController descriptionController;
  final TextEditingController notesController;
  final String coordinates;
  final bool isLoading;
  final bool isPreview;
  final bool isWide;
  final VoidCallback onConfirm;
  final ScrollController? scrollController;
  final VoidCallback? onHandleTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: isWide
            ? Border(
                left: BorderSide(
                  color: colors.outlineVariant.withValues(alpha: 0.5),
                ),
              )
            : null,
        borderRadius: isWide
            ? BorderRadius.zero
            : const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: isWide
            ? null
            : const [
                BoxShadow(
                  color: Color(0x1A0B2340),
                  blurRadius: 18,
                  offset: Offset(0, -5),
                ),
              ],
      ),
      child: SafeArea(
        top: false,
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            controller: scrollController,
            padding: EdgeInsets.fromLTRB(
              isWide ? 20 : 24,
              isWide ? 22 : 14,
              isWide ? 20 : 24,
              20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isWide)
                  Center(
                    child: GestureDetector(
                      onTap: onHandleTap,
                      behavior: HitTestBehavior.opaque,
                      child: SizedBox(
                        width: 72,
                        height: 24,
                        child: Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: colors.outlineVariant,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Confirm your location',
                        style: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    _StatusBadge(isPreview: isPreview),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  'Verify the pin on the map and add visual directions for the courier.',
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: colors.onSurfaceVariant, height: 1.4),
                ),
                const SizedBox(height: 16),
                _SelectedLocation(coordinates: coordinates),
                const SizedBox(height: 17),
                _FieldLabel(label: 'Location description', required: false),
                const SizedBox(height: 7),
                TextFormField(
                  controller: descriptionController,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Add a landmark or directions for the courier.'
                      : null,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.meeting_room_outlined),
                    hintText: 'e.g. Blue gate beside the pharmacy',
                  ),
                ),
                const SizedBox(height: 7),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, size: 15, color: colors.tertiary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Help the driver recognize your drop-off spot swiftly.',
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: colors.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                const _FieldLabel(label: 'Delivery notes', required: false),
                const SizedBox(height: 7),
                TextFormField(
                  controller: notesController,
                  minLines: 2,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 28),
                      child: Icon(Icons.notes_outlined),
                    ),
                    hintText: 'e.g. Call when you arrive',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 15),
                const _PrecisionNotice(),
                const SizedBox(height: 17),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: isLoading ? null : onConfirm,
                    icon: isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.arrow_forward),
                    label: Text(
                      isLoading ? 'Saving location' : 'Confirm location',
                    ),
                  ),
                ),
                if (isPreview) ...[
                  const SizedBox(height: 9),
                  Center(
                    child: Text(
                      'Preview only. Confirmation will not send data.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: colors.onSurfaceVariant),
                    ),
                  ),
                ],
                if (isWide) ...[
                  const SizedBox(height: 18),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: 13,
                        color: colors.secondary,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          'Locora Secure Spatial Handshake',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                      Text(
                        'v2.4',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isPreview});

  final bool isPreview;

  @override
  Widget build(BuildContext context) {
    final color = isPreview ? AppColors.tertiary : AppColors.secondary;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Text(
          isPreview ? 'PREVIEW' : 'READY',
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: color, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _SelectedLocation extends StatelessWidget {
  const _SelectedLocation({required this.coordinates});

  final String coordinates;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.location_on_outlined,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CONFIRMED TARGET',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  coordinates,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, required this.required});

  final String label;
  final bool required;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        Text(
          required ? 'Required' : 'Optional',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: required ? colors.error : colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _PrecisionNotice extends StatelessWidget {
  const _PrecisionNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.verified_user_outlined,
            color: AppColors.primary,
            size: 18,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Locora Precision Guarantee',
                  style: Theme.of(context).textTheme.labelMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  'The courier receives direct turn-by-turn guidance to this pin.',
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
