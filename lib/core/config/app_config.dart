class AppConfig {
  const AppConfig({required this.apiBaseUrl, required this.mapboxToken});

  final String apiBaseUrl;
  final String mapboxToken;

  factory AppConfig.fromEnvironment() {
    return const AppConfig(
      apiBaseUrl: String.fromEnvironment(
        'API_BASE_URL',
      ),
      mapboxToken: String.fromEnvironment(
        'MAPBOX_TOKEN',
      ),
    );
  }
}
