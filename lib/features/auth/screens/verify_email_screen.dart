import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:locora/core/network/api_client.dart';
import 'package:locora/features/auth/providers/auth_providers.dart';
import 'package:locora/shared/widgets/buttons.dart';
import 'package:locora/shared/widgets/navbar.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key, required this.token});

  final String token;

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  bool _loading = true;
  bool _verified = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _verifyEmail());
  }

  Future<void> _verifyEmail() async {
    final token = widget.token.trim();
    if (token.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'This verification link is invalid or expired.';
      });
      return;
    }

    try {
      await ref.read(authApiProvider).verifyBusinessEmail(token: token);
      if (mounted) setState(() => _verified = true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error is ApiExeption && error.statusCode == 400
            ? 'This verification link is invalid or expired.'
            : error.toString();
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Card(
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.all(compact ? 20 : 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Icon(
                              _verified
                                  ? Icons.mark_email_read_outlined
                                  : Icons.mark_email_unread_outlined,
                              size: 42,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _verified
                                  ? 'Email verified'
                                  : 'Verify your email',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (_loading)
                              const Center(child: CircularProgressIndicator())
                            else
                              Text(
                                _verified
                                    ? 'Your business account is ready. You can now log in.'
                                    : _error ?? 'We could not verify this email address.',
                                textAlign: TextAlign.center,
                                style: _error != null
                                    ? TextStyle(color: theme.colorScheme.error)
                                    : null,
                              ),
                            const SizedBox(height: 24),
                            PrimaryButton(
                              label: 'Continue to Business Login',
                              onPressed: _loading
                                  ? null
                                  : () => context.go('/business/login'),
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
