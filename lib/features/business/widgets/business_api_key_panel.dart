import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BusinessApiKeyPanel extends StatefulWidget {
  const BusinessApiKeyPanel({
    super.key,
    required this.businessId,
    required this.apiKey,
  });

  final String? businessId;
  final String? apiKey;

  @override
  State<BusinessApiKeyPanel> createState() => _BusinessApiKeyPanelState();
}

class _BusinessApiKeyPanelState extends State<BusinessApiKeyPanel> {
  bool _isVisible = false;

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
    final key = widget.apiKey;
    final businessId = widget.businessId;
    final keyLabel = key == null
        ? 'No API key stored'
        : _isVisible
        ? key
        : '${key.substring(0, key.length < 8 ? key.length : 8)} ••••••••••••';

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
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final fields = [
                _CredentialValueField(
                  label: 'Business ID',
                  value: businessId ?? 'Unavailable',
                  onCopy: () => _copyValue(businessId, 'Business ID'),
                ),
                _CredentialValueField(
                  label: 'Live API key',
                  value: keyLabel,
                  actions: [
                    if (key != null) ...[
                      IconButton(
                        tooltip: _isVisible ? 'Hide API key' : 'Show API key',
                        onPressed: () =>
                            setState(() => _isVisible = !_isVisible),
                        icon: Icon(
                          _isVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                      IconButton(
                        tooltip: 'Copy API key',
                        onPressed: () => _copyValue(key, 'API key'),
                        icon: const Icon(Icons.content_copy_rounded),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ],
                ),
              ];

              if (constraints.maxWidth < 560) {
                return Column(
                  children: [fields[0], const SizedBox(height: 12), fields[1]],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: fields[0]),
                  const SizedBox(width: 14),
                  Expanded(child: fields[1]),
                ],
              );
            },
          ),
          const SizedBox(height: 9),
          Text(
            key == null
                ? 'Add a production key to authenticate requests from your business application.'
                : 'Keep this key private. It authenticates requests from your business application.',
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
