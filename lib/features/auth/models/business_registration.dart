class BusinessRegistration {
  const BusinessRegistration({required this.apiKey, required this.note});

  final String apiKey;
  final String note;

  factory BusinessRegistration.fromJson(Map<String, dynamic> json) {
    final apiKey = json['api_key']?.toString();
    if (apiKey == null || apiKey.isEmpty) {
      throw const FormatException(
        'Registration response did not include an API key.',
      );
    }

    return BusinessRegistration(
      apiKey: apiKey,
      note: json['note']?.toString() ?? '',
    );
  }
}
