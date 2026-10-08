import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:locora/features/auth/models/business_registration.dart';
import 'package:locora/features/auth/providers/auth_providers.dart';
import 'package:locora/shared/widgets/buttons.dart';
import 'package:locora/shared/widgets/navbar.dart';

class BusinessCredentialsScreen extends ConsumerStatefulWidget {
  const BusinessCredentialsScreen({super.key, required this.registration});

  final BusinessRegistration registration;

  @override
  ConsumerState<BusinessCredentialsScreen> createState() =>
      _BusinessCredentialsScreenState();
}

class _BusinessCredentialsScreenState
    extends ConsumerState<BusinessCredentialsScreen> {
  bool _resending = false;
  String? _resendMessage;
  String? _resendError;

  Future<void> _resendVerification() async {
    setState(() {
      _resending = true;
      _resendMessage = null;
      _resendError = null;
    });
    try {
      await ref
          .read(authApiProvider)
          .resendBusinessVerification(email: widget.registration.email);
      if (mounted) {
        setState(() {
          _resendMessage = 'If an unverified account with that email exists, verification instructions have been sent.';
        });
      }
    } catch (error) {
      if (mounted) setState(() => _resendError = error.toString());
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  Future<void> _copy(BuildContext context, String value, String label) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$label copied')));
  }

  @override
  Widget build(BuildContext context) {
    final registration = widget.registration;
    final theme = Theme.of(context);
    final compact = MediaQuery.sizeOf(context).width < 520;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Navbar(),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(compact ? 16 : 24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Card(
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.all(compact ? 20 : 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Icon(
                              Icons.verified_outlined,
                              size: 42,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Business account created',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              registration.note.isNotEmpty ? registration.note : 'Copy your API key now. It will not be shown again.',
                              textAlign: TextAlign.center,
                            ),
                            if (registration.emailVerificationRequired) ...[
                              const SizedBox(height: 20),
                              Text(
                                'Verify your email to activate your account',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                registration.verificationEmailSent
                                    ? 'A verification link was sent to ${registration.email}. Open it to finish setting up your account.'
                                    : 'We could not send the verification email. Request another link below.',
                              ),
                              if (_resendMessage != null) ...[
                                const SizedBox(height: 8),
                                Text(_resendMessage!),
                              ],
                              if (_resendError != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  _resendError!,
                                  style: TextStyle(
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                              ],
                              TextButton.icon(
                                onPressed: _resending
                                    ? null
                                    : _resendVerification,
                                icon: _resending
                                    ? const SizedBox.square(
                                        dimension: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.mark_email_unread_outlined,
                                      ),
                                label: const Text('Resend verification email'),
                              ),
                            ],
                            const SizedBox(height: 24),
                            _CredentialRow(
                              label: 'Business ID',
                              value: registration.businessId,
                              onCopy: () => _copy(
                                context,
                                registration.businessId,
                                'Business ID',
                              ),
                            ),
                            const SizedBox(height: 14),
                            _CredentialRow(
                              label: 'API key',
                              value: registration.apiKey,
                              onCopy: () => _copy(
                                context,
                                registration.apiKey,
                                'API key',
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.errorContainer
                                    .withValues(alpha: 0.45),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: theme.colorScheme.error,
                                  ),
                                  const SizedBox(width: 10),
                                  const Expanded(
                                    child: Text(
                                      'Treat the API key like a password. Store it in your server-side secrets, not in a public client or source repository. It cannot be used until your email is verified.',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 22),
                            PrimaryButton(
                              label: 'Continue to Business Login',
                              onPressed: () => context.go('/business/login'),
                              height: 44,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CredentialRow extends StatelessWidget {
  const _CredentialRow({
    required this.label,
    required this.value,
    required this.onCopy,
  });

  final String label;
  final String value;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Row(
            children: [
              Expanded(
                child: SelectableText(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Copy $label',
                onPressed: onCopy,
                icon: const Icon(Icons.content_copy_rounded),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
