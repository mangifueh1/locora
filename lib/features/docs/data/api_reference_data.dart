import '../models/api_endpoint.dart';

class ApiReferenceData {
  ApiReferenceData._();

  static const baseUrl = 'https://api.locora.site';
  static const localBaseUrl = 'http://localhost:4000/api/v1';

  static const categories = ApiEndpointCategory.values;

  static const endpoints = <ApiEndpoint>[
    ApiEndpoint(
      name: 'Register a business',
      method: 'POST',
      path: '/businesses/register',
      category: ApiEndpointCategory.business,
      auth: 'Public',
      description: 'Create a business account and issue a one-time API key.',
      parameters: [
        ApiParameter(
          name: 'name',
          type: 'string',
          description: 'Unique business name.',
          required: true,
        ),
        ApiParameter(
          name: 'email',
          type: 'string',
          description: 'Business email address.',
          required: true,
        ),
        ApiParameter(
          name: 'password',
          type: 'string',
          description: 'Dashboard password.',
          required: true,
        ),
      ],
      requestExample: '{\n  "name": "Acme Meals",\n  "email": "ops@acme.example",\n  "password": "StrongPassword123"\n}',
      responseExample: '{\n  "business": { "id": "uuid", "name": "Acme Meals", "created_at": "timestamp" },\n  "api_key": "<businessId>.<rawKey>",\n  "note": "Store this API key now — it cannot be retrieved again."\n}',
      errors: [
        '400 Missing name or password',
        '409 Business name already exists',
      ],
    ),
    ApiEndpoint(
      name: 'Business login',
      method: 'POST',
      path: '/businesses/login',
      category: ApiEndpointCategory.business,
      auth: 'Public',
      description: 'Sign in to the business dashboard and receive a business session JWT.',
      parameters: [
        ApiParameter(
          name: 'name',
          type: 'string',
          description: 'Business name.',
          required: true,
        ),
        ApiParameter(
          name: 'password',
          type: 'string',
          description: 'Business password.',
          required: true,
        ),
      ],
      requestExample:
          '{\n  "name": "Acme Meals",\n  "password": "StrongPassword123"\n}',
      responseExample: '{\n  "business": { "id": "uuid", "name": "Acme Meals" },\n  "token": "jwt"\n}',
      errors: ['400 Missing credentials', '401 Invalid name or password'],
    ),
    ApiEndpoint(
      name: 'List business drivers',
      method: 'GET',
      path: '/businesses/me/drivers',
      category: ApiEndpointCategory.business,
      auth: 'Business JWT',
      description: 'List drivers registered with the authenticated business.',
      responseExample: '{\n  "drivers": [{ "id": "uuid", "name": "Sam Driver", "phone": "+15551234567", "joined_at": "timestamp" }]\n}',
    ),
    ApiEndpoint(
      name: 'Remove a business driver',
      method: 'DELETE',
      path: '/businesses/me/drivers/:driverId',
      category: ApiEndpointCategory.business,
      auth: 'Business JWT',
      description:
          'Remove a driver from this business without deleting their account.',
      parameters: [
        ApiParameter(
          name: 'driverId',
          type: 'uuid',
          description: 'Driver account ID.',
          required: true,
          location: 'path',
        ),
      ],
      responseExample: '{\n  "status": "removed",\n  "driver_id": "uuid"\n}',
      errors: ['404 Driver is not registered with this business'],
    ),
    ApiEndpoint(
      name: 'List business deliveries',
      method: 'GET',
      path: '/businesses/me/deliveries',
      category: ApiEndpointCategory.business,
      auth: 'Business JWT',
      description:
          'List this business’s deliveries, optionally filtered by status.',
      parameters: [
        ApiParameter(
          name: 'status',
          type: 'string',
          description: 'pending, assigned, in_progress, or delivered.',
          location: 'query',
        ),
      ],
      responseExample: '{\n  "deliveries": [{ "id": "uuid", "order_id": "ORD-123", "status": "pending", "customer_lat": 40.7128, "customer_lng": -74.006 }]\n}',
    ),
    ApiEndpoint(
      name: 'Check API key status',
      method: 'GET',
      path: '/businesses/me/api-key',
      category: ApiEndpointCategory.business,
      auth: 'Business JWT',
      description:
          'Check whether an API key exists. The raw key is never returned.',
      responseExample: '{\n  "business_id": "uuid",\n  "note": "The raw API key is never shown again after issuance — regenerate if lost."\n}',
    ),
    ApiEndpoint(
      name: 'Regenerate API key',
      method: 'POST',
      path: '/businesses/me/api-key/regenerate',
      category: ApiEndpointCategory.business,
      auth: 'Business JWT',
      description: 'Issue a new one-time API key and immediately invalidate the previous key.',
      responseExample: '{\n  "api_key": "<businessId>.<newRawKey>",\n  "note": "The previous API key is now invalid. Store this new one now."\n}',
    ),
    ApiEndpoint(
      name: 'Register a driver',
      method: 'POST',
      path: '/drivers/register',
      category: ApiEndpointCategory.driver,
      auth: 'Public',
      description: 'Create a driver account and join one or more businesses.',
      parameters: [
        ApiParameter(
          name: 'name',
          type: 'string',
          description: 'Driver’s name.',
          required: true,
        ),
        ApiParameter(
          name: 'phone',
          type: 'string',
          description: 'Phone number in a common format.',
          required: true,
        ),
        ApiParameter(
          name: 'password',
          type: 'string',
          description: 'Account password.',
          required: true,
        ),
        ApiParameter(
          name: 'business_ids',
          type: 'string[]',
          description: 'One or more existing business IDs.',
          required: true,
        ),
      ],
      requestExample: '{\n  "name": "Jane Driver",\n  "phone": "+15551234567",\n  "password": "SecurePass123",\n  "business_ids": ["uuid-1", "uuid-2"]\n}',
      responseExample: '{\n  "driver": { "id": "uuid", "name": "Jane Driver", "phone": "+15551234567", "created_at": "timestamp" },\n  "token": "jwt"\n}',
      errors: [
        '400 Invalid payload or business IDs',
        '409 Driver phone already exists',
      ],
    ),
    ApiEndpoint(
      name: 'Driver login',
      method: 'POST',
      path: '/drivers/login',
      category: ApiEndpointCategory.driver,
      auth: 'Public',
      description:
          'Sign in to the driver dashboard and receive a driver session JWT.',
      parameters: [
        ApiParameter(
          name: 'phone',
          type: 'string',
          description: 'Registered phone number.',
          required: true,
        ),
        ApiParameter(
          name: 'password',
          type: 'string',
          description: 'Account password.',
          required: true,
        ),
      ],
      requestExample:
          '{\n  "phone": "+15551234567",\n  "password": "SecurePass123"\n}',
      responseExample: '{\n  "driver": { "id": "uuid", "name": "Jane Driver", "phone": "+15551234567" },\n  "token": "jwt"\n}',
    ),
    ApiEndpoint(
      name: 'Available deliveries',
      method: 'GET',
      path: '/drivers/me/available-deliveries',
      category: ApiEndpointCategory.driver,
      auth: 'Driver JWT',
      description: 'List claimable deliveries and the driver’s remaining active slots. Drivers may have at most two active deliveries.',
      responseExample: '{\n  "active_delivery_count": 1,\n  "available_slots": 1,\n  "deliveries": [{ "id": "uuid", "order_id": "ORD-777", "status": "pending", "business_name": "Acme Meals" }]\n}',
    ),
    ApiEndpoint(
      name: 'List assigned deliveries',
      method: 'GET',
      path: '/drivers/me/deliveries',
      category: ApiEndpointCategory.driver,
      auth: 'Driver JWT',
      description: 'List all deliveries assigned to the authenticated driver.',
      responseExample: '{\n  "deliveries": [{ "id": "uuid", "order_id": "ORD-777", "status": "assigned", "business_name": "Acme Meals" }]\n}',
    ),
    ApiEndpoint(
      name: 'List driver businesses',
      method: 'GET',
      path: '/drivers/me/businesses',
      category: ApiEndpointCategory.driver,
      auth: 'Driver JWT',
      description: 'List the businesses this driver belongs to.',
      responseExample:
          '{\n  "businesses": [{ "id": "uuid", "name": "Acme Meals" }]\n}',
    ),
    ApiEndpoint(
      name: 'Create a delivery',
      method: 'POST',
      path: '/deliveries',
      category: ApiEndpointCategory.delivery,
      auth: 'Business API Key',
      description: 'Create a delivery. A saved customer location is reused; otherwise a short-lived location picker URL is returned.',
      parameters: [
        ApiParameter(
          name: 'order_id',
          type: 'string',
          description: 'Business order reference.',
          required: true,
        ),
        ApiParameter(
          name: 'customer_phone',
          type: 'string',
          description: 'Customer phone; normalized before lookup.',
          required: true,
        ),
        ApiParameter(
          name: 'customer_uid',
          type: 'string',
          description: 'Optional customer reference from your system.',
        ),
      ],
      requestExample: '{\n  "order_id": "ORD-123",\n  "customer_phone": "+15551234567",\n  "customer_uid": "customer-42"\n}',
      responseExample: '{\n  "requires_location": true,\n  "delivery_id": "uuid",\n  "picker_url": "https://your-frontend.com/pick/<pickerToken>",\n  "tracking_link": "https://your-frontend.com/track/<trackingToken>"\n}',
      errors: [
        '400 Missing order ID or invalid phone',
        '401 Invalid business API key',
      ],
    ),
    ApiEndpoint(
      name: 'Save picker location',
      method: 'POST',
      path: '/deliveries/by-token/:token/location',
      category: ApiEndpointCategory.delivery,
      auth: 'Public',
      description:
          'Save the customer’s selected coordinates from a picker link.',
      parameters: [
        ApiParameter(
          name: 'token',
          type: 'string',
          description: 'Picker token.',
          required: true,
          location: 'path',
        ),
        ApiParameter(
          name: 'lat',
          type: 'number',
          description: 'Latitude coordinate.',
          required: true,
        ),
        ApiParameter(
          name: 'lng',
          type: 'number',
          description: 'Longitude coordinate.',
          required: true,
        ),
      ],
      requestExample: '{\n  "lat": 40.7128,\n  "lng": -74.006\n}',
      responseExample: '{\n  "status": "success",\n  "tracking_link": "https://your-frontend.com/track/<trackingToken>"\n}',
      errors: [
        '400 Invalid coordinates',
        '401 Picker link is invalid or expired',
        '404 Delivery not found',
      ],
    ),
    ApiEndpoint(
      name: 'Track a delivery',
      method: 'GET',
      path: '/deliveries/by-token/:token',
      category: ApiEndpointCategory.delivery,
      auth: 'Public',
      description: 'Get public tracking information, assignment state, and the latest driver position.',
      parameters: [
        ApiParameter(
          name: 'token',
          type: 'string',
          description: 'Tracking token.',
          required: true,
          location: 'path',
        ),
      ],
      responseExample: '{\n  "delivery": {\n    "id": "uuid", "order_id": "ORD-123", "status": "assigned",\n    "customer_lat": 40.7128, "customer_lng": -74.006,\n    "driver": { "id": "uuid", "lat": 40.722, "lng": -74.012 },\n    "assignment": "assigned"\n  }\n}',
    ),
    ApiEndpoint(
      name: 'Claim a delivery',
      method: 'POST',
      path: '/deliveries/:id/claim',
      category: ApiEndpointCategory.delivery,
      auth: 'Driver JWT',
      description: 'Claim a pending delivery belonging to one of the driver’s businesses.',
      parameters: [
        ApiParameter(
          name: 'id',
          type: 'uuid',
          description: 'Delivery ID.',
          required: true,
          location: 'path',
        ),
        ApiParameter(
          name: 'lat',
          type: 'number',
          description: 'Current driver latitude.',
          required: true,
        ),
        ApiParameter(
          name: 'lng',
          type: 'number',
          description: 'Current driver longitude.',
          required: true,
        ),
      ],
      requestExample: '{\n  "lat": 40.7128,\n  "lng": -74.006\n}',
      responseExample: '{\n  "delivery": { "id": "uuid", "driver_id": "uuid", "status": "assigned", "driver_lat": 40.7128, "driver_lng": -74.006 }\n}',
      errors: [
        '400 Invalid coordinates',
        '404 Delivery not found for one of your businesses',
        '409 Delivery unavailable or active limit reached',
      ],
    ),
    ApiEndpoint(
      name: 'Update driver location',
      method: 'POST',
      path: '/deliveries/:id/location',
      category: ApiEndpointCategory.delivery,
      auth: 'Driver JWT',
      description: 'Update the location of a delivery assigned to the authenticated driver.',
      parameters: [
        ApiParameter(
          name: 'id',
          type: 'uuid',
          description: 'Delivery ID.',
          required: true,
          location: 'path',
        ),
        ApiParameter(
          name: 'lat',
          type: 'number',
          description: 'Current latitude.',
          required: true,
        ),
        ApiParameter(
          name: 'lng',
          type: 'number',
          description: 'Current longitude.',
          required: true,
        ),
      ],
      requestExample: '{\n  "lat": 40.732,\n  "lng": -74.004\n}',
      responseExample: '{\n  "delivery": { "id": "uuid", "driver_lat": 40.732, "driver_lng": -74.004, "updated_at": "timestamp" }\n}',
      errors: [
        '400 Invalid coordinates',
        '404 Delivery not found or not assigned to this driver',
      ],
    ),
    ApiEndpoint(
      name: 'Get assigned delivery',
      method: 'GET',
      path: '/deliveries/:id',
      category: ApiEndpointCategory.delivery,
      auth: 'Driver JWT',
      description:
          'Get details for one delivery assigned to the authenticated driver.',
      parameters: [
        ApiParameter(
          name: 'id',
          type: 'uuid',
          description: 'Delivery ID.',
          required: true,
          location: 'path',
        ),
      ],
      responseExample: '{\n  "delivery": { "id": "uuid", "order_id": "ORD-123", "status": "assigned", "business_id": "uuid", "customer_id": "uuid", "driver_id": "uuid" }\n}',
    ),
    ApiEndpoint(
      name: 'Start a delivery',
      method: 'POST',
      path: '/deliveries/:id/start',
      category: ApiEndpointCategory.delivery,
      auth: 'Driver JWT',
      description: 'Mark an assigned delivery as in progress.',
      parameters: [
        ApiParameter(
          name: 'id',
          type: 'uuid',
          description: 'Delivery ID.',
          required: true,
          location: 'path',
        ),
      ],
      responseExample: '{\n  "delivery": { "id": "uuid", "status": "in_progress", "updated_at": "timestamp" }\n}',
    ),
    ApiEndpoint(
      name: 'Complete a delivery',
      method: 'POST',
      path: '/deliveries/:id/complete',
      category: ApiEndpointCategory.delivery,
      auth: 'Driver JWT',
      description: 'Mark a delivery as delivered.',
      parameters: [
        ApiParameter(
          name: 'id',
          type: 'uuid',
          description: 'Delivery ID.',
          required: true,
          location: 'path',
        ),
      ],
      responseExample: '{\n  "delivery": { "id": "uuid", "status": "delivered", "updated_at": "timestamp" }\n}',
    ),
    ApiEndpoint(
      name: 'Clear customer location',
      method: 'DELETE',
      path: '/customers/:phone/location',
      category: ApiEndpointCategory.customer,
      auth: 'Business API Key',
      description: 'Clear a customer’s saved delivery location. Phone values are normalized internally.',
      parameters: [
        ApiParameter(
          name: 'phone',
          type: 'string',
          description: 'Customer phone in a common format.',
          required: true,
          location: 'path',
        ),
      ],
      responseExample: '{\n  "status": "reset",\n  "customer_id": "uuid"\n}',
      errors: [
        '400 Invalid phone number',
        '404 No customer found for that phone number',
      ],
    ),
    ApiEndpoint(
      name: 'Health check',
      method: 'GET',
      path: '/health',
      category: ApiEndpointCategory.health,
      auth: 'Public',
      description: 'Check that the backend is responding.',
      responseExample: '{\n  "status": "ok"\n}',
    ),
  ];
}
