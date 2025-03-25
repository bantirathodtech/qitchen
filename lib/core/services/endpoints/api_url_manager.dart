class AppUrls {
  // Base URL
  static const String baseUrl = 'https://hub.caftrix.cwcloud.in/';
  static const String foodOrderingBase = '${baseUrl}api/food-ordering/';

  // AUTH
  static const String createUserAccount = '${foodOrderingBase}verifyCustomer';
  static const String verifyCustomer = '${foodOrderingBase}verifyCustomer';

  // STORE
  static const String getStore = '${foodOrderingBase}stores';

  // PRODUCTS
  static const String getProducts = '${foodOrderingBase}products';
  static const String getFavorites = '${foodOrderingBase}favorites';

  // ORDER
  static const String createOrder = '${foodOrderingBase}orders';
  static const String redisOrder = '${foodOrderingBase}redisOrder';

  // HISTORY
  static const String getOrders = '${foodOrderingBase}orders';

  // WALLET
  static const String wallet = '${foodOrderingBase}wallet'; // Base wallet endpoint
  static const String upsertWallet = wallet; // POST endpoint for transactions
  static const String getWalletBalance = wallet; // GET endpoint for balance (append wallet ID)
  static const String walletTransactions = '${wallet}transactions'; // GET transactions
}

