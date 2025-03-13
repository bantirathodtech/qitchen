// class AppUrls {
//   // Base URL
//   static const String baseUrl = 'https://dev-api.cwcloud.in/';
//
//   // Authentication endpoints
//   static const String createUserAccount = '${baseUrl}api/verifyCustomer1';
//   static const String verifyCustomer = '${baseUrl}api/verifyCustomer1';
//
//   // Store and products endpoints
//   static const String getStore = '${baseUrl}api/getStores1';
//   static const String getProducts = '${baseUrl}api/getProducts';
//   static const String getFavorites = '${baseUrl}api/favorites';
//
//   // Order endpoints
//   static const String createOrder = '${baseUrl}api/orders';
//   static const String getOrders = '${baseUrl}api/getOrders1';
//   static const String redisOrder = '/api/redis_order';
//
//   // Wallet endpoints - Updated for better clarity
//   static const String wallet = '${baseUrl}api/wallet'; // Base wallet endpoint
//   static const String upsertWallet = wallet; // POST endpoint for transactions
//   static const String getWalletBalance =
//       wallet; // GET endpoint for balance (append wallet ID)
//   static const String walletTransactions =
//       '${wallet}/transactions'; // GET transactions
// }

class AppUrls {
  // Base URL
  static const String baseUrl = 'https://hub.caftrix.cwcloud.in/';

  // AUTH
  static const String createUserAccount = '${baseUrl}api/verifyCustomer1';
  static const String verifyCustomer = '${baseUrl}api/verifyCustomer1';

  // STORE
  // static const String getStore = '${baseUrl}api/getStores1';
  static const String getStore = '${baseUrl}api/food-ordering/stores'; //11/03/24


  // PRODUCTS
  // static const String getProducts = '${baseUrl}api/getProducts';
  static const String getProducts = '${baseUrl}api/getProducts';

  static const String getFavorites = '${baseUrl}api/food-ordering/favorites';

  // ORDER
  static const String createOrder = '${baseUrl}api/orders';
  static const String getOrders = '${baseUrl}api/getOrders1';
  static const String redisOrder = '/api/redis_order';

  // WALLET
  static const String wallet = '${baseUrl}api/wallet'; // Base wallet endpoint
  static const String upsertWallet = wallet; // POST endpoint for transactions
  static const String getWalletBalance =
      wallet; // GET endpoint for balance (append wallet ID)
  static const String walletTransactions =
      '${wallet}/transactions'; // GET transactions
}



// class AppUrls {
//   // Base URL
//   static const String baseUrl = 'https://services.caftrix.cwcloud.in/retail-services/graphql';
//
//   // Authentication endpoints
//   static const String createUserAccount = baseUrl;
//   static const String verifyCustomer = baseUrl;
//
//   // Store and products endpoints
//   static const String getStore = baseUrl;
//   static const String getProducts = baseUrl;
//   static const String getFavorites = baseUrl;
//
//   // Order endpoints
//   static const String createOrder = baseUrl;
//   static const String getOrders = baseUrl;
//   static const String redisOrder = 'redis://52.66.127.28:6379';
//
//   // Wallet endpoints - Updated for better clarity
//   static const String wallet = baseUrl;
//   static const String upsertWallet = wallet;
//   static const String getWalletBalance = wallet;
//   static const String walletTransactions = wallet;
//
//   // Additional Constants
//   static const String xApiKey = '8ccaf3fe5af65e922653aef';
//   static const String typeSenseUrl = 'typesense.exceloid.in';
//   static const int typeSensePort = 8108;
//   static const String typeSenseProtocol = 'https';
//
//   // Logo
//   static const String logo = 'https://exceloid-image-master.s3.amazonaws.com/Sproutz+logo+%281%29.svg';
// }
