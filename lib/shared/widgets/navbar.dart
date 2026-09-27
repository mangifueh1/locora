import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:locora/shared/theme/app_colors.dart';
import 'package:locora/shared/theme/app_text_sizes.dart';
import 'package:locora/shared/widgets/buttons.dart';

class Navbar extends StatelessWidget {
  const Navbar({super.key});

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 960;
    final navItems = [
      _NavItem(label: 'Home', route: '/'),
      _NavItem(label: 'Contact', route: '/contact'),
      _NavItem(label: 'API Docs', route: '/api-docs'),
    ];

    return Container(
      padding: compact
          ? const EdgeInsets.symmetric(horizontal: 16, vertical: 10)
          : EdgeInsets.symmetric(horizontal: 45, vertical: 15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.45),
          ),
        ),
      ),
      child: Center(
        child: Row(
          crossAxisAlignment: .center,
          children: compact
              ? [
                  const _BrandLogo(compact: true),
                  const Spacer(),
                  PopupMenuButton<String>(
                    tooltip: 'Open navigation menu',
                    icon: const Icon(Icons.menu_rounded),
                    color: AppColors.surfaceContainerLowest,
                    surfaceTintColor: Colors.transparent,
                    shadowColor: AppColors.onSurface.withValues(alpha: 0.16),
                    elevation: 10,
                    menuPadding: const EdgeInsets.symmetric(vertical: 6),
                    constraints: const BoxConstraints(minWidth: 216),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: AppColors.outlineVariant.withValues(alpha: 0.65),
                      ),
                    ),
                    onSelected: (route) => context.go(route),
                    itemBuilder: (context) => [
                      PopupMenuItem<String>(
                        value: navItems[0].route,
                        child: _MenuEntry(
                          icon: Icons.home_outlined,
                          label: navItems[0].label,
                          selected:
                              GoRouterState.of(context).uri.path ==
                              navItems[0].route,
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: navItems[1].route,
                        child: _MenuEntry(
                          icon: Icons.mail_outline_rounded,
                          label: navItems[1].label,
                          selected:
                              GoRouterState.of(context).uri.path ==
                              navItems[1].route,
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: navItems[2].route,
                        child: _MenuEntry(
                          icon: Icons.code_rounded,
                          label: navItems[2].label,
                          selected:
                              GoRouterState.of(context).uri.path ==
                              navItems[2].route,
                        ),
                      ),
                      const PopupMenuDivider(height: 8),
                      const PopupMenuItem<String>(
                        value: '/login',
                        child: _MenuEntry(
                          icon: Icons.login_rounded,
                          label: 'Log In',
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: '/business/register',
                        child: _MenuEntry(
                          icon: Icons.arrow_forward_rounded,
                          label: 'Get Started',
                          primary: true,
                        ),
                      ),
                    ],
                  ),
                ]
              : [
                  const _BrandLogo(),
                  SizedBox(width: 32),
                  Expanded(
                    child: Row(
                      children: navItems
                          .map(
                            (item) => Padding(
                              padding: EdgeInsets.only(right: 28),
                              child: _NavLink(
                                label: item.label,
                                isActive:
                                    item.route ==
                                    GoRouterState.of(context).uri.path,
                                onPressed: item.route == null
                                    ? null
                                    : () => context.go(item.route!),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  Row(
                    children: [
                      _TextActionButton(
                        label: 'Log In',
                        onPressed: () => context.go('/login'),
                      ),
                      const SizedBox(width: 14),
                      PrimaryButton(
                        label: 'Get Started',
                        onPressed: () => context.go('/business/register'),
                      ),
                    ],
                  ),
                ],
        ),
      ),
    );
  }
}

class _MenuEntry extends StatelessWidget {
  const _MenuEntry({
    required this.icon,
    required this.label,
    this.selected = false,
    this.primary = false,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final foreground = primary
        ? AppColors.primary
        : selected
        ? AppColors.secondary
        : AppColors.onSurfaceVariant;
    return Row(
      children: [
        Icon(icon, size: 18, color: foreground),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: primary ? AppColors.primary : AppColors.onSurface,
              fontSize: 14,
              fontWeight: primary || selected
                  ? FontWeight.w700
                  : FontWeight.w500,
            ),
          ),
        ),
        if (selected)
          const Icon(Icons.check_rounded, size: 16, color: AppColors.secondary),
      ],
    );
  }
}

class _BrandLogo extends StatelessWidget {
  const _BrandLogo({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: compact ? 106 : 106,
      height: compact ? 32 : 32,
      child: SvgPicture.asset(
        'assets/icons/locora_icon.svg',
        fit: BoxFit.contain,
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  const _NavLink({
    required this.label,
    required this.onPressed,
    this.isActive = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: AppTextSizes.small,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive
                    ? AppColors.onSurface
                    : AppColors.onSurfaceVariant,
              ),
            ),

            if (isActive)
              Container(
                margin: EdgeInsets.only(top: 6),
                width: 37,
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TextActionButton extends StatelessWidget {
  const _TextActionButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Text(
          label,
          style: TextStyle(
            fontSize: AppTextSizes.small,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.label, this.route});

  final String label;
  final String? route;
}
