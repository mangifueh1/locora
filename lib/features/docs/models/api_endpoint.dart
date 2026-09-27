enum ApiEndpointCategory {
  business,
  driver,
  delivery,
  customer,
  health,
  realtime,
}

class ApiEndpoint {
  const ApiEndpoint({
    required this.name,
    required this.method,
    required this.path,
    required this.category,
    required this.auth,
    required this.description,
    this.parameters = const [],
    this.requestExample,
    this.responseExample,
    this.errors = const [],
  });

  final String name;
  final String method;
  final String path;
  final ApiEndpointCategory category;
  final String auth;
  final String description;
  final List<ApiParameter> parameters;
  final String? requestExample;
  final String? responseExample;
  final List<String> errors;
}

class ApiParameter {
  const ApiParameter({
    required this.name,
    required this.type,
    required this.description,
    this.required = false,
    this.location = 'body',
  });

  final String name;
  final String type;
  final String description;
  final bool required;
  final String location;
}
