import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final _businessIdControllers = [TextEditingController()];
  final _businessPassword = TextEditingController();
  final _driverPassword = TextEditingController();
  final _businessConfirmPassword = TextEditingController();
  final _driverConfirmPassword = TextEditingController();
  final _webhookUrl = TextEditingController();

  bool _loading = false;
  String? _error;
  String? _businessIdsError;

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
    for (final controller in _businessIdControllers) {
      controller.dispose();
    }
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
      _businessIdsError = null;
    });
  }

  void _addBusinessIdField() {
    if (_loading || _businessIdControllers.last.text.trim().isEmpty) return;
    setState(() {
      _businessIdControllers.add(TextEditingController());
      _businessIdsError = null;
    });
  }

  void _removeBusinessIdField(int index) {
    if (_loading || index == 0) return;
    setState(() {
      _businessIdControllers.removeAt(index).dispose();
      _businessIdsError = null;
    });
  }

  List<String> get _businessIds => _businessIdControllers
      .map((controller) => controller.text.trim())
      .where((businessId) => businessId.isNotEmpty)
      .toSet()
      .toList();

  Future<void> _signup() async {
    if (_role == SignupRole.driver &&
        _businessIdControllers.any(
          (controller) => controller.text.trim().isEmpty,
        )) {
      setState(() {
        _businessIdsError = 'Enter a business ID in each field.';
      });
      return;
    }

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
      _businessIdsError = null;
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
              businessIds: _businessIds,
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
                              for (
                                var index = 0;
                                index < _businessIdControllers.length;
                                index++
                              )
                                LocoraTextField(
                                  label: index == 0
                                      ? 'Business ID'
                                      : 'Business ID ${index + 1}',
                                  controller: _businessIdControllers[index],
                                  hint: 'Enter a business ID',
                                  icon: Icons.business_outlined,
                                  textInputAction: TextInputAction.next,
                                  onChanged: (_) => setState(() {
                                    _businessIdsError = null;
                                  }),
                                  suffix: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (index > 0)
                                        IconButton(
                                          tooltip:
                                              'Remove business ID ${index + 1}',
                                          visualDensity: VisualDensity.compact,
                                          onPressed: _loading
                                              ? null
                                              : () => _removeBusinessIdField(
                                                  index,
                                                ),
                                          icon: const Icon(
                                            Icons.remove_circle_outline,
                                          ),
                                        ),
                                      if (index ==
                                              _businessIdControllers.length -
                                                  1 &&
                                          _businessIdControllers[index].text
                                              .trim()
                                              .isNotEmpty)
                                        IconButton(
                                          tooltip: 'Add business ID',
                                          visualDensity: VisualDensity.compact,
                                          onPressed: _loading
                                              ? null
                                              : _addBusinessIdField,
                                          icon: const Icon(
                                            Icons.add_circle_outline,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              if (_businessIdsError != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Text(
                                    _businessIdsError!,
                                    style: TextStyle(
                                      color: theme.colorScheme.error,
                                    ),
                                  ),
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
                              height: 44,

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
