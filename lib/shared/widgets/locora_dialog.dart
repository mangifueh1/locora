import 'package:flutter/material.dart';
import 'package:locora/shared/theme/app_colors.dart';

class LocoraDialog extends StatelessWidget {
  const LocoraDialog({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
    this.icon,
  });

  final Widget title;
  final Widget content;
  final List<Widget> actions;
  final IconData? icon;

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget title,
    required Widget content,
    required List<Widget> actions,
    IconData? icon,
    bool barrierDismissible = true,
  }) => showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (_) => LocoraDialog(
      title: title,
      content: content,
      actions: actions,
      icon: icon,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      backgroundColor: AppColors.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: const BorderSide(color: AppColors.outlineVariant),
      ),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      title: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: DefaultTextStyle.merge(
              style: theme.textTheme.titleLarge!.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w700,
              ),
              child: title,
            ),
          ),
        ],
      ),
      content: DefaultTextStyle.merge(
        style: theme.textTheme.bodyMedium!.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
        child: content,
      ),
      actions: actions,
    );
  }
}
