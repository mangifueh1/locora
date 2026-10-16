import 'package:flutter_test/flutter_test.dart';
import 'package:locora/features/business/models/business_profile.dart';

void main() {
  test('parses the authenticated business profile response', () {
    final profile = BusinessProfile.fromJson({
      'business': {
        'id': 'business-123',
        'name': 'Acme Logistics',
        'email': 'dispatch@acme.test',
        'email_verified': true,
        'webhook_url': 'https://acme.test/webhooks/locora',
        'created_at': '2025-01-01T12:00:00Z',
      },
    });

    expect(profile.id, 'business-123');
    expect(profile.name, 'Acme Logistics');
    expect(profile.email, 'dispatch@acme.test');
    expect(profile.emailVerified, isTrue);
    expect(profile.webhookUrl, 'https://acme.test/webhooks/locora');
    expect(profile.createdAt, DateTime.utc(2025, 1, 1, 12));
  });

  test('rejects a response without a business identity', () {
    expect(
      () => BusinessProfile.fromJson({'business': {'email': 'a@b.test'}}),
      throwsFormatException,
    );
  });
}
