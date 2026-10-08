import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:locora/core/network/api_client.dart';
import 'package:locora/features/auth/widgets/role_tab.dart';

import 'package:locora/features/auth/providers/auth_providers.dart';
import 'package:locora/features/business/providers/business_providers.dart';
import 'package:locora/features/driver/providers/driver_providers.dart';
import 'package:locora/shared/theme/app_colors.dart';
import 'package:locora/shared/widgets/buttons.dart';
import 'package:locora/shared/widgets/navbar.dart';
import 'package:locora/shared/widgets/locora_text_field.dart';

enum LoginRole { business, driver }

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.initialRole = LoginRole.business});

  final LoginRole initialRole;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late LoginRole _role;

  final _businessName = TextEditingController();
  final _driverPhone = TextEditingController();
  final _businessPassword = TextEditingController();
  final _driverPassword = TextEditingController();

  bool _loading = false;
  String? _error;
  bool _unverifiedBusiness = false;
  bool _obscurePassword = true;

  TextEditingController get _name =>
      _role == LoginRole.business ? _businessName : _driverPhone;

  TextEditingController get _password =>
      _role == LoginRole.business ? _businessPassword : _driverPassword;

  @override
  void initState() {
    super.initState();
    _role = widget.initialRole;
  }

  @override
  void dispose() {
    _businessName.dispose();
    _driverPhone.dispose();
    _businessPassword.dispose();
    _driverPassword.dispose();
    super.dispose();
  }

  void _selectRole(LoginRole role) {
    if (_loading || role == _role) return;
    setState(() {
      _role = role;
      _error = null;
      _unverifiedBusiness = false;
    });
  }

  Future<void> _login() async {
    if (_name.text.trim().isEmpty || _password.text.isEmpty) {
      setState(() => _error = 'Please enter your login and password.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _unverifiedBusiness = false;
    });

    try {
      if (_role == LoginRole.business) {
        final result = await ref
            .read(authApiProvider)
            .loginBusiness(name: _name.text.trim(), password: _password.text);
        await ref.read(businessSessionProvider).saveToken(result.token);

        if (!mounted) return;
        context.pushReplacementNamed('/business/dashboard');
      } else {
        final result = await ref
            .read(authApiProvider)
            .loginDriver(phone: _name.text.trim(), password: _password.text);
        await ref.read(driverSessionProvider).saveToken(result.token);

        if (!mounted) return;
        context.pushReplacementNamed('/driver/dashboard');
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error.toString();
          _unverifiedBusiness =
              _role == LoginRole.business &&
              error is ApiExeption &&
              error.statusCode == 403;
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _showForgotPasswordDialog() async {
    final emailController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        var submitting = false;
        var sent = false;
        String? error;

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
                Icon(
                  sent ? Icons.mark_email_read_outlined : Icons.lock_reset,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    sent ? 'Check your email' : 'Reset your password',
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
                  sent
                      ? 'If an account with that email exists, password reset instructions have been sent.'
                      : 'Enter the email address for your business account.',
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: AppColors.onSurfaceVariant),
                ),
                if (!sent) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'you@example.com',
                      prefixIcon: Icon(Icons.mail_outline),
                      contentPadding: EdgeInsets.all(14),
                      labelStyle: TextStyle(color: AppColors.tertiary),
                      hintStyle: TextStyle(color: AppColors.outlineVariant),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                        borderSide: BorderSide(color: AppColors.outlineVariant),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ],
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.tertiary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                onPressed: submitting
                    ? null
                    : () => Navigator.of(dialogContext).pop(),
                child: Text(sent ? 'Done' : 'Cancel'),
              ),
              if (!sent)
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  onPressed: submitting
                      ? null
                      : () async {
                          final email = emailController.text.trim();
                          if (email.isEmpty) {
                            setDialogState(
                              () => error = 'Enter your email address.',
                            );
                            return;
                          }
                          setDialogState(() {
                            submitting = true;
                            error = null;
                          });
                          try {
                            await ref
                                .read(authApiProvider)
                                .requestBusinessPasswordReset(email: email);
                            setDialogState(() => sent = true);
                          } catch (requestError) {
                            setDialogState(
                              () => error = requestError.toString(),
                            );
                          } finally {
                            setDialogState(() => submitting = false);
                          }
                        },
                  child: submitting
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.onPrimary,
                          ),
                        )
                      : const Text('Send link'),
                ),
            ],
          ),
        );
      },
    );
    emailController.dispose();
  }

  Future<void> _showResendVerificationDialog() async {
    final emailController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        var submitting = false;
        var sent = false;
        String? error;

        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            backgroundColor: AppColors.surfaceContainerLowest,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              side: BorderSide(color: AppColors.outlineVariant),
            ),
            title: Row(
              children: [
                Icon(
                  sent
                      ? Icons.mark_email_read_outlined
                      : Icons.mark_email_unread_outlined,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    sent ? 'Check your email' : 'Resend verification email',
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
                  sent
                      ? 'If an unverified account with that email exists, verification instructions have been sent.'
                      : 'Enter the email address used for your business account.',
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: AppColors.onSurfaceVariant),
                ),
                if (!sent) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'you@example.com',
                      prefixIcon: Icon(Icons.mail_outline),
                      contentPadding: EdgeInsets.all(14),
                    ),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: submitting
                    ? null
                    : () => Navigator.of(dialogContext).pop(),
                child: Text(sent ? 'Done' : 'Cancel'),
              ),
              if (!sent)
                FilledButton(
                  onPressed: submitting
                      ? null
                      : () async {
                          final email = emailController.text.trim();
                          if (email.isEmpty) {
                            setDialogState(
                              () => error = 'Enter your email address.',
                            );
                            return;
                          }
                          setDialogState(() {
                            submitting = true;
                            error = null;
                          });
                          try {
                            await ref
                                .read(authApiProvider)
                                .resendBusinessVerification(email: email);
                            setDialogState(() => sent = true);
                          } catch (requestError) {
                            setDialogState(
                              () => error = requestError.toString(),
                            );
                          } finally {
                            setDialogState(() => submitting = false);
                          }
                        },
                  child: submitting
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Send link'),
                ),
            ],
          ),
        );
      },
    );
    emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBusiness = _role == LoginRole.business;
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
                      elevation: 1,
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          compact ? 20 : 32,
                          compact ? 24 : 32,
                          compact ? 20 : 32,
                          24,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Icon(
                              Icons.near_me,
                              size: 42,
                              color: theme.colorScheme.primary,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Locora',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'SPATIAL INTELLIGENCE & LOGISTICS',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.labelSmall?.copyWith(
                                letterSpacing: 1.3,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            SizedBox(height: 16),
                            Container(
                              color: AppColors.surfaceContainerLow,
                              padding: .all(4),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: RoleTab(
                                      icon: Icons.business_outlined,
                                      label: 'Business',
                                      selected: isBusiness,
                                      onTap: () =>
                                          _selectRole(LoginRole.business),
                                    ),
                                  ),
                                  Expanded(
                                    child: RoleTab(
                                      icon: Icons.navigation_outlined,
                                      label: 'Driver',
                                      selected: !isBusiness,
                                      onTap: () =>
                                          _selectRole(LoginRole.driver),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 28),
                            Text(
                              'Welcome back.',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isBusiness
                                  ? 'Log in to manage your Locora business account.'
                                  : 'Log in to view and manage your deliveries.',
                            ),
                            SizedBox(height: 24),
                            LocoraTextField(
                              label: isBusiness
                                  ? 'Business Name'
                                  : 'Phone Number',
                              hint: isBusiness
                                  ? 'Acme Logistics, Metro Mart, etc.'
                                  : '+1 555 123 4567',
                              controller: _name,
                              suffix: Icon(
                                isBusiness
                                    ? Icons.business_outlined
                                    : Icons.phone_outlined,
                              ),
                              keyboardType: isBusiness
                                  ? null
                                  : TextInputType.phone,
                              textInputAction: TextInputAction.next,
                            ),
                            LocoraTextField(
                              label: 'Password',
                              hint: 'Enter your password',
                              controller: _password,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              suffix: IconButton(
                                tooltip: _obscurePassword
                                    ? 'Show password'
                                    : 'Hide password',
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                            if (isBusiness)
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: _loading
                                      ? null
                                      : _showForgotPasswordDialog,
                                  child: const Text('Forgot password?'),
                                ),
                              ),
                            if (_error != null)
                              Text(
                                _error!,
                                style: TextStyle(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            if (_unverifiedBusiness)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton.icon(
                                  onPressed: _loading
                                      ? null
                                      : _showResendVerificationDialog,
                                  icon: const Icon(
                                    Icons.mark_email_unread_outlined,
                                  ),
                                  label: const Text(
                                    'Resend verification email',
                                  ),
                                ),
                              ),
                            const SizedBox(height: 8),
                            PrimaryButton(
                              label: 'Log In ->',
                              onPressed: _loading ? null : _login,
                              height: 44,
                              isLoading: _loading,
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              style: ButtonStyle(
                                overlayColor: .all(Colors.transparent),
                              ),
                              onPressed: _loading
                                  ? null
                                  : () => context.go('/signup'),
                              child: Text(
                                isBusiness
                                    ? "Don't have a business account? Sign up"
                                    : "Don't have a driver account? Sign up",
                              ),
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
