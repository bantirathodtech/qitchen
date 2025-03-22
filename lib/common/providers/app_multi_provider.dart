import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../core/api/api_base_service.dart';
import '../../features/auth/profile/profile_repository.dart';
import '../../features/auth/profile/profile_viewmodel.dart';
import '../../features/auth/signup/repository/sign_up_repository.dart';
import '../../features/auth/signup/service/signup_service.dart';
import '../../features/auth/signup/viewmodel/sign_up_viewmodel.dart';
import '../../features/auth/verify/repository/verify_repository.dart';
import '../../features/auth/verify/service/verify_service.dart';
import '../../features/auth/verify/viewmodel/verify_viewmodel.dart';
import '../../features/favorite/favorite_manager.dart';
import '../../features/history/repository/order_history_repository.dart';
import '../../features/history/service/order_history_service.dart';
import '../../features/history/state/order_history_state.dart';
import '../../features/history/state/wallet_history_state.dart';
import '../../features/history/viewmodel/order_history_viewmodel.dart';
import '../../features/history/viewmodel/wallet_history_viewmodel.dart';
import '../../features/home/cart/multiple/cart_manager.dart';
import '../../features/ordering/order/data/repositories/kitchen_order_repository.dart';
import '../../features/ordering/order/data/repositories/payment_order_repository.dart';
import '../../features/ordering/order/provider/kitchen_order_state.dart';
import '../../features/ordering/order/provider/payment_order_state.dart';
import '../../features/ordering/order/services/kitchen_api_service.dart';
import '../../features/ordering/order/services/payment_api_service.dart';
import '../../features/ordering/order/viewmodel/kitchen_order_viewmodel.dart';
import '../../features/ordering/order/viewmodel/payment_order_viewmodel.dart';
import '../../features/ordering/wallet/repository/wallet_repository.dart';
import '../../features/ordering/wallet/service/wallet_service.dart';
import '../../features/ordering/wallet/viewmodel/wallet_viewmodel.dart';
import '../../features/products/state/product_state.dart';
import '../../features/products/repository/product_repository.dart';
import '../../features/products/service/product_service_redis.dart';
import '../../features/products/viewmodel/product_viewmodel.dart';
import '../../features/store/provider/store_provider.dart';
import '../../features/store/service/store_service.dart';
import '../../features/store/viewmodel/home_viewmodel.dart';

List<SingleChildWidget> getProviders() {
  return [
    //TODO: First set up core providers
    Provider<Dio>(create: (_) => Dio()),
    ProxyProvider<Dio, ApiBaseService>(
      update: (_, dio, __) => ApiBaseService(dio: dio),
    ),

    //TODO: Set up StoreProvider first as it's the source of truth for businessUnitId
    ChangeNotifierProvider<StoreProvider>(
      create: (_) => StoreProvider(),
    ),

    //TODO: Set up CartManager with StoreProvider dependency
    ChangeNotifierProxyProvider<StoreProvider, CartManager>(
      create: (context) => CartManager(
        Provider.of<StoreProvider>(context, listen: false),
      ),
      update: (_, storeProvider, previous) =>
          previous ?? CartManager(storeProvider),
    ),
    ChangeNotifierProxyProvider<StoreProvider, FavoriteManager>(
      create: (context) => FavoriteManager(
        context.read<StoreProvider>(),
      ),
      update: (context, storeProvider, previous) {
        return previous ?? FavoriteManager(storeProvider);
      },
    ),
    //TODO: Home feature
    ProxyProvider<ApiBaseService, StoreService>(
      update: (_, apiBaseService, __) =>
          StoreService(apiBaseService: apiBaseService),
    ),
    ChangeNotifierProxyProvider<StoreService, HomeViewModel>(
      create: (context) => HomeViewModel(
        storeService: Provider.of<StoreService>(context, listen: false),
        storeProvider: Provider.of<StoreProvider>(context, listen: false),
      ),
      update: (context, storeService, viewModel) =>
          viewModel ??
          HomeViewModel(
            storeService: storeService,
            storeProvider: Provider.of<StoreProvider>(context, listen: false),
          ),
    ),

    //TODO: Product related providers
    ProxyProvider<ApiBaseService, ProductService>(
      update: (_, apiBaseService, __) =>
          ProductService(apiBaseService: apiBaseService),
    ),
    ProxyProvider<ProductService, ProductRepository>(
      update: (_, productService, __) =>
          ProductRepository(productService: productService),
    ),
    // ChangeNotifierProxyProvider2<ProductRepository, StoreProvider,
    //     ProductViewModel>(
    //   create: (context) => ProductViewModel(
    //     repository: context.read<ProductRepository>(),
    //     storeProvider: context.read<StoreProvider>(),
    //   ),
    //   update: (context, repository, storeProvider, previous) =>
    //       previous ??
    //       ProductViewModel(
    //         repository: repository,
    //         storeProvider: storeProvider,
    //       ),
    // ),

    ChangeNotifierProvider<ProductsNotifier>(
      create: (context) => ProductsNotifier(),
    ),
    ChangeNotifierProxyProvider3<ProductRepository, ProductsNotifier,
        StoreProvider, ProductViewModel>(
      create: (context) => ProductViewModel(
        repository: context.read<ProductRepository>(),
        state: context.read<ProductsNotifier>(),
      ),
      update: (context, repository, state, storeProvider, previous) =>
          previous ??
          ProductViewModel(
            repository: repository,
            state: state,
          ),
    ),

    // Wallet feature
    ProxyProvider<ApiBaseService, WalletService>(
      update: (_, apiBaseService, __) =>
          WalletService(apiBaseService: apiBaseService),
    ),
    ProxyProvider<WalletService, WalletRepository>(
      update: (_, walletService, __) =>
          WalletRepository(walletService: walletService),
    ),
    // ChangeNotifierProxyProvider<WalletService, WalletViewModel>(
    //   create: (context) => WalletViewModel(
    //     walletService: context.read<WalletService>(),
    //   ),
    //   update: (_, walletService, previous) =>
    //       previous ?? WalletViewModel(walletService: walletService),
    // ),

    // Then update WalletViewModel provider to use repository
    ChangeNotifierProxyProvider<WalletRepository, WalletViewModel>(
      create: (context) => WalletViewModel(
        repository: context.read<WalletRepository>(),
      ),
      update: (_, repository, previous) =>
          previous ?? WalletViewModel(repository: repository),
    ),

    //TODO: Verify feature
    ProxyProvider<ApiBaseService, VerifyService>(
      update: (_, apiBaseService, __) =>
          VerifyService(apiBaseService: apiBaseService),
    ),
    ProxyProvider<VerifyService, VerifyRepository>(
      update: (_, verifyService, __) =>
          VerifyRepository(verifyService: verifyService),
    ),
    ChangeNotifierProxyProvider<VerifyRepository, VerifyViewModel>(
      create: (context) => VerifyViewModel(
        verifyRepository: Provider.of<VerifyRepository>(context, listen: false),
      ),
      update: (_, repository, viewModel) =>
          viewModel ?? VerifyViewModel(verifyRepository: repository),
    ),

    //TODO: SignUp feature
    ProxyProvider<ApiBaseService, SignUpService>(
      update: (_, apiBaseService, __) =>
          SignUpService(apiBaseService: apiBaseService),
    ),
    ProxyProvider<SignUpService, SignUpRepository>(
      update: (_, signUpService, __) =>
          SignUpRepository(signUpService: signUpService),
    ),
    ChangeNotifierProxyProvider<SignUpRepository, SignUpViewModel>(
      create: (context) => SignUpViewModel(
        repository: Provider.of<SignUpRepository>(context, listen: false),
      ),
      update: (_, repository, viewModel) =>
          viewModel ?? SignUpViewModel(repository: repository),
    ),

    // Profile Repository with SignUpService dependency
    ProxyProvider<SignUpService, ProfileRepository>(
      update: (_, signUpService, __) =>
          ProfileRepository(signUpService: signUpService),
    ),

// Profile ViewModel with Repository dependency
    ChangeNotifierProxyProvider<ProfileRepository, ProfileViewModel>(
      create: (context) => ProfileViewModel(
        repository: context.read<ProfileRepository>(),
      ),
      update: (_, repository, viewModel) =>
          viewModel ?? ProfileViewModel(repository: repository),
    ),
    //=============== Regular Order Feature ===============

    // // Order Service
    // ProxyProvider<ApiBaseService, OrderService>(
    //   update: (_, apiBaseService, __) =>
    //       OrderService(apiBaseService: apiBaseService),
    // ),
    //
    // // Order Repository
    // ProxyProvider<OrderService, OrderRepository>(
    //   update: (_, orderService, __) => OrderRepository(orderService),
    // ),
    //
    // // Order Provider
    // ChangeNotifierProvider(
    //   create: (_) => OrderProvider(),
    // ),
    //
    // // Order ViewModel
    // ChangeNotifierProxyProvider2<OrderRepository, OrderProvider,
    //     OrderViewModel>(
    //   create: (context) => OrderViewModel(
    //     repository: context.read<OrderRepository>(),
    //     orderProvider: context.read<OrderProvider>(),
    //   ),
    //   update: (_, repository, orderProvider, previous) =>
    //       previous ??
    //       OrderViewModel(
    //         repository: repository,
    //         orderProvider: orderProvider,
    //       ),
    // ),

    //=============== Redis Order Feature ===============
    // // Redis Order Service
    // ProxyProvider<ApiBaseService, RedisOrderService>(
    //   update: (_, apiBaseService, __) =>
    //       RedisOrderService(apiBaseService: apiBaseService),
    // ),
    //
    // // Redis Order Repository
    // ProxyProvider<RedisOrderService, RedisOrderRepository>(
    //   update: (_, redisOrderService, __) =>
    //       RedisOrderRepository(redisOrderService),
    // ),
    //
    // // Redis Order Provider
    // ChangeNotifierProvider(
    //   create: (_) => RedisOrderProvider(),
    // ),
    //
    // // Redis Order ViewModel
    // ChangeNotifierProxyProvider2<RedisOrderRepository, RedisOrderProvider,
    //     RedisOrderViewModel>(
    //   create: (context) => RedisOrderViewModel(
    //     repository: context.read<RedisOrderRepository>(),
    //     redisOrderProvider: context.read<RedisOrderProvider>(),
    //   ),
    //   update: (_, repository, redisOrderProvider, previous) =>
    //       previous ??
    //       RedisOrderViewModel(
    //         repository: repository,
    //         redisOrderProvider: redisOrderProvider,
    //       ),
    // ),
    //=============== Payment Order Feature ===============
    // Payment Order Service
    ProxyProvider<ApiBaseService, PaymentApiService>(
      update: (_, apiBaseService, __) =>
          PaymentApiService(apiService: apiBaseService),
    ),

    // Payment Order Repository
    ProxyProvider<PaymentApiService, PaymentOrderRepository>(
      update: (_, paymentApiService, __) =>
          PaymentOrderRepository(apiService: paymentApiService),
    ),

    // Payment Order State
    ChangeNotifierProvider<PaymentOrderState>(
      create: (_) => PaymentOrderState(),
    ),

    // Payment Order ViewModel
    ChangeNotifierProxyProvider2<PaymentOrderRepository, PaymentOrderState,
        PaymentOrderViewModel>(
      create: (context) => PaymentOrderViewModel(
        repository: context.read<PaymentOrderRepository>(),
        state: context.read<PaymentOrderState>(),
      ),
      update: (_, repository, state, previous) =>
          previous ??
          PaymentOrderViewModel(
            repository: repository,
            state: state,
          ),
    ),

    //=============== Kitchen Order Feature ===============
    // Kitchen Order Service
    ProxyProvider<ApiBaseService, KitchenApiService>(
      update: (_, apiBaseService, __) =>
          KitchenApiService(apiService: apiBaseService),
    ),

    // Kitchen Order Repository
    ProxyProvider<KitchenApiService, KitchenOrderRepository>(
      update: (_, kitchenApiService, __) =>
          KitchenOrderRepository(apiService: kitchenApiService),
    ),

    // Kitchen Order State
    ChangeNotifierProvider<KitchenOrderState>(
      create: (_) => KitchenOrderState(),
    ),

    // Kitchen Order ViewModel
    ChangeNotifierProxyProvider2<KitchenOrderRepository, KitchenOrderState,
        KitchenOrderViewModel>(
      create: (context) => KitchenOrderViewModel(
        repository: context.read<KitchenOrderRepository>(),
        state: context.read<KitchenOrderState>(),
      ),
      update: (_, repository, state, previous) =>
          previous ??
          KitchenOrderViewModel(
            repository: repository,
            state: state,
          ),
    ),

    //TODO: Order History feature
    ProxyProvider<ApiBaseService, OrderHistoryService>(
      update: (_, apiBaseService, __) =>
          OrderHistoryService(apiBaseService: apiBaseService),
    ),
    ProxyProvider<OrderHistoryService, OrderHistoryRepository>(
      update: (_, historyService, __) => OrderHistoryRepository(historyService),
    ),
// Add StateNotifier provider
    ChangeNotifierProvider<OrderHistoryStateNotifier>(
      create: (_) => OrderHistoryStateNotifier(),
    ),
// Update ViewModel provider to include both repository and state
    ProxyProvider3<OrderHistoryRepository, OrderHistoryStateNotifier,
        CartManager, OrderHistoryViewModel>(
      update: (_, repository, stateNotifier, cartManager, previousViewModel) =>
          previousViewModel ??
          OrderHistoryViewModel(
            repository: repository,
            stateNotifier: stateNotifier,
            cartManager: cartManager,
          ),
    ),

    ChangeNotifierProvider(create: (_) => WalletHistoryStateNotifier()),
    Provider(
      create: (context) => WalletHistoryViewModel(
        walletService: context.read<WalletService>(),
        stateNotifier: context.read<WalletHistoryStateNotifier>(),
      ),
    ),
  ];
}
