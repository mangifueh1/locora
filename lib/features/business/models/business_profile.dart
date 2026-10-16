class BusinessProfile {
  const BusinessProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.emailVerified,
    this.webhookUrl,
    this.createdAt,
  });

  final String id;
  final String name;
  final String email;
  final bool emailVerified;
  final String? webhookUrl;
  final DateTime? createdAt;

  factory BusinessProfile.fromJson(Map<String, dynamic> json) {
    final business = json['business'];
    if (business is! Map<String, dynamic>) {
      throw const FormatException(
        'Business profile response did not include a business object.',
      );
    }

    final id = business['id']?.toString();
    final name = business['name']?.toString();
    if (id == null || id.isEmpty || name == null || name.isEmpty) {
      throw const FormatException(
        'Business profile response is missing its ID or name.',
      );
    }

    return BusinessProfile(
      id: id,
      name: name,
      email: business['email']?.toString() ?? '',
      emailVerified: business['email_verified'] == true,
      webhookUrl: business['webhook_url']?.toString(),
      createdAt: DateTime.tryParse(business['created_at']?.toString() ?? ''),
    );
  }
}
