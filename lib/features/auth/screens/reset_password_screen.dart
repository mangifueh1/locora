import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:locora/features/auth/providers/auth_providers.dart';
import 'package:locora/shared/widgets/buttons.dart';
import 'package:locora/shared/widgets/locora_text_field.dart';
import 'package:locora/shared/widgets/navbar.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key, required this.token});

  final String token;

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (widget.token.isEmpty) {
      setState(() => _error = 'This password reset link is invalid.');
      return;
    }
    if (_password.text.isEmpty || _confirmPassword.text.isEmpty) {
      setState(() => _error = 'Enter and confirm your new password.');
      return;
    }
    if (_password.text != _confirmPassword.text) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref
          .read(authApiProvider)
          .resetBusinessPassword(token: widget.token, password: _password.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset. You can now log in.')),
      );
      context.go('/business/login');
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 520;
    final theme = Theme.of(context);

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
                            Text(
                              'Set a new password',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Choose a new password for your business account.',
                            ),
                            const SizedBox(height: 24),
                            LocoraTextField(
                              label: 'New Password',
                              hint: 'Enter your new password',
                              controller: _password,
                              obscureText: true,
                              textInputAction: TextInputAction.next,
                            ),
                            LocoraTextField(
                              label: 'Confirm Password',
                              hint: 'Re-enter your new password',
                              controller: _confirmPassword,
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                            ),
                            if (_error != null) ...[
                              Text(
                                _error!,
                                style: TextStyle(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                            PrimaryButton(
                              label: 'Reset Password',
                              onPressed: _loading ? null : _resetPassword,
                              height: 44,
                              isLoading: _loading,
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
