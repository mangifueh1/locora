class AuthLoginResponse {
  const AuthLoginResponse({required this.token});

  final String token;

  factory AuthLoginResponse.fromJson(Map<String, dynamic> json) {
    final token = json['token']?.toString();
    if (token == null || token.isEmpty) {
      throw const FormatException('Login response did not include a token.');
    }

    return AuthLoginResponse(token: token);
  }
}
