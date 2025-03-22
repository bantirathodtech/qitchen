lib/
├── core/
│   ├── config/
│   │   ├── app_environment_config.dart    // Environment & app configurations
│   │   ├── api_security_config.dart       // API security settings
│   │   └── feature_flags_config.dart      // Feature toggles & flags
│   │
│   ├── network/
│   │   ├── network_http_client.dart       // Base HTTP client
│   │   ├── network_request_interceptor.dart  // Request handling
│   │   ├── network_response_interceptor.dart // Response handling
│   │   ├── api_url_manager.dart           // URL endpoints
│   │   ├── api_response_cache.dart        // Response caching
│   │   └── network_error_manager.dart     // Error handling
│   │
│   ├── storage/
│   │   ├── secure_credentials_storage.dart  // Secure storage
│   │   ├── user_preferences_manager.dart    // User preferences
│   │   └── offline_data_cache.dart         // Offline data
│   │
│   └── utils/
│       ├── debug_log_manager.dart         // Logging
│       ├── network_connectivity_utils.dart // Network utilities
│       ├── text_formatter_utils.dart      // Text formatting
│       └── datetime_formatter_utils.dart   // Date handling
│
├── data/
│   ├── graphql/
│   │   ├── mutations/
│   │   │   ├── customer_mutations.dart    // Customer mutations
│   │   │   ├── order_mutations.dart       // Order mutations
│   │   │   └── payment_mutations.dart     // Payment mutations
│   │   │
│   │   ├── queries/
│   │   │   ├── customer_queries.dart      // Customer queries
│   │   │   ├── order_queries.dart         // Order queries
│   │   │   └── product_queries.dart       // Product queries
│   │   │
│   │   └── shared_fragments.dart          // Shared GraphQL fragments
│   │
│   └── models/
│       ├── user_account_model.dart        // User model
│       ├── product_inventory_model.dart    // Product model
│       ├── order_transaction_model.dart    // Order model
│       ├── shopping_cart_model.dart        // Cart model
│       └── payment_wallet_model.dart       // Payment model
│
├── features/
│   ├── cart/
│   │   └── services/
│   │       └── shopping_cart_manager.dart  // Cart operations
│   │
│   ├── home/
│   │   └── services/
│   │       └── storefront_manager.dart     // Home/store operations
│   │
│   ├── orders/
│   │   └── services/
│   │       └── order_transaction_manager.dart  // Order operations
│   │
│   ├── products/
│   │   └── services/
│   │       └── product_catalog_manager.dart    // Product operations
│   │
│   └── profile/
│       └── services/
│           └── user_profile_manager.dart       // Profile operations
│
└── services/
├── authentication_manager.dart        // Auth operations
├── payment_transaction_manager.dart   // Payment operations
└── dependency_injector.dart          // Service dependencies