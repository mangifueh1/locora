import 'package:flutter/material.dart';

import 'package:locora/shared/theme/app_colors.dart';
import 'package:locora/shared/widgets/footer.dart';
import 'package:locora/shared/widgets/navbar.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) => const _LegalDocumentScreen(
    title: 'Terms of Service',
    introduction:
        'These Terms of Service govern your access to and use of Locora. '
        'By creating an account or using the service, you agree to these terms.',
    sections: [
      _LegalSection(
        '1. The service',
        'Locora provides tools for businesses, drivers, and delivery recipients '
            'to coordinate deliveries and share delivery locations. Features '
            'may change as we improve the service.',
      ),
      _LegalSection(
        '2. Accounts and eligibility',
        'You must provide accurate account information, keep your credentials '
            'secure, and promptly update information that changes. You are '
            'responsible for activity under your account. If you create an '
            'account for a business, you confirm that you are authorized to '
            'accept these terms for that business.',
      ),
      _LegalSection(
        '3. Acceptable use',
        'Use Locora only for lawful delivery coordination. Do not misuse the '
            'service, interfere with its operation, attempt unauthorized access, '
            'submit information you are not permitted to share, or use another '
            'person’s account without permission.',
      ),
      _LegalSection(
        '4. Location and delivery information',
        'Locora can help share a delivery destination or location with the '
            'people involved in that delivery. You are responsible for '
            'providing accurate information and obtaining any permissions '
            'needed to share another person’s information. Location estimates '
            'and delivery details may be delayed or inaccurate; do not rely on '
            'Locora for emergency services or as a guarantee of delivery time '
            'or outcome.',
      ),
      _LegalSection(
        '5. Business accounts and credentials',
        'Business account owners are responsible for managing authorized users '
            'and protecting account credentials, including API keys. Keep keys '
            'confidential, use them only with authorized systems, and contact '
            'Locora promptly if you believe a key or account has been exposed.',
      ),
      _LegalSection(
        '6. Suspension and termination',
        'You may stop using Locora at any time. We may suspend or restrict '
            'access where reasonably necessary to protect users, investigate '
            'misuse, comply with law, or maintain the service. We will provide '
            'notice when reasonably practicable.',
      ),
      _LegalSection(
        '7. Availability and disclaimers',
        'We work to keep Locora available and reliable, but the service may be '
            'interrupted, changed, or unavailable from time to time. To the '
            'extent permitted by applicable law, Locora is provided “as is” and '
            '“as available,” without warranties that cannot be excluded by law.',
      ),
      _LegalSection(
        '8. Limitation of liability',
        'To the extent permitted by applicable law, Locora Technologies Inc. '
            'will not be liable for indirect, incidental, special, consequential, '
            'or punitive loss arising from your use of the service. Nothing in '
            'these terms limits liability that applicable law does not allow '
            'to be limited.',
      ),
      _LegalSection(
        '9. Changes to these terms',
        'We may update these terms as the service or applicable requirements '
            'change. We will post the current version here and update its '
            'effective date. If a change materially affects your use, we will '
            'take reasonable steps to provide notice. Continued use after an '
            'update means you accept the revised terms.',
      ),
      _LegalSection(
        '10. Contact',
        'Questions about these terms? Contact us at support@locora.com.',
      ),
    ],
  );
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) => const _LegalDocumentScreen(
    title: 'Privacy Policy',
    introduction:
        'This policy explains how Locora Technologies Inc. collects, uses, '
        'and shares information when you use Locora’s delivery coordination '
        'service.',
    sections: [
      _LegalSection(
        '1. Information we collect',
        'Account information: name, email address, phone number, password '
            'credentials, and business details or business IDs you provide. '
            'Delivery information: delivery identifiers, destinations, '
            'tracking links, and location information shared for a delivery. '
            'Technical information: basic device, connection, and service '
            'activity data needed to operate, secure, and troubleshoot Locora.',
      ),
      _LegalSection(
        '2. How we use information',
        'We use information to create and secure accounts, coordinate and '
            'track deliveries, share delivery details with the people authorized '
            'for a delivery, provide support, maintain and improve Locora, '
            'prevent misuse, and meet legal obligations.',
      ),
      _LegalSection(
        '3. How information is shared',
        'We share relevant delivery information with the businesses, drivers, '
            'and recipients involved in that delivery so they can coordinate '
            'it. We may use service providers that help host, operate, secure, '
            'or support Locora; they may process information on our behalf. '
            'We may also disclose information when required by law or needed '
            'to protect users, Locora, or the public. We do not sell personal '
            'information.',
      ),
      _LegalSection(
        '4. Location information',
        'Location or destination information is used to provide delivery '
            'coordination and tracking features. It may be visible to the '
            'business, driver, or recipient authorized for that delivery. Only '
            'share location information when you have the right and permission '
            'to do so.',
      ),
      _LegalSection(
        '5. Retention and security',
        'We keep information for as long as reasonably needed to provide the '
            'service, support business records, resolve disputes, and meet '
            'legal or security obligations. We use reasonable safeguards, but '
            'no method of storage or transmission is completely secure.',
      ),
      _LegalSection(
        '6. Your choices and requests',
        'You can keep your account details up to date and may contact us to '
            'ask about access, correction, or deletion of your information. '
            'Some information may need to be retained where required by law '
            'or for legitimate operational purposes. We will handle requests '
            'as required by applicable law.',
      ),
      _LegalSection(
        '7. Children',
        'Locora is intended for business and delivery coordination and is not '
            'directed to children. Do not create an account if you are not '
            'permitted to use the service under applicable law.',
      ),
      _LegalSection(
        '8. Changes to this policy',
        'We may update this policy as Locora changes. The current version '
            'will be posted here with its effective date. We will take '
            'reasonable steps to notify users of material changes.',
      ),
      _LegalSection(
        '9. Contact',
        'For privacy questions or requests, contact support@locora.com.',
      ),
    ],
  );
}

class _LegalSection {
  const _LegalSection(this.title, this.body);

  final String title;
  final String body;
}

class _LegalDocumentScreen extends StatelessWidget {
  const _LegalDocumentScreen({
    required this.title,
    required this.introduction,
    required this.sections,
  });

  final String title;
  final String introduction;
  final List<_LegalSection> sections;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Navbar(),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 38, 22, 54),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 860),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LOCORA / LEGAL',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Effective October 10, 2026',
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        introduction,
                        style: Theme.of(context).textTheme.bodyLarge
                            ?.copyWith(height: 1.6),
                      ),
                      const SizedBox(height: 24),
                      for (final section in sections) ...[
                        const Divider(height: 28),
                        Text(
                          section.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          section.body,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColors.onSurfaceVariant,
                                height: 1.6,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const LocoraFooter(),
            ],
          ),
        ),
      ),
    );
  }
}
