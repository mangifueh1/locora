class DriverRegistration {
  const DriverRegistration({this.token});

  final String? token;

  factory DriverRegistration.fromJson(Map<String, dynamic> json) {
    return DriverRegistration(token: json['token']?.toString());
  }
}
