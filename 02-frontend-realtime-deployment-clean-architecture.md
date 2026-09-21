# Locora — Part 2: Flutter Web Frontend, Live Tracking & Deployment

> **Purpose:** Build the Flutter Web side of Locora on top of the backend from Part 1.
>
> This document intentionally uses **Feature-First + Lightweight Architecture** rather than full Clean Architecture.
>
> The goal is simple: keep the project organized enough to scale, while avoiding dozens of tiny classes that make an MVP harder to understand.
>
> **Main Locora flow:**
>
> `Business backend → create delivery → customer opens Locora picker → customer selects house → Locora saves location → customer returns to business → business assigns driver → driver starts delivery → driver shares live location → tracking clients receive live updates.`

---

# 0. Architecture decision

## Do we need full Clean Architecture?

No.

For this version of Locora, full Clean Architecture would add a lot of ceremony without solving an immediate problem.

A structure like this is enough:

```text
lib/
├── core/
│   ├── config/
│   ├── network/
│   ├── routing/
│   ├── storage/
│   ├── realtime/
│   └── location/
│
├── features/
│   ├── picker/
│   │   ├── data/
│   │   ├── models/
│   │   ├── providers/
│   │   ├── screens/
│   │   └── widgets/
│   │
│   ├── driver/
│   │   ├── data/
│   │   ├── models/
│   │   ├── providers/
│   │   ├── screens/
│   │   └── widgets/
│   │
│   └── business/
│       ├── data/
│       ├── models/
│       ├── providers/
│       ├── screens/
│       └── widgets/
│
├── shared/
│   ├── widgets/
│   └── utils/
│
└── main.dart
```

## The rule to remember

Keep this direction:

```text
Screen / Widget
      ↓
Riverpod Provider / Notifier
      ↓
Feature Data Class / Service
      ↓
Core API / Socket / Storage
```

For a small feature, the provider can call the data class directly.

You **do not** need this for every button:

```text
Widget → Controller → UseCase → Repository → DataSource → API
```

That is useful in larger systems. For Locora V1 it would mostly create more files to maintain.

### Why this architecture?

- **Feature-first:** related code stays together.
- **Riverpod:** handles state and dependency injection.
- **Data classes/services:** contain backend communication instead of widgets.
- **Core:** contains things shared by multiple features.
- **Models:** prevent the UI from being filled with raw JSON maps.

> **Learning note:** You are not abandoning architecture. You are choosing the smallest architecture that solves the current problem.

---

# 1. Frontend surfaces

Locora has three real product surfaces today and one future surface.

## Customer

```text
/pick/:token
```

A public page. No login.

The customer uses it to select the exact house location.

## Driver

```text
/driver/login
/driver/register
/driver/dashboard
/driver/deliveries/:deliveryId
```

The driver can see assigned deliveries, start a delivery, share live GPS, and mark it delivered.

## Business

```text
/business/login
/business/dashboard
```

The business can see drivers, deliveries, assign drivers, remove drivers, and regenerate its API key.

## Future customer tracking

```text
/track/:trackingToken
```

Public, read-only live tracking. We can build this after the core flow works.

---

# 2. Important product flow: location picker

The browser should not be treated as the permanent source of truth for the customer's coordinates.

The recommended flow is:

```text
1. Business backend creates a delivery in Locora.
2. Locora returns picker_url.
3. Business app opens picker_url.
4. Customer moves the map and confirms the house.
5. Locora saves the location against that delivery.
6. Locora redirects the customer back to the business return URL.
7. Business backend can retrieve the saved location from Locora.
```

A useful delivery creation payload is:

```json
{
  "order_id": "A-1001",
  "customer_phone": "+237670000000",
  "return_url": "https://business.example/checkout/location-complete"
}
```

> **Important:** Do not allow arbitrary websites to be used as redirect targets. In production, validate the return URL against a business-specific allowlist.

---

# 3. Project setup

```bash
flutter create locora_web
cd locora_web
flutter config --enable-web
```

## Dependencies

`pubspec.yaml`

```yaml
dependencies:
  flutter:
    sdk: flutter

  flutter_riverpod: ^2.5.1
  flutter_map: ^7.0.2
  latlong2: ^0.9.1
  geolocator: ^13.0.1
  socket_io_client: ^2.0.3
  http: ^1.2.2
  shared_preferences: ^2.3.2
  go_router: ^14.2.7
```

Run:

```bash
flutter pub get
```

## Why each package exists

| Package | Why Locora needs it |
|---|---|
| `flutter_riverpod` | App state + dependency injection |
| `flutter_map` | Map UI on Flutter Web |
| `latlong2` | Latitude/longitude objects used by the map |
| `geolocator` | Driver browser/device GPS |
| `socket_io_client` | Real-time driver position updates |
| `http` | REST API calls |
| `shared_preferences` | Simple browser persistence for sessions |
| `go_router` | Routing + route parameters + redirects |

> **Realistic limitation:** `shared_preferences` is convenient, but browser storage is not a secure vault. Do not store secrets that should never be exposed to the browser.

---

# 4. Create the folders

```bash
mkdir -p lib/core/config \
         lib/core/network \
         lib/core/routing \
         lib/core/storage \
         lib/core/realtime \
         lib/core/location \
         lib/features/picker/data \
         lib/features/picker/models \
         lib/features/picker/providers \
         lib/features/picker/screens \
         lib/features/picker/widgets \
         lib/features/driver/data \
         lib/features/driver/models \
         lib/features/driver/providers \
         lib/features/driver/screens \
         lib/features/driver/widgets \
         lib/features/business/data \
         lib/features/business/models \
         lib/features/business/providers \
         lib/features/business/screens \
         lib/features/business/widgets \
         lib/shared/widgets \
         lib/shared/utils
```

> **Note:** You can create these directories manually in VS Code instead. The command is only a shortcut.

---

# 5. Configuration

Create:

```text
lib/core/config/app_config.dart
```

```dart
class AppConfig {
  const AppConfig({
    required this.apiBaseUrl,
    required this.mapboxToken,
  });

  final String apiBaseUrl;
  final String mapboxToken;

  factory AppConfig.fromEnvironment() {
    return const AppConfig(
      apiBaseUrl: String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://localhost:4000',
      ),
      mapboxToken: String.fromEnvironment(
        'MAPBOX_TOKEN',
        defaultValue: 'pk.PASTE_YOUR_TOKEN_HERE',
      ),
    );
  }

  String get mapboxTileUrl =>
      'https://api.mapbox.com/styles/v1/mapbox/streets-v12/tiles/'
      '{z}/{x}/{y}@2x?access_token=$mapboxToken';
}
```

### What is happening here?

`String.fromEnvironment` lets you pass values when the app is built instead of hardcoding your backend URL.

For development:

```bash
flutter run -d chrome \
  --dart-define=API_BASE_URL=http://localhost:4000 \
  --dart-define=MAPBOX_TOKEN=pk.your_real_token
```

For production:

```bash
flutter build web \
  --dart-define=API_BASE_URL=https://api.locora.example \
  --dart-define=MAPBOX_TOKEN=pk.your_real_token
```

> **Learning note:** configuration is separated from the rest of the application so you can change environments without changing feature code.

---

# 6. Core storage: authentication tokens

Create:

```text
lib/core/storage/token_storage.dart
```

```dart
import 'package:shared_preferences/shared_preferences.dart';

enum AuthScope {
  driver,
  business,
}

class TokenStorage {
  static const _driverKey = 'driver_token';
  static const _businessKey = 'business_token';

  Future<void> save(AuthScope scope, String token) async {
    final prefs = await SharedPreferences.getInstance();

    final key = switch (scope) {
      AuthScope.driver => _driverKey,
      AuthScope.business => _businessKey,
    };

    await prefs.setString(key, token);
  }

  Future<String?> read(AuthScope scope) async {
    final prefs = await SharedPreferences.getInstance();

    final key = switch (scope) {
      AuthScope.driver => _driverKey,
      AuthScope.business => _businessKey,
    };

    return prefs.getString(key);
  }

  Future<void> clear(AuthScope scope) async {
    final prefs = await SharedPreferences.getInstance();

    final key = switch (scope) {
      AuthScope.driver => _driverKey,
      AuthScope.business => _businessKey,
    };

    await prefs.remove(key);
  }
}
```

### Why keep driver and business tokens separate?

A driver and a business are different identities.

This is useful during development and testing because a browser can technically have both sessions.

> **Important:** Authentication and authorization are still enforced by the backend. Hiding a page in Flutter does not secure the API.

---

# 7. Core HTTP client

Create:

```text
lib/core/network/api_client.dart
```

```dart
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../storage/token_storage.dart';

class ApiException implements Exception {
  const ApiException(this.message, this.statusCode);

  final String message;
  final int statusCode;

  @override
  String toString() => message;
}

enum RequestAuth {
  none,
  driver,
  business,
}

class ApiClient {
  ApiClient({
    required String baseUrl,
    required TokenStorage tokenStorage,
  })  : _baseUrl = baseUrl,
        _tokenStorage = tokenStorage;

  final String _baseUrl;
  final TokenStorage _tokenStorage;

  Future<Map<String, String>> _headers(RequestAuth auth) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (auth == RequestAuth.none) {
      return headers;
    }

    final scope = auth == RequestAuth.driver
        ? AuthScope.driver
        : AuthScope.business;

    final token = await _tokenStorage.read(scope);

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Future<Map<String, dynamic>> get(
    String path, {
    RequestAuth auth = RequestAuth.none,
    Map<String, String>? queryParameters,
  }) async {
    final uri = Uri.parse('$_baseUrl$path').replace(
      queryParameters: queryParameters,
    );

    final response = await http.get(
      uri,
      headers: await _headers(auth),
    );

    return _decode(response);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    RequestAuth auth = RequestAuth.none,
    Map<String, dynamic>? body,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl$path'),
      headers: await _headers(auth),
      body: jsonEncode(body ?? {}),
    );

    return _decode(response);
  }

  Future<Map<String, dynamic>> delete(
    String path, {
    RequestAuth auth = RequestAuth.none,
  }) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl$path'),
      headers: await _headers(auth),
    );

    return _decode(response);
  }

  Map<String, dynamic> _decode(http.Response response) {
    dynamic decoded;

    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      throw ApiException(
        'The server returned an invalid response.',
        response.statusCode,
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded is Map<String, dynamic>
          ? decoded['error']?.toString() ?? 'Request failed.'
          : 'Request failed.';

      throw ApiException(message, response.statusCode);
    }

    if (decoded is! Map<String, dynamic>) {
      throw ApiException('Unexpected server response.', response.statusCode);
    }

    return decoded;
  }
}
```

### What this class does

The feature code should not repeatedly write this:

```dart
http.post(...)
jsonEncode(...)
Authorization: Bearer ...
jsonDecode(...)
```

`ApiClient` handles those repetitive details once.

The feature data classes can then say:

```dart
api.post('/api/v1/drivers/login', body: {...});
```

### Why `RequestAuth`?

Locora has three kinds of requests:

```text
none      → public picker
 driver   → driver dashboard/API
 business → business dashboard/API
```

That makes it difficult to accidentally use the wrong token for an endpoint.

---

# 8. Riverpod setup

Create:

```text
lib/core/providers.dart
```

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/app_config.dart';
import 'network/api_client.dart';
import 'storage/token_storage.dart';

final appConfigProvider = Provider<AppConfig>(
  (ref) => AppConfig.fromEnvironment(),
);

final tokenStorageProvider = Provider<TokenStorage>(
  (ref) => TokenStorage(),
);

final apiClientProvider = Provider<ApiClient>((ref) {
  final config = ref.watch(appConfigProvider);
  final storage = ref.watch(tokenStorageProvider);

  return ApiClient(
    baseUrl: config.apiBaseUrl,
    tokenStorage: storage,
  );
});
```

### Why is this useful?

Instead of creating the API client manually in every screen:

```dart
final api = ApiClient(...);
```

Riverpod creates and supplies the dependency.

Later, in tests, you can replace the API client with a fake implementation.

---

# 9. Picker feature

The picker is the most important part of Locora because it solves the original problem: Cameroon deliveries often need a precise house location even when a normal street address is not useful.

The picker should be simple:

```text
Map
 ↓
Customer moves map under fixed pin
 ↓
Customer taps Confirm
 ↓
POST location
 ↓
Success
 ↓
Return to business
```

## 9.1 Location model

Create:

```text
lib/features/picker/models/delivery_location.dart
```

```dart
class DeliveryLocation {
  const DeliveryLocation({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  Map<String, dynamic> toJson() {
    return {
      'lat': latitude,
      'lng': longitude,
    };
  }
}
```

### Why a model instead of `Map<String, dynamic>` everywhere?

Because the UI should deal with something meaningful:

```dart
DeliveryLocation(
  latitude: 4.147606,
  longitude: 9.287438,
)
```

rather than remembering that JSON happens to call those fields `lat` and `lng`.

---

## 9.2 Picker data class

Create:

```text
lib/features/picker/data/picker_api.dart
```

```dart
import '../../../core/network/api_client.dart';
import '../models/delivery_location.dart';

class PickerApi {
  PickerApi(this._api);

  final ApiClient _api;

  Future<Map<String, dynamic>> confirmLocation({
    required String token,
    required DeliveryLocation location,
  }) async {
    return _api.post(
      '/api/v1/deliveries/by-token/$token/location',
      body: location.toJson(),
    );
  }
}
```

### Why is this class useful?

It keeps backend endpoint knowledge inside the feature instead of inside the UI.

The screen should not know that the endpoint is:

```text
/api/v1/deliveries/by-token/:token/location
```

That is backend communication detail.

---

## 9.3 Picker provider

Create:

```text
lib/features/picker/providers/picker_provider.dart
```

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../data/picker_api.dart';
import '../models/delivery_location.dart';

final pickerApiProvider = Provider<PickerApi>((ref) {
  return PickerApi(ref.watch(apiClientProvider));
});

final pickerControllerProvider = StateNotifierProvider.family<
    PickerController,
    AsyncValue<void>,
    String>((ref, token) {
  return PickerController(
    ref.watch(pickerApiProvider),
    token,
  );
});

class PickerController extends StateNotifier<AsyncValue<void>> {
  PickerController(this._api, this.token)
      : super(const AsyncValue.data(null));

  final PickerApi _api;
  final String token;

  Future<Map<String, dynamic>?> confirm(
    DeliveryLocation location,
  ) async {
    state = const AsyncValue.loading();

    try {
      final result = await _api.confirmLocation(
        token: token,
        location: location,
      );

      state = const AsyncValue.data(null);
      return result;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }
}
```

> **Note:** A `StateNotifierProvider.family` creates a separate controller for each picker token. That matters because two customers opening two different picker links should not share submission state.

---

## 9.4 Picker map widget

Create:

```text
lib/features/picker/widgets/location_map.dart
```

```dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/config/app_config.dart';

class LocationMap extends StatelessWidget {
  const LocationMap({
    super.key,
    required this.config,
    required this.center,
    required this.onCenterChanged,
    required this.mapController,
  });

  final AppConfig config;
  final LatLng center;
  final ValueChanged<LatLng> onCenterChanged;
  final MapController mapController;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: center,
            initialZoom: 15,
            onPositionChanged: (position, hasGesture) {
              if (hasGesture) {
                onCenterChanged(position.center);
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: config.mapboxTileUrl,
              userAgentPackageName: 'com.locora.web',
            ),
          ],
        ),

        // The pin stays fixed while the customer moves the map.
        // This makes the center of the screen represent the selected house.
        const IgnorePointer(
          child: Transform.translate(
            offset: Offset(0, -24),
            child: Icon(
              Icons.location_pin,
              size: 48,
              color: Colors.red,
            ),
          ),
        ),
      ],
    );
  }
}
```

### The important idea

The pin is **not draggable**.

Instead:

```text
Pin stays still
       ↑
Map moves underneath it
```

When the customer stops moving the map, the coordinate at the pin is the selected coordinate.

This is a very good UX for a delivery-location product.

---

## 9.5 Picker screen

Create:

```text
lib/features/picker/screens/location_picker_screen.dart
```

```dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/providers.dart';
import '../models/delivery_location.dart';
import '../providers/picker_provider.dart';
import '../widgets/location_map.dart';

class LocationPickerScreen extends ConsumerStatefulWidget {
  const LocationPickerScreen({
    super.key,
    required this.token,
    this.returnUrl,
  });

  final String token;
  final String? returnUrl;

  @override
  ConsumerState<LocationPickerScreen> createState() =>
      _LocationPickerScreenState();
}

class _LocationPickerScreenState
    extends ConsumerState<LocationPickerScreen> {
  final MapController _mapController = MapController();

  LatLng _center = const LatLng(4.1560, 9.2632);

  Future<void> _confirm() async {
    final result = await ref
        .read(pickerControllerProvider(widget.token).notifier)
        .confirm(
          DeliveryLocation(
            latitude: _center.latitude,
            longitude: _center.longitude,
          ),
        );

    if (!mounted || result == null) return;

    final backendReturnUrl = result['return_url']?.toString();

    final destination = backendReturnUrl ?? widget.returnUrl;

    if (destination != null && destination.isNotEmpty) {
      final uri = Uri.tryParse(destination);

      if (uri != null) {
        await launchUrl(uri);
        return;
      }
    }

    await showDialog<void>(
      context: context,
      builder: (_) => const AlertDialog(
        title: Text('Location saved'),
        content: Text(
          'Your delivery location has been saved successfully.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(appConfigProvider);
    final state = ref.watch(pickerControllerProvider(widget.token));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm your delivery location'),
      ),
      body: Stack(
        children: [
          LocationMap(
            config: config,
            center: _center,
            mapController: _mapController,
            onCenterChanged: (value) {
              setState(() => _center = value);
            },
          ),

          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: SafeArea(
              child: FilledButton(
                onPressed: state.isLoading ? null : _confirm,
                child: state.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Confirm this location'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

### What the screen is responsible for

The screen only handles **presentation concerns**:

- showing the map;
- storing the currently visible center;
- showing the button;
- calling the provider;
- reacting to loading/success.

The screen does not build HTTP requests itself.

> **Note:** `url_launcher` is used above for returning to a business URL, so add the dependency if you use that exact implementation:
>
> ```yaml
> url_launcher: ^6.3.1
> ```
>
> A production implementation should preferably let the backend return the validated redirect URL rather than trusting a customer-supplied query parameter.

---

# 10. Driver models

Create:

```text
lib/features/driver/models/driver.dart
```

```dart
class Driver {
  const Driver({
    required this.id,
    required this.name,
    required this.phone,
  });

  final String id;
  final String name;
  final String phone;

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'].toString(),
      name: json['name'].toString(),
      phone: json['phone'].toString(),
    );
  }
}
```

Create:

```text
lib/features/driver/models/delivery.dart
```

```dart
class Delivery {
  const Delivery({
    required this.id,
    required this.orderId,
    required this.status,
    this.businessName,
    this.customerLat,
    this.customerLng,
  });

  final String id;
  final String orderId;
  final String status;
  final String? businessName;
  final double? customerLat;
  final double? customerLng;

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json['id'].toString(),
      orderId: json['order_id'].toString(),
      status: json['status'].toString(),
      businessName: json['business_name']?.toString(),
      customerLat: (json['customer_lat'] as num?)?.toDouble(),
      customerLng: (json['customer_lng'] as num?)?.toDouble(),
    );
  }
}
```

### Why models matter

Without models, the dashboard tends to become:

```dart
Text('${d['business_name']}')
Text('${d['status']}')
```

Models let you write:

```dart
Text(delivery.businessName ?? 'Unknown business')
Text(delivery.status)
```

That is easier to read and harder to break.

---

# 11. Driver API

Create:

```text
lib/features/driver/data/driver_api.dart
```

```dart
import '../../../core/network/api_client.dart';
import '../models/delivery.dart';
import '../models/driver.dart';

class DriverApi {
  DriverApi(this._api);

  final ApiClient _api;

  Future<Map<String, dynamic>> register({
    required String name,
    required String phone,
    required String password,
    required List<String> businessIds,
  }) {
    return _api.post(
      '/api/v1/drivers/register',
      body: {
        'name': name,
        'phone': phone,
        'password': password,
        'business_ids': businessIds,
      },
    );
  }

  Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
  }) {
    return _api.post(
      '/api/v1/drivers/login',
      body: {
        'phone': phone,
        'password': password,
      },
    );
  }

  Future<List<Delivery>> myDeliveries() async {
    final result = await _api.get(
      '/api/v1/drivers/me/deliveries',
      auth: RequestAuth.driver,
    );

    final items = result['deliveries'] as List<dynamic>? ?? [];

    return items
        .whereType<Map<String, dynamic>>()
        .map(Delivery.fromJson)
        .toList();
  }

  Future<Delivery> deliveryDetail(String id) async {
    final result = await _api.get(
      '/api/v1/deliveries/$id',
      auth: RequestAuth.driver,
    );

    return Delivery.fromJson(
      result['delivery'] as Map<String, dynamic>,
    );
  }

  Future<void> startDelivery(String id) async {
    await _api.post(
      '/api/v1/deliveries/$id/start',
      auth: RequestAuth.driver,
    );
  }

  Future<void> completeDelivery(String id) async {
    await _api.post(
      '/api/v1/deliveries/$id/complete',
      auth: RequestAuth.driver,
    );
  }
}
```

### Why this is enough

`DriverApi` becomes the single place where the driver feature knows the REST endpoints.

The driver screens don't care whether the backend uses Express routes, a reverse proxy, or a different API implementation later.

---

# 12. Driver providers

Create:

```text
lib/features/driver/providers/driver_providers.dart
```

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/storage/token_storage.dart';
import '../data/driver_api.dart';
import '../models/delivery.dart';

final driverApiProvider = Provider<DriverApi>((ref) {
  return DriverApi(ref.watch(apiClientProvider));
});

final driverSessionProvider = Provider<DriverSession>((ref) {
  return DriverSession(ref.watch(tokenStorageProvider));
});

class DriverSession {
  DriverSession(this._storage);

  final TokenStorage _storage;

  Future<void> saveToken(String token) {
    return _storage.save(AuthScope.driver, token);
  }

  Future<void> logout() {
    return _storage.clear(AuthScope.driver);
  }
}

final driverDeliveriesProvider =
    FutureProvider.autoDispose<List<Delivery>>((ref) {
  return ref.watch(driverApiProvider).myDeliveries();
});
```

### What Riverpod is doing here

`driverDeliveriesProvider` represents a request whose state is:

```text
loading
or
success(List<Delivery>)
or
error
```

Your UI does not need to manage three separate booleans manually.

---

# 13. Driver login screen

Create:

```text
lib/features/driver/screens/driver_login_screen.dart
```

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/driver_providers.dart';

class DriverLoginScreen extends ConsumerStatefulWidget {
  const DriverLoginScreen({super.key});

  @override
  ConsumerState<DriverLoginScreen> createState() =>
      _DriverLoginScreenState();
}

class _DriverLoginScreenState
    extends ConsumerState<DriverLoginScreen> {
  final _phone = TextEditingController();
  final _password = TextEditingController();

  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await ref.read(driverApiProvider).login(
            phone: _phone.text.trim(),
            password: _password.text,
          );

      await ref.read(driverSessionProvider).saveToken(
            result['token'].toString(),
          );

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/driver/dashboard');
    } catch (error) {
      setState(() => _error = error.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Driver login')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                  ),
                ),
                TextField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                  ),
                ),
                const SizedBox(height: 16),
                if (_error != null)
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _loading ? null : _login,
                  child: _loading
                      ? const CircularProgressIndicator()
                      : const Text('Log in'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

> **Note:** The UI remains ordinary Flutter UI. The backend communication happens through `DriverApi`, and the session token goes through `TokenStorage`.

---

# 14. Driver dashboard

Create:

```text
lib/features/driver/screens/driver_dashboard_screen.dart
```

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/driver_providers.dart';

class DriverDashboardScreen extends ConsumerWidget {
  const DriverDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deliveries = ref.watch(driverDeliveriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My deliveries')),
      body: deliveries.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, _) => Center(
          child: Text('Could not load deliveries: $error'),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text('No deliveries assigned yet.'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(driverDeliveriesProvider);
              await ref.read(driverDeliveriesProvider.future);
            },
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final delivery = items[index];

                return ListTile(
                  title: Text(
                    '${delivery.businessName ?? 'Business'} — '
                    'Order ${delivery.orderId}',
                  ),
                  subtitle: Text('Status: ${delivery.status}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      '/driver/deliveries/${delivery.id}',
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
```

### Why this screen is so small

That is intentional.

The screen says:

```text
Give me deliveries.
Show them.
```

Riverpod handles the asynchronous state.

The API class handles HTTP.

The model handles JSON conversion.

Each responsibility has somewhere sensible to live.

---

# 15. Real-time location service

Create:

```text
lib/core/realtime/socket_service.dart
```

```dart
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService {
  SocketService(this.baseUrl);

  final String baseUrl;

  io.Socket connect() {
    return io.io(
      baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );
  }

  void joinDelivery(
    io.Socket socket,
    String deliveryId,
  ) {
    socket.emit('join-delivery', deliveryId);
  }

  void sendDriverLocation(
    io.Socket socket, {
    required String deliveryId,
    required double latitude,
    required double longitude,
  }) {
    socket.emit('driver-location', {
      'deliveryId': deliveryId,
      'lat': latitude,
      'lng': longitude,
    });
  }
}
```

### Why is Socket.IO not inside the screen?

A screen should not have to know how a websocket connection is configured.

Keeping it here also gives you one place to change the socket implementation later.

For example, if Locora eventually moves from Socket.IO to WebSockets or another service, the tracking feature changes in one place instead of every screen.

---

# 16. Driver GPS service

Create:

```text
lib/core/location/location_service.dart
```

```dart
import 'dart:async';

import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<bool> ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return false;
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Stream<Position> positionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }
}
```

### What `distanceFilter: 10` means

The location stream does not need to send an update every tiny movement.

A 10-meter threshold reduces unnecessary network traffic.

You can tune this later based on:

- battery use;
- GPS accuracy;
- network cost;
- how smooth you want tracking to look.

---

# 17. Live delivery controller

Create:

```text
lib/features/driver/providers/live_delivery_controller.dart
```

```dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../../core/config/app_config.dart';
import '../../../core/location/location_service.dart';
import '../../../core/providers.dart';
import '../../../core/realtime/socket_service.dart';
import '../data/driver_api.dart';

final liveDeliveryControllerProvider =
    AutoDisposeNotifierProviderFamily<
        LiveDeliveryController,
        LiveDeliveryState,
        String>(LiveDeliveryController.new);

class LiveDeliveryState {
  const LiveDeliveryState({
    this.isSharing = false,
    this.error,
  });

  final bool isSharing;
  final String? error;

  LiveDeliveryState copyWith({
    bool? isSharing,
    String? error,
  }) {
    return LiveDeliveryState(
      isSharing: isSharing ?? this.isSharing,
      error: error,
    );
  }
}

class LiveDeliveryController
    extends AutoDisposeFamilyNotifier<LiveDeliveryState, String> {
  StreamSubscription<Position>? _positionSubscription;
  io.Socket? _socket;

  late DriverApi _driverApi;
  late LocationService _locationService;
  late SocketService _socketService;
  late AppConfig _config;

  @override
  LiveDeliveryState build(String deliveryId) {
    _driverApi = ref.watch(driverApiProvider);
    _locationService = LocationService();
    _config = ref.watch(appConfigProvider);
    _socketService = SocketService(_config.apiBaseUrl);

    ref.onDispose(() {
      _positionSubscription?.cancel();
      _socket?.dispose();
    });

    return const LiveDeliveryState();
  }

  Future<void> start() async {
    if (state.isSharing) return;

    final permitted = await _locationService.ensurePermission();

    if (!permitted) {
      state = state.copyWith(
        error: 'Location permission is required to start tracking.',
      );
      return;
    }

    try {
      // Ask the backend to change the delivery to in_progress first.
      await _driverApi.startDelivery(arg);

      _socket = _socketService.connect();
      _socket!.connect();

      _socketService.joinDelivery(_socket!, arg);

      _positionSubscription =
          _locationService.positionStream().listen((position) {
        _socketService.sendDriverLocation(
          _socket!,
          deliveryId: arg,
          latitude: position.latitude,
          longitude: position.longitude,
        );
      });

      state = state.copyWith(
        isSharing: true,
      );
    } catch (error) {
      state = state.copyWith(error: error.toString());
    }
  }

  Future<void> stop() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;

    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;

    await _driverApi.completeDelivery(arg);

    state = state.copyWith(isSharing: false);
  }
}
```

### Important lifecycle

When the driver taps **Start delivery**:

```text
Backend status → in_progress
        ↓
Connect Socket.IO
        ↓
Join delivery room
        ↓
Start GPS stream
        ↓
Send location every time the stream updates
```

When the delivery finishes:

```text
Stop GPS
 ↓
Disconnect socket
 ↓
Backend status → completed
```

> **Realistic limitation:** Flutter Web is not a reliable replacement for a native mobile driver app when the browser is backgrounded, suspended, or the device aggressively limits browser activity. For a serious production delivery fleet, a native Android/iOS driver app will eventually be the better solution. Web is excellent for an MVP and desktop/browser-based testing.

---

# 18. Delivery detail / live tracking screen

Create:

```text
lib/features/driver/screens/delivery_detail_screen.dart
```

```dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/providers.dart';
import '../providers/driver_providers.dart';
import '../providers/live_delivery_controller.dart';

class DeliveryDetailScreen extends ConsumerWidget {
  const DeliveryDetailScreen({
    super.key,
    required this.deliveryId,
  });

  final String deliveryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final delivery = ref.watch(
      FutureProvider.autoDispose(
        (ref) => ref.watch(driverApiProvider).deliveryDetail(deliveryId),
      ),
    );

    final tracking = ref.watch(
      liveDeliveryControllerProvider(deliveryId),
    );

    final config = ref.watch(appConfigProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Delivery $deliveryId'),
      ),
      body: delivery.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, _) => Center(
          child: Text('Could not load delivery: $error'),
        ),
        data: (item) {
          final hasCustomerLocation =
              item.customerLat != null && item.customerLng != null;

          if (!hasCustomerLocation) {
            return const Center(
              child: Text('Customer location is not available yet.'),
            );
          }

          final customer = LatLng(
            item.customerLat!,
            item.customerLng!,
          );

          return Column(
            children: [
              Expanded(
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: customer,
                    initialZoom: 15,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: config.mapboxTileUrl,
                      userAgentPackageName: 'com.locora.web',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: customer,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.home,
                            size: 34,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: tracking.isSharing
                            ? null
                            : () => ref
                                .read(
                                  liveDeliveryControllerProvider(
                                    deliveryId,
                                  ).notifier,
                                )
                                .start(),
                        child: Text(
                          tracking.isSharing
                              ? 'Sharing location'
                              : 'Start delivery',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: tracking.isSharing
                            ? () => ref
                                .read(
                                  liveDeliveryControllerProvider(
                                    deliveryId,
                                  ).notifier,
                                )
                                .stop()
                            : null,
                        child: const Text('Mark delivered'),
                      ),
                    ),
                  ],
                ),
              ),

              if (tracking.error != null)
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  child: Text(
                    tracking.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
```

> **Note:** The example above shows the customer's location. The live driver marker should be driven by the driver's local position for the driver's own UI and by Socket.IO events for another viewer. Keep those concerns separate rather than pretending one widget is responsible for the entire realtime system.

---

# 19. Business feature

The business dashboard has four jobs:

```text
1. Show drivers
2. Remove drivers
3. Show pending deliveries
4. Assign a driver
5. Regenerate API key
```

The business uses a normal login token for dashboard actions.

The API key is **not** the same thing as the dashboard session.

That separation is important:

```text
Business dashboard session
        ↓
Human uses dashboard

Business API key
        ↓
Business backend integrates with Locora API
```

---

# 20. Business API

Create:

```text
lib/features/business/data/business_api.dart
```

```dart
import '../../../core/network/api_client.dart';
import '../../driver/models/delivery.dart';
import '../../driver/models/driver.dart';

class BusinessApi {
  BusinessApi(this._api);

  final ApiClient _api;

  Future<Map<String, dynamic>> login({
    required String name,
    required String password,
  }) {
    return _api.post(
      '/api/v1/businesses/login',
      body: {
        'name': name,
        'password': password,
      },
    );
  }

  Future<List<Driver>> drivers() async {
    final result = await _api.get(
      '/api/v1/businesses/me/drivers',
      auth: RequestAuth.business,
    );

    final items = result['drivers'] as List<dynamic>? ?? [];

    return items
        .whereType<Map<String, dynamic>>()
        .map(Driver.fromJson)
        .toList();
  }

  Future<List<Delivery>> deliveries({String? status}) async {
    final result = await _api.get(
      '/api/v1/businesses/me/deliveries',
      auth: RequestAuth.business,
      queryParameters: status == null ? null : {'status': status},
    );

    final items = result['deliveries'] as List<dynamic>? ?? [];

    return items
        .whereType<Map<String, dynamic>>()
        .map(Delivery.fromJson)
        .toList();
  }

  Future<void> removeDriver(String driverId) async {
    await _api.delete(
      '/api/v1/businesses/me/drivers/$driverId',
      auth: RequestAuth.business,
    );
  }

  Future<void> assignDriver({
    required String deliveryId,
    required String driverId,
  }) async {
    await _api.post(
      '/api/v1/deliveries/$deliveryId/assign',
      auth: RequestAuth.business,
      body: {'driver_id': driverId},
    );
  }

  Future<String> regenerateApiKey() async {
    final result = await _api.post(
      '/api/v1/businesses/me/api-key/regenerate',
      auth: RequestAuth.business,
    );

    return result['api_key'].toString();
  }
}
```

---

# 21. Business providers

Create:

```text
lib/features/business/providers/business_providers.dart
```

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/storage/token_storage.dart';
import '../data/business_api.dart';

final businessApiProvider = Provider<BusinessApi>((ref) {
  return BusinessApi(ref.watch(apiClientProvider));
});

final businessSessionProvider = Provider<BusinessSession>((ref) {
  return BusinessSession(ref.watch(tokenStorageProvider));
});

class BusinessSession {
  BusinessSession(this._storage);

  final TokenStorage _storage;

  Future<void> saveToken(String token) {
    return _storage.save(AuthScope.business, token);
  }

  Future<void> logout() {
    return _storage.clear(AuthScope.business);
  }
}
```

---

# 22. Business login screen

Create:

```text
lib/features/business/screens/business_login_screen.dart
```

The screen follows the same pattern as driver login:

```dart
final result = await ref.read(businessApiProvider).login(
  name: name,
  password: password,
);

await ref.read(businessSessionProvider).saveToken(
  result['token'].toString(),
);
```

Then navigate to:

```text
/business/dashboard
```

### Learning note

Do not duplicate the actual HTTP implementation here.

The screen only coordinates the form.

That is the main architecture rule of this project.

---

# 23. Business dashboard state

For the MVP, one provider can load the dashboard data:

```dart
class BusinessDashboardData {
  const BusinessDashboardData({
    required this.drivers,
    required this.pendingDeliveries,
  });

  final List<Driver> drivers;
  final List<Delivery> pendingDeliveries;
}
```

Then create a notifier that calls:

```dart
final drivers = await api.drivers();
final deliveries = await api.deliveries(status: 'pending');
```

and stores the result.

### Why not make five different use-case classes?

Because the business dashboard is currently one small workflow.

Splitting:

```text
GetDriversUseCase
GetPendingDeliveriesUseCase
AssignDriverUseCase
RemoveDriverUseCase
RegenerateApiKeyUseCase
```

would be reasonable in a much larger application.

For V1, the `BusinessApi` is already a clear boundary.

---

# 24. Business dashboard UI

The dashboard layout should be roughly:

```text
┌─────────────────────────────────────────┐
│ Locora Business Dashboard               │
├─────────────────────────────────────────┤
│                                         │
│ Drivers                                  │
│ ┌─────────────────────────────────────┐ │
│ │ Driver name   phone       Remove    │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ Pending deliveries                      │
│ ┌─────────────────────────────────────┐ │
│ │ Order A-1001      Assign driver    │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ API key                                 │
│ [ Regenerate API key ]                  │
│                                         │
└─────────────────────────────────────────┘
```

Keep the UI simple at first.

Once the workflow is proven, improve:

- tables;
- filters;
- status chips;
- statistics;
- responsive desktop layout;
- delivery map view.

---

# 25. Routing with GoRouter

Create:

```text
lib/core/routing/app_router.dart
```

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/business/screens/business_dashboard_screen.dart';
import '../../features/business/screens/business_login_screen.dart';
import '../../features/driver/screens/driver_dashboard_screen.dart';
import '../../features/driver/screens/driver_login_screen.dart';
import '../../features/driver/screens/delivery_detail_screen.dart';
import '../../features/picker/screens/location_picker_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/driver/login',
  routes: [
    GoRoute(
      path: '/pick/:token',
      builder: (context, state) {
        return LocationPickerScreen(
          token: state.pathParameters['token']!,
        );
      },
    ),
    GoRoute(
      path: '/driver/login',
      builder: (_, __) => const DriverLoginScreen(),
    ),
    GoRoute(
      path: '/driver/dashboard',
      builder: (_, __) => const DriverDashboardScreen(),
    ),
    GoRoute(
      path: '/driver/deliveries/:id',
      builder: (context, state) {
        return DeliveryDetailScreen(
          deliveryId: state.pathParameters['id']!,
        );
      },
    ),
    GoRoute(
      path: '/business/login',
      builder: (_, __) => const BusinessLoginScreen(),
    ),
    GoRoute(
      path: '/business/dashboard',
      builder: (_, __) => const BusinessDashboardScreen(),
    ),
  ],
);
```

Then in `main.dart`:

```dart
import 'package:flutter/material.dart';

import 'core/routing/app_router.dart';

void main() {
  runApp(const ProviderScope(child: LocoraApp()));
}

class LocoraApp extends StatelessWidget {
  const LocoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Locora',
      routerConfig: appRouter,
    );
  }
}
```

Remember to import:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
```

and wrap the app in `ProviderScope`.

### Why GoRouter?

The old `onGenerateRoute` approach works, but GoRouter becomes useful when Locora adds:

- authentication redirects;
- route guards;
- query parameters;
- deep links;
- nested business sections;
- public tracking links.

---

# 26. Authentication redirects

Once token handling is working, add route guards.

The idea is:

```text
/driver/dashboard
       ↓
Driver token exists?
       ├── Yes → show dashboard
       └── No  → /driver/login
```

And:

```text
/business/dashboard
       ↓
Business token exists?
       ├── Yes → show dashboard
       └── No  → /business/login
```

> **Important:** route guards are only a UX feature. They do not replace backend authorization.

---

# 27. Map configuration and important web considerations

The original implementation uses Mapbox raster tiles through `flutter_map`.

That can work well for a Flutter Web MVP.

However:

### Mapbox token

A browser-side public token is not a secret.

Protect it with URL restrictions in your Mapbox account.

### HTTPS

Production browsers increasingly require secure contexts for sensitive browser APIs.

Deploy the frontend and backend over HTTPS.

### Browser location permission

The driver must explicitly grant location access.

### CORS

Your Express backend must allow requests from the production frontend origin.

Do not leave:

```js
origin: '*'
```

permanently once the application is public.

---

# 28. End-to-end local test

Start the backend from Part 1.

Then:

```bash
flutter run -d chrome \
  --dart-define=API_BASE_URL=http://localhost:4000 \
  --dart-define=MAPBOX_TOKEN=pk.your_real_token
```

## Driver flow

1. Register a driver.
2. Log in.
3. Open `/driver/dashboard`.
4. Confirm assigned deliveries appear.
5. Open a delivery.
6. Tap **Start delivery**.
7. Grant browser location permission.
8. Confirm GPS events are being emitted.
9. Tap **Mark delivered**.
10. Confirm the backend status becomes `completed`.

## Customer picker flow

1. Create a delivery through the backend.
2. Get the `picker_url`.
3. Open the URL in Chrome.
4. Move the map underneath the fixed pin.
5. Confirm the location.
6. Confirm the backend stores the coordinates.
7. Confirm the customer can return to the business using the validated return URL.

## Business flow

1. Log in at `/business/login`.
2. Confirm your drivers appear.
3. Create a delivery.
4. Confirm it appears under pending deliveries.
5. Assign the delivery to a driver.
6. Confirm the status changes to `assigned`.
7. Regenerate the API key.
8. Confirm the old key stops working.

---

# 29. Recommended backend/front-end contract

The frontend should assume responses roughly like these.

## Driver login

```json
{
  "token": "JWT...",
  "driver": {
    "id": "driver-id",
    "name": "Driver Name",
    "phone": "+237..."
  }
}
```

## Driver deliveries

```json
{
  "deliveries": [
    {
      "id": "delivery-id",
      "order_id": "A-1001",
      "business_name": "Business A",
      "status": "assigned",
      "customer_lat": 4.147606,
      "customer_lng": 9.287438
    }
  ]
}
```

## Picker confirmation

```json
{
  "success": true,
  "tracking_link": "https://locora.example/track/abc123",
  "return_url": "https://business.example/location-complete"
}
```

## Business drivers

```json
{
  "drivers": [
    {
      "id": "driver-id",
      "name": "Driver Name",
      "phone": "+237..."
    }
  ]
}
```

> **Learning note:** Keeping the API contract explicit makes frontend development much easier because you know what each data class must parse.

---

# 30. Deployment

## Backend

A host with a persistent Node process and managed PostgreSQL is appropriate.

Examples:

- Render
- Railway
- Fly.io

General process:

```text
GitHub repo
 ↓
Deploy Node/Express service
 ↓
Connect PostgreSQL
 ↓
Set production environment variables
 ↓
Run schema/migrations
 ↓
Expose HTTPS API URL
```

Important environment variables will include things such as:

```text
DATABASE_URL
JWT_SECRET
PUBLIC_APP_URL
```

## Frontend

Flutter Web can be deployed to services such as Firebase Hosting, Netlify, or another static hosting provider.

Build:

```bash
flutter build web \
  --dart-define=API_BASE_URL=https://your-api.example.com \
  --dart-define=MAPBOX_TOKEN=pk.your_real_token
```

Then deploy `build/web`.

---

# 31. Production security checklist

Before real businesses use the system:

```text
[ ] JWT_SECRET is long and random
[ ] JWT_SECRET is not committed to Git
[ ] Production Postgres uses SSL
[ ] CORS allows only trusted frontend origins
[ ] Mapbox token has URL restrictions
[ ] Picker tokens expire
[ ] Picker token cannot be reused after its intended lifecycle
[ ] Return URLs are validated/allowlisted
[ ] Business API keys are stored securely and hashed where appropriate
[ ] Regenerating a key invalidates the old key
[ ] Driver authorization is checked server-side
[ ] Business authorization is checked server-side
[ ] Delivery IDs cannot be used to access another business's deliveries
[ ] Rate limiting is considered for public endpoints
[ ] Location update frequency is rate-limited server-side
```

### Especially important

A driver must never be able to change another driver's delivery merely by guessing a delivery ID.

The backend should verify:

```text
current driver
      ↓
is assigned to this delivery?
      ↓
YES → allow
NO  → 403
```

Likewise, a business should only be able to see its own drivers and deliveries.

---

# 32. Testing strategy

You do not need a huge test suite yet.

Start with these.

## Unit tests

Test model parsing:

```text
Delivery.fromJson()
Driver.fromJson()
```

Test token storage behavior.

Test small utility functions.

## API tests

Using Postman or automated integration tests:

```text
register business
register driver
login driver
create delivery
save picker location
assign driver
start delivery
complete delivery
regenerate API key
```

## Manual browser tests

Test at least:

```text
Chrome desktop
Chrome mobile-size viewport
Location permission denied
Location permission granted
Network temporarily unavailable
Expired picker token
Unauthorized dashboard access
```

---

# 33. What NOT to do

## Do not do this

```dart
class DeliveryDetailScreen extends StatefulWidget {
  // 500 lines of HTTP + socket + GPS + UI code
}
```

## Also avoid this for V1

```text
Screen
 ↓
Controller
 ↓
UseCase
 ↓
Repository
 ↓
RepositoryImpl
 ↓
RemoteDataSource
 ↓
HTTP client
 ↓
Server
```

when each layer contains almost no logic.

## Prefer this

```text
Screen
 ↓
Riverpod provider/notifier
 ↓
Feature API/data class
 ↓
Core API client
 ↓
Server
```

And for realtime:

```text
Screen
 ↓
Riverpod controller
 ↓
LocationService + SocketService
 ↓
Locora backend
```

This gives you separation without burying a relatively small project in abstractions.

---

# 34. Future migration path

If Locora grows significantly, you can introduce stronger boundaries later.

For example:

```text
Current V1

feature
 ├── data
 ├── models
 ├── providers
 └── screens
```

can become:

```text
Larger V2

feature
 ├── data
 ├── domain
 ├── presentation
 └── services
```

You can then add:

- repositories;
- use cases;
- immutable state models;
- generated serialization;
- more isolated domain logic;
- dedicated testing layers.

You do **not** need to build those layers today just because they might be useful later.

---

# 35. Recommended build order

Build Locora in this order so you always have something testable.

## Phase 1 — Foundation

```text
[ ] Flutter Web project
[ ] Riverpod
[ ] GoRouter
[ ] AppConfig
[ ] TokenStorage
[ ] ApiClient
```

## Phase 2 — Customer picker

```text
[ ] Picker route
[ ] Mapbox map
[ ] Fixed-center pin
[ ] Confirm location
[ ] Backend location endpoint
[ ] Return URL flow
```

## Phase 3 — Driver authentication

```text
[ ] Register
[ ] Login
[ ] Save driver token
[ ] Driver route guard
```

## Phase 4 — Driver deliveries

```text
[ ] Delivery model
[ ] DriverApi
[ ] Dashboard
[ ] Delivery detail
```

## Phase 5 — Live tracking

```text
[ ] Location permission
[ ] LocationService
[ ] SocketService
[ ] Start delivery
[ ] Driver GPS stream
[ ] Complete delivery
```

## Phase 6 — Business dashboard

```text
[ ] Business login
[ ] Driver list
[ ] Remove driver
[ ] Pending deliveries
[ ] Assign driver
[ ] API key regeneration
```

## Phase 7 — Public tracking

```text
[ ] /track/:token
[ ] Socket room subscription
[ ] Customer-facing map
[ ] Delivery status
```

## Phase 8 — Production hardening

```text
[ ] HTTPS
[ ] CORS restrictions
[ ] Rate limiting
[ ] Return URL allowlist
[ ] Token expiry checks
[ ] Better error handling
[ ] Monitoring/logging
```

---

# 36. What the finished Locora architecture should feel like

The project should feel like this when you're working on it:

```text
I need to change the picker
        ↓
features/picker/

I need to change driver login
        ↓
features/driver/

I need to change business dashboard
        ↓
features/business/

I need to change HTTP behavior
        ↓
core/network/

I need to change token storage
        ↓
core/storage/

I need to change live sockets
        ↓
core/realtime/

I need to change browser GPS handling
        ↓
core/location/
```

That is the main reason for this structure.

You should be able to predict **where code belongs** without thinking about architecture theory every time you create a file.

---

# 37. Final recommendation

For Locora V1, use:

```text
Flutter Web
+ Riverpod
+ GoRouter
+ Feature-first folders
+ Feature API/data classes
+ Typed models
+ Shared core services
+ REST
+ Socket.IO
```

Do not spend your development time building a perfect architecture before the actual product flow works.

The most valuable thing to prove first is:

```text
Business
  ↓
Customer picks a real house
  ↓
Locora stores it correctly
  ↓
Driver gets the delivery
  ↓
Driver starts the trip
  ↓
Locora receives live GPS
  ↓
Someone else can see the driver's position
```

Once that loop works reliably, the architecture can evolve with the product instead of being designed around hypothetical future complexity.

---

# 38. Next major feature after V1

The best next feature is **public customer tracking**.

The backend already has the key concept needed for it: a delivery-specific tracking token/socket room.

The customer-facing screen can then be:

```text
Customer opens tracking link
        ↓
Map loads
        ↓
Business/customer location appears
        ↓
Driver location arrives through Socket.IO
        ↓
Driver marker moves live
        ↓
Delivery status updates
```

That turns Locora from a location-selection tool into a complete **delivery-location + live-tracking platform**.
