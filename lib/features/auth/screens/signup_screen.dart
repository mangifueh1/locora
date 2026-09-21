import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:locora/features/auth/widgets/role_tab.dart';

import 'package:locora/features/auth/providers/auth_providers.dart';
import 'package:locora/features/driver/providers/driver_providers.dart';
import 'package:locora/features/business/providers/business_providers.dart';
import 'package:locora/shared/theme/app_colors.dart';
import 'package:locora/shared/widgets/buttons.dart';
import 'package:locora/shared/widgets/locora_text_field.dart';
import 'package:locora/shared/widgets/navbar.dart';

enum SignupRole { business, driver }

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key, this.initialRole = SignupRole.business});

  final SignupRole initialRole;

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  late SignupRole _role;

  final _businessName = TextEditingController();
  final _driverName = TextEditingController();
  final _phone = TextEditingController();
  final _businessPassword = TextEditingController();
  final _driverPassword = TextEditingController();
  final _businessConfirmPassword = TextEditingController();
  final _driverConfirmPassword = TextEditingController();
  final _webhookUrl = TextEditingController();

  bool _loading = false;
  String? _error;

  TextEditingController get _password =>
      _role == SignupRole.business ? _businessPassword : _driverPassword;

  TextEditingController get _confirmPassword => _role == SignupRole.business
      ? _businessConfirmPassword
      : _driverConfirmPassword;

  @override
  void initState() {
    super.initState();
    _role = widget.initialRole;
  }

  @override
  void dispose() {
    _businessName.dispose();
    _driverName.dispose();
    _phone.dispose();
    _businessPassword.dispose();
    _driverPassword.dispose();
    _businessConfirmPassword.dispose();
    _driverConfirmPassword.dispose();
    _webhookUrl.dispose();
    super.dispose();
  }

  void _selectRole(SignupRole role) {
    if (_loading || role == _role) return;
    setState(() {
      _role = role;
      _error = null;
    });
  }

  Future<void> _signup() async {
    final password = _password.text;
    if (password.isEmpty || _confirmPassword.text.isEmpty) {
      setState(() => _error = 'Please enter and confirm your password.');
      return;
    }
    if (password != _confirmPassword.text) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (_role == SignupRole.business) {
        final registration = await ref
            .read(authApiProvider)
            .registerBusiness(
              name: _businessName.text.trim(),
              password: password,
              webhookUrl: _webhookUrl.text,
            );
        await ref.read(businessSessionProvider).saveApiKey(registration.apiKey);

        if (!mounted) return;
        context.pushReplacementNamed('/business/login');
      } else {
        final result = await ref
            .read(authApiProvider)
            .registerDriver(
              name: _driverName.text.trim(),
              phone: _phone.text.trim(),
              password: password,
              businessIds: const [],
            );
        if (result.token != null) {
          await ref.read(driverSessionProvider).saveToken(result.token!);
        }

        if (!mounted) return;
        context.pushReplacementNamed('/driver/login');
      }
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Navbar(),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 360.w),
                    child: Card(
                      elevation: 1,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(32, 32, 32, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Icon(
                              Icons.near_me,
                              size: 42,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Locora',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'COORDINATE & DELIVERY INFRASTRUCTURE',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.labelSmall?.copyWith(
                                letterSpacing: 1.3,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            Container(
                              color: AppColors.surfaceContainerLow,
                              padding: .all(4.r),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: RoleTab(
                                      icon: Icons.business_outlined,
                                      label: 'Business',
                                      selected: _role == SignupRole.business,
                                      onTap: () =>
                                          _selectRole(SignupRole.business),
                                    ),
                                  ),
                                  Expanded(
                                    child: RoleTab(
                                      icon: Icons.local_shipping_outlined,
                                      label: 'Driver',
                                      selected: _role == SignupRole.driver,
                                      onTap: () =>
                                          _selectRole(SignupRole.driver),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 28),
                            Text(
                              _role == SignupRole.business
                                  ? 'Create your business account.'
                                  : 'Create your driver account.',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _role == SignupRole.business
                                  ? 'Connect your business to Locora and simplify your delivery locations.'
                                  : 'Join Locora and keep your assigned deliveries moving.',
                            ),
                            const SizedBox(height: 22),
                            if (_role == SignupRole.business) ...[
                              LocoraTextField(
                                label: 'Business Name',
                                controller: _businessName,
                                hint: 'Acme Logistics, Metro Mart, etc.',
                                textInputAction: TextInputAction.next,
                              ),
                            ] else ...[
                              LocoraTextField(
                                label: 'Full Name',
                                controller: _driverName,
                                hint: 'Your full name',
                                textInputAction: TextInputAction.next,
                              ),
                              LocoraTextField(
                                label: 'Phone Number',
                                controller: _phone,
                                hint: '+1 555 123 4567',
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.next,
                              ),
                            ],
                            LocoraTextField(
                              label: 'Password',
                              controller: _password,
                              hint: 'At least 8 characters',
                              obscureText: true,
                              textInputAction: TextInputAction.next,
                            ),
                            LocoraTextField(
                              label: 'Confirm Password',
                              controller: _confirmPassword,
                              hint: 'Re-enter password',
                              obscureText: true,
                              textInputAction: TextInputAction.next,
                            ),
                            if (_role == SignupRole.business)
                              LocoraTextField(
                                label: 'Webhook URL (optional)',
                                controller: _webhookUrl,
                                hint: 'https://example.com/webhook',
                                keyboardType: TextInputType.url,
                                textInputAction: TextInputAction.done,
                              ),
                            if (_error != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                _error!,
                                style: TextStyle(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ],
                            const SizedBox(height: 18),
                            PrimaryButton(
                              height: 44.h,

                              label: _role == SignupRole.business
                                  ? 'Create Business Account ->'
                                  : 'Create Driver Account ->',
                              onPressed: _loading ? null : _signup,
                            ),
                            // FilledButton(
                            //   onPressed: _loading ? null : _signup,
                            //   child: _loading
                            //       ? const SizedBox(
                            //           width: 20,
                            //           height: 20,
                            //           child: CircularProgressIndicator(
                            //             strokeWidth: 2,
                            //           ),
                            //         )
                            //       : Text(
                            //           _role == SignupRole.business
                            //               ? 'Create Business Account ->'
                            //               : 'Create Driver Account ->',
                            //         ),
                            // ),
                            const SizedBox(height: 12),
                            TextButton(
                              style: ButtonStyle(
                                overlayColor: .all(Colors.transparent),
                              ),
                              onPressed: _loading
                                  ? null
                                  : () => context.go('/login'),
                              child: const Text(
                                'Already have an account? Log in',
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
