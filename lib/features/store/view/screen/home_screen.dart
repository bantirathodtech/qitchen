// File: screens/home/home_screen.dart

import 'package:cw_food_ordering/features/store/model/store_models.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../common/log/loggers.dart';
import '../../../../../../common/styles/app_text_styles.dart';
import '../../../../core/network/network_helper.dart';
import '../../../../core/search_overlay/1/search_icon.dart';
import '../../../../data/cache/app_prefetch_manager.dart';
import '../../../../data/db/app_preferences.dart';
import '../../../auth/profile/profile_screen.dart';
import '../../../home/error_display.dart';
import '../../../home/loading_indicator.dart';
import '../../../home/location_selection_screen.dart';
import '../../../home/widgets/restaurant_list.dart';
import '../../../products/view/product_screen.dart';
import '../../provider/store_provider.dart';
import '../../viewmodel/home_viewmodel.dart';
import '../widgets/food_court_banner.dart';

// Enhanced normalization function to handle all cases
String normalizeSearchText(String text) {
  return text
      .toLowerCase()
      .replaceAll('-', ' ') // First replace dashes with spaces
      .replaceAll('_', ' ') // Replace underscores with spaces
      .replaceAll(RegExp(r'\s+'), '') // Remove all spaces
      .trim();
}

class HomeScreen extends StatefulWidget {
  static const String TAG = '[HomeScreen]';
  static const String ROUTE = '/home';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  String currentLocation = "Chennai, AMB 6";
  bool _isInitializing = true; // New flag to track initial loading state

  // Location state variables
  String? selectedCity;
  String? selectedArea;

  @override
  void initState() {
    super.initState();
    AppLogger.logInfo('${HomeScreen.TAG}: Initializing HomeScreen');

    // Set initial loading flag
    setState(() => _isInitializing = true);

    // Load data & location in parallel
    _loadInitialData();

    // Trigger prefetch in background after initial render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppPrefetchManager.prefetchAppData(context);
    });
  }

  // Combined loading method to handle all initial data needs
  Future<void> _loadInitialData() async {
    try {
      // Load both location and store data in parallel
      await Future.wait([
        _loadSavedLocation(),
        _initializeData(),
      ]);
    } finally {
      // Always mark initialization as complete regardless of outcome
      if (mounted) {
        setState(() => _isInitializing = false);
      }
    }
  }

  Future<void> _loadSavedLocation() async {
    final savedLocation = await AppPreference.getSelectedLocation();

    if (mounted && savedLocation['city'] != null && savedLocation['area'] != null) {
      setState(() {
        selectedCity = savedLocation['city'];
        selectedArea = savedLocation['area'];
        currentLocation = "${savedLocation['city']}, ${savedLocation['area']}";
      });
    }
  }

  // Improved data initialization with better error handling
  Future<void> _initializeData() async {
    // Safety check: don't proceed if widget is disposed
    if (!mounted) return;

    try {
      AppLogger.logInfo('${HomeScreen.TAG}: Loading initial store data');

      // Get viewModel instance
      final viewModel = context.read<HomeViewModel>();

      // Reset any previous error state
      viewModel.clearError();

      // Check if data is already cached in the viewModel
      if (viewModel.storeData != null) {
        AppLogger.logInfo('${HomeScreen.TAG}: Using already loaded store data');
        return; // Skip API call if we already have data
      }

      // Check device connectivity before making network requests
      final isConnected = await NetworkHelper.isConnected();
      if (!isConnected) {
        throw Exception('No internet connection. Please check your network settings.');
      }

      // Fetch data with timeout protection
      await viewModel.fetchStores().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          AppLogger.logError('${HomeScreen.TAG}: Store data fetch timed out');
          throw Exception('Connection timed out. Please check your internet connection.');
        },
      );

      AppLogger.logInfo('${HomeScreen.TAG}: Store data loaded successfully');
    } catch (e) {
      // Error handling - log and update UI with error message
      AppLogger.logError('${HomeScreen.TAG}: Error loading initial data: $e');

      // Only update UI if widget is still mounted
      if (mounted) {
        // Pass error to ViewModel so the error state shows in UI
        context.read<HomeViewModel>().setError(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<HomeViewModel>(
          builder: (context, viewModel, child) {
            // CASE 1: Initial loading - show loading indicator
            if (_isInitializing) {
              return const LoadingIndicator();
            }

            // CASE 2: ViewModel is actively loading - show loading indicator
            if (viewModel.isLoading) {
              return const LoadingIndicator();
            }

            // CASE 3: Error state with data - show error but allow retry
            if (viewModel.error.isNotEmpty && viewModel.storeData == null) {
              return ErrorDisplay(
                error: viewModel.error,
                onRetry: () {
                  setState(() => _isInitializing = true);
                  _initializeData().then((_) {
                    if (mounted) setState(() => _isInitializing = false);
                  });
                },
              );
            }

            // CASE 4: No data but no error - show better message with retry
            if (viewModel.storeData == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('We\'re having trouble loading the restaurant data.'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() => _isInitializing = true);
                        _initializeData().then((_) {
                          if (mounted) setState(() => _isInitializing = false);
                        });
                      },
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              );
            }

            // CASE 5: Has data (possibly with warning error) - show content
            return _buildContent(context, viewModel);
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, HomeViewModel viewModel) {
    return RefreshIndicator(
      onRefresh: () async {
        // Show loading state during refresh
        setState(() => _isInitializing = true);

        try {
          await viewModel.fetchStores(forceRefresh: true);
        } finally {
          if (mounted) setState(() => _isInitializing = false);
        }
      },
      child: CustomScrollView(
        slivers: [
          _buildBody(viewModel),
        ],
      ),
    );
  }


  // Widget _buildAppBar() {
  //   return SliverAppBar(
  //     floating: true,
  //     title: Text(
  //       'Food Court',
  //       style: AppTextStyles.h3,
  //     ),
  //     actions: [
  //       IconButton(
  //         icon: const Icon(Icons.refresh),
  //         onPressed: () => context.read<HomeViewModel>().fetchStores(
  //               forceRefresh: true,
  //             ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildBody(HomeViewModel viewModel) {
    // Filter restaurants based on normalized search query
    final restaurants = viewModel.storeData?.restaurants ?? [];
    final normalizedQuery = normalizeSearchText(_searchQuery);

    final filteredRestaurants = _searchQuery.isEmpty
        ? restaurants
        : restaurants.where((restaurant) {
            // Create both a spaceless and spaced version of the restaurant name
            final normalizedNameNoSpaces = normalizeSearchText(restaurant.name);
            final normalizedNameWithSpaces = restaurant.name
                .toLowerCase()
                .replaceAll('-', ' ')
                .replaceAll('_', ' ')
                .replaceAll(RegExp(r'\s+'), ' ')
                .trim();

            final normalizedDescriptionNoSpaces =
                normalizeSearchText(restaurant.shortDescription ?? '');
            final normalizedDescriptionWithSpaces =
                (restaurant.shortDescription ?? '')
                    .toLowerCase()
                    .replaceAll('-', ' ')
                    .replaceAll('_', ' ')
                    .replaceAll(RegExp(r'\s+'), ' ')
                    .trim();

            // Check both versions against the query
            final queryWithoutSpaces = normalizedQuery;
            final queryWithSpaces = _searchQuery
                .toLowerCase()
                .replaceAll('-', ' ')
                .replaceAll('_', ' ')
                .replaceAll(RegExp(r'\s+'), ' ')
                .trim();

            return normalizedNameNoSpaces.contains(queryWithoutSpaces) ||
                normalizedNameWithSpaces.contains(queryWithSpaces) ||
                normalizedDescriptionNoSpaces.contains(queryWithoutSpaces) ||
                normalizedDescriptionWithSpaces.contains(queryWithSpaces);
          }).toList();

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(),
            const SizedBox(height: 16),
            FoodCourtBanner(
              // name: viewModel.storeData?.name ?? 'Food Court',
              name: currentLocation,

              onTap: () => _handleFoodCourtTap(context),
              onLocationSelect: () async {
                // Open location selection screen
                // In your home screen where you handle the result
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LocationSelectionScreen(),
                  ),
                );

                // Update location if result is not null
                if (result != null && result is Map<String, dynamic>) {  // Change to dynamic instead of String?
                  setState(() {
                    currentLocation = "${result['city']}, ${result['area']}";
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            // const OrderStatusCard(),
            // const SizedBox(height: 16),
            // if (viewModel.storeData?.promotionBanner?.isNotEmpty ?? false) ...[
            //   PromotionBanner(
            //     bannerUrl: viewModel.storeData?.promotionBanner ?? '',
            //     onTap: () => _handlePromotionTap(context),
            //   ),
            //   const SizedBox(height: 8),
            // ],
            // SearchBarSection(
            //   onSearch: (query) => setState(() => _searchQuery = query),
            // ),
            const SizedBox(height: 16),
            Text(
              'Restaurants',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: 8),
            RestaurantList(
              restaurants: filteredRestaurants,
              onRestaurantSelected: (restaurant) =>
                  _handleRestaurantSelection(context, restaurant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Consumer<StoreProvider>(
      builder: (context, storeProvider, child) {
        final userName = storeProvider.userName;
        final displayName = (userName == null || userName.trim().isEmpty)
            ? 'User'
            : userName;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, $displayName',
                  style: AppTextStyles.h3,
                ),
                const SizedBox(height: 4),
                Text(
                  'What would you like to eat?',
                  style: AppTextStyles.h5,
                ),
              ],
            ),
            Row(
              children: [
                const SearchIcon(),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    _navigateToScreen(context, const ProfileScreen());
                  },
                  child: Container(
                    width: 30, // Set the desired width
                    height: 30, // Set the desired height
                    margin: const EdgeInsets.only(right: 12),
                    child: Image.asset(
                      'assets/images/user_avatar.png', // Your image path
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            )
          ],
        );
      },
    );
  }


  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  void _handleFoodCourtTap(BuildContext context) {
    AppLogger.logInfo('${HomeScreen.TAG}:  Food court banner tapped');
    // Handle food court tap
  }

  void _handlePromotionTap(BuildContext context) {
    AppLogger.logInfo('${HomeScreen.TAG}:  Promotion banner tapped');
    // Handle promotion tap
  }

// Handle restaurant selection and navigation
  void _handleRestaurantSelection(
    BuildContext context,
    RestaurantModel restaurant,
  ) {
    AppLogger.logInfo(
        '${HomeScreen.TAG}: Processing restaurant selection: ${restaurant.name}');
    AppLogger.logInfo(
        '${HomeScreen.TAG}: BusinessUnitId: ${restaurant.businessUnit.csBunitId}');

    try {
      // Update StoreProvider with selection
      context.read<StoreProvider>().selectRestaurant(restaurant);

      // Get restaurant status and navigate
      final status =
          context.read<HomeViewModel>().getRestaurantStatus(restaurant);

      // Navigate to product screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductScreen(
            storeId: restaurant.storeId,
            storeImage: restaurant.storeImage,
            restaurantName: restaurant.name,
            isOpen: status['isOpen'] as bool,
            displayTiming: status['displayTiming'] as String,
            shortDescription: restaurant.shortDescription,
            // csBunitId: '',
          ),
        ),
      );

      AppLogger.logInfo(
          '${HomeScreen.TAG}: Successfully navigated to ProductScreen');
    } catch (e) {
      AppLogger.logError(
          '${HomeScreen.TAG}: Error handling restaurant selection: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error selecting restaurant')),
      );
    }
  }
}

