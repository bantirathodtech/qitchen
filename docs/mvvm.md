# MVVM Architecture - File Structure and Responsibilities

## 1. Core/Base Files

### base_model.dart

- Base class for all models
- Provides common serialization methods
- Enforces model structure

```dart
abstract class BaseModel<T> {
  Map<String, dynamic> toJson();

  T fromJson(Map<String, dynamic> json);
}
```

**Responsibilities**:

* Contract for data models
* JSON serialization patterns
* Type safety enforcement
* Common model utilities

### base_service.dart

- Network communication base
- Error handling wrapper
- API response standardization

```dart
abstract class BaseService {
  final ApiService _apiService;

  Future<ApiResponse<T>> safeApiCall<T>(Future<T> apiCall);

  Future<ApiResponse<T>> handleResponse<T>(Response response);
}
```

**Responsibilities**:

* API call wrapping
* Response standardization
* Network error catching
* Timeout handling

### base_repository.dart

- Data management contract
- Cache handling patterns
- Error propagation

```dart
abstract class BaseRepository<T> {
  final BaseService service;
  final CacheManager cache;

  Future<T> getData();

  Future<void> cacheData(T data);
}
```

**Responsibilities**:

* Data flow management
* Cache coordination
* Service coordination
* Error handling strategy

### base_viewmodel.dart

- UI state management base
- Loading state handling
- Error state management

```dart
abstract class BaseViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  void updateState();

  void handleError(Exception error);
}
```

**Responsibilities**:

* State management patterns
* Loading state control
* Error state handling
* UI updates coordination

## 2. Network Layer

### api_service.dart

- HTTP client wrapper
- Request formatting
- Response parsing

```dart
class ApiService {
  final Dio _dio;

  Future<Response> get(String url);

  Future<Response> post(String url, dynamic data);

  void handleError(DioError error);
}
```

**Responsibilities**:

* API communication
* Headers management
* Request formatting
* Response handling
* Timeout management

### api_response.dart

- Standard response wrapper
- Error formatting
- Data encapsulation

```dart
class ApiResponse<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  factory ApiResponse.success(T data);

  factory ApiResponse.error(String message);
}
```

**Responsibilities**:

* Response standardization
* Error formatting
* Success/failure states
* Data type safety

## 3. Data Layer

### feature_model.dart

- Data structure
- JSON parsing
- Data validation

```dart
class FeatureModel extends BaseModel<FeatureModel> {
  final String id;
  final String name;

  FeatureModel.fromJson();

  Map<String, dynamic> toJson();
}
```

**Responsibilities**:

* Data structure definition
* Property validation
* Type conversion
* JSON serialization

### feature_service.dart

- API endpoint calls
- Request formatting
- Raw response handling

```dart
class FeatureService extends BaseService {
  Future<ApiResponse<T>> getData<T>();

  Future<ApiResponse<T>> updateData<T>(T data);
}
```

**Responsibilities**:

* API endpoint mapping
* Request formatting
* Response parsing
* Network error handling

### feature_repository.dart

- Business logic
- Data transformation
- Cache management

```dart
class FeatureRepository {
  final FeatureService _service;
  final CacheManager _cache;

  Future<FeatureModel> getData();

  Future<void> processData(FeatureModel data);
}
```

**Responsibilities**:

* Data coordination
* Business rules
* Cache strategy
* Error handling
* Data transformation

## 4. Presentation Layer

### feature_viewmodel.dart

- UI state management
- Data formatting
- User interaction handling

```dart
class FeatureViewModel extends BaseViewModel {
  final FeatureRepository _repository;
  FeatureModel? _data;

  Future<void> loadData();

  void updateUI();
}
```

**Responsibilities**:

* UI state management
* Data formatting
* Loading states
* Error handling
* User action processing

### feature_screen.dart

- Screen layout
- User interaction
- State consumption

```dart
class FeatureScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<FeatureViewModel>();
  }
}
```

**Responsibilities**:

* Layout structure
* State consumption
* User interaction
* Navigation
* UI updates

### feature_widget.dart

- Reusable UI components
- Presentation logic
- State display

```dart
class FeatureWidget extends StatelessWidget {
  final FeatureModel data;

  Widget build(BuildContext context);
}
```

**Responsibilities**:

* Component presentation
* State visualization
* User input handling
* Styling
* Reusability

## 5. Utility Layer

### app_logger.dart

- Logging standardization
- Debug information
- Error tracking

```dart
class AppLogger {
  static void debug(String message);

  static void error(String message, StackTrace stackTrace);
}
```

**Responsibilities**:

* Log management
* Error tracking
* Debug information
* Performance monitoring

### preferences_manager.dart

- Local storage
- Data persistence
- Cache management

```dart
class PreferencesManager {
  Future<void> saveData(String key, dynamic value);

  Future<T?> getData<T>(String key);
}
```

**Responsibilities**:

* Data persistence
* Cache management
* Storage optimization
* Data encryption

## Data Flow

```
UI Action → ViewModel → Repository → Service → API
API Response → Service → Repository → ViewModel → UI Update
```

Would you like me to elaborate on any specific component or responsibility?