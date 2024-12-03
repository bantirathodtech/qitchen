Cached API Client


Implements caching using Dio interceptors
Uses SharedPreferences for cache storage
Features:

Cache duration control
Request/Response interceptors
Automatic cache invalidation
Error handling


Includes CacheInterceptor and SharedPreferencesCacheService

This structure follows a modular approach where:

URLs are centralized
Queries are organized by domain
API communication is handled through a single service
Local storage is managed consistently
Business logic is separated by feature
Caching is implemented at the client level