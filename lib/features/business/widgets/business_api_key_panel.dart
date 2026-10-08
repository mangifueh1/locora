import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:locora/shared/theme/app_colors.dart';

class BusinessApiKeyPanel extends StatefulWidget {
  const BusinessApiKeyPanel({
    super.key,
    required this.businessId,
    required this.onRegenerate,
  });

  final String? businessId;
  final Future<String> Function() onRegenerate;

  @override
  State<BusinessApiKeyPanel> createState() => _BusinessApiKeyPanelState();
}

class _BusinessApiKeyPanelState extends State<BusinessApiKeyPanel> {
  bool _isRegenerating = false;

  Future<void> _confirmRegeneration() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(color: AppColors.outlineVariant),
        ),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
        actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        title: Row(
          children: [
            const Icon(Icons.key_rounded, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Generate new API key?',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'The current API key will stop working immediately. The new key will be shown once, so copy it to your server-side secrets.',
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Generate key'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isRegenerating = true);
    try {
      final newApiKey = await widget.onRegenerate();
      if (!mounted) return;
      await _showGeneratedKey(newApiKey);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not replace API key: $error')),
      );
    } finally {
      if (mounted) setState(() => _isRegenerating = false);
    }
  }

  Future<void> _showGeneratedKey(String apiKey) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        var copied = false;
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            backgroundColor: AppColors.surfaceContainerLowest,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              side: BorderSide(color: AppColors.outlineVariant),
            ),
            titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
            actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            title: Row(
              children: [
                const Icon(Icons.vpn_key_rounded, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your new API key',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Copy and store this key now. It will not be shown again.',
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: SelectableText(
                    apiKey,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurface,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Close'),
              ),
              FilledButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: apiKey));
                  setDialogState(() => copied = true);
                },
                icon: Icon(
                  copied ? Icons.check_rounded : Icons.content_copy_rounded,
                ),
                label: Text(copied ? 'Copied' : 'Copy key'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _copyValue(String? value, String label) async {
    if (value == null) return;

    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$label copied')));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final businessId = widget.businessId;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.key_rounded, color: colors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'API access',
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'Production credential',
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: _isRegenerating ? null : _confirmRegeneration,
              icon: _isRegenerating
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.autorenew_rounded),
              label: Text(
                _isRegenerating ? 'Generating...' : 'Generate new API key',
              ),
            ),
          ),
          const SizedBox(height: 16),
          _CredentialValueField(
            label: 'Business ID',
            value: businessId ?? 'Unavailable',
            onCopy: () => _copyValue(businessId, 'Business ID'),
          ),
          const SizedBox(height: 9),
          Text(
            'API keys are not stored in this app. Generate a new key to reveal it once; this invalidates the current key.',
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _CredentialValueField extends StatelessWidget {
  const _CredentialValueField({
    required this.label,
    required this.value,
    this.onCopy,
    this.actions = const [],
  });

  final String label;
  final String value;
  final VoidCallback? onCopy;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ),
        Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.fromLTRB(14, 4, 4, 4),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: SelectableText(
                  value,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ...actions,
              if (onCopy != null)
                IconButton(
                  tooltip: 'Copy $label',
                  onPressed: onCopy,
                  icon: const Icon(Icons.content_copy_rounded),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
