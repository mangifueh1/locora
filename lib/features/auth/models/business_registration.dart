class BusinessRegistration {
  const BusinessRegistration({
    required this.businessId,
    required this.apiKey,
    required this.note,
    this.email = '',
    this.emailVerificationRequired = false,
    this.verificationEmailSent = false,
  });

  final String businessId;
  final String apiKey;
  final String note;
  final String email;
  final bool emailVerificationRequired;
  final bool verificationEmailSent;

  factory BusinessRegistration.fromJson(
    Map<String, dynamic> json, {
    String email = '',
  }) {
    final business = json['business'];
    final businessId = business is Map<String, dynamic>
        ? business['id']?.toString()
        : null;
    final apiKey = json['api_key']?.toString();
    if (businessId == null || businessId.isEmpty) {
      throw const FormatException(
        'Registration response did not include a business ID.',
      );
    }
    if (apiKey == null || apiKey.isEmpty) {
      throw const FormatException(
        'Registration response did not include an API key.',
      );
    }

    return BusinessRegistration(
      businessId: businessId,
      apiKey: apiKey,
      note: json['note']?.toString() ?? '',
      email: email,
      emailVerificationRequired: json['email_verification_required'] == true,
      verificationEmailSent: json['verification_email_sent'] == true,
    );
  }
}
