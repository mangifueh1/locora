import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:locora/shared/theme/app_colors.dart';
import 'package:locora/shared/widgets/locora_dialog.dart';

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
      builder: (context) => LocoraDialog(
        title: const Text('Generate new API key?'),
        icon: Icons.key_rounded,
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
      setState(() => _isRegenerating = false);
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
      builder: (_) => _GeneratedApiKeyDialog(apiKey: apiKey),
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
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.fingerprint_rounded, color: colors.primary, size: 19),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'NODE CREDENTIALS',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'PERMANENT BUSINESS ID',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.35,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.verified_rounded,
                      size: 15,
                      color: colors.secondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'VERIFIED',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colors.secondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _CredentialValueField(
                  label: '',
                  value: businessId ?? 'Loading business ID...',
                  onCopy: businessId == null
                      ? null
                      : () => _copyValue(businessId, 'Business ID'),
                ),
                const SizedBox(height: 8),
                Text(
                  'Share this ID with couriers to connect them to your dispatch fleet.',
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'API KEY',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.35,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Generate a key for secure server-to-server API access.',
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: colors.onSurfaceVariant),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _isRegenerating ? null : _confirmRegeneration,
                  icon: _isRegenerating
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.key_rounded, size: 17),
                  label: Text(
                    _isRegenerating ? 'Generating...' : 'Regenerate API key',
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'The key is shown once. Generating a new key invalidates the current one.',
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GeneratedApiKeyDialog extends StatefulWidget {
  const _GeneratedApiKeyDialog({required this.apiKey});

  final String apiKey;

  @override
  State<_GeneratedApiKeyDialog> createState() => _GeneratedApiKeyDialogState();
}

class _GeneratedApiKeyDialogState extends State<_GeneratedApiKeyDialog> {
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    return LocoraDialog(
      title: const Text('Your new API key'),
      icon: Icons.vpn_key_rounded,
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
              widget.apiKey,
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
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        FilledButton.icon(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: widget.apiKey));
            if (mounted) setState(() => _copied = true);
          },
          icon: Icon(
            _copied ? Icons.check_rounded : Icons.content_copy_rounded,
          ),
          label: Text(_copied ? 'Copied' : 'Copy key'),
        ),
      ],
    );
  }
}

class _CredentialValueField extends StatelessWidget {
  const _CredentialValueField({
    required this.label,
    required this.value,
    this.onCopy,
  });

  final String label;
  final String value;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
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
          padding: const EdgeInsets.fromLTRB(9, 4, 4, 4),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
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
