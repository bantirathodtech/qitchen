// File: screens/home/home_screen.dart

import 'package:cw_food_ordering/features/store/model/store_models.dart';
import 'package:cw_food_ordering/features/store/view/widgets/restaurant_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../../../../common/log/loggers.dart';
import '../../../../../../common/styles/app_text_styles.dart';
import '../../../../core/search_overlay/1/search_icon.dart';
import '../../../auth/profile/profile_screen.dart';
import '../../../home/error_display.dart';
import '../../../home/loading_indicator.dart';
import '../../../home/location_selection_screen.dart';
import '../../../home/widgets/restaurant_list.dart';
import '../../../products/view/product_screen.dart';
import '../../../search/search_bar_section.dart';
import '../../provider/store_provider.dart';
import '../../viewmodel/home_viewmodel.dart';
import '../widgets/food_court_banner.dart';
import '../widgets/order_status_card.dart';
import '../widgets/promotion_banner.dart';

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
  String _searchQuery = ''; // Add this to track search query
  String currentLocation = "Chennai, AMB 6";

  @override
  void initState() {
    super.initState();
    AppLogger.logInfo('${HomeScreen.TAG}: Initializing HomeScreen');
    _initializeData();
  }

  // Initialize store data
  Future<void> _initializeData() async {
    try {
      AppLogger.logInfo('${HomeScreen.TAG}: Loading initial store data');
      await context.read<HomeViewModel>().fetchStores();
    } catch (e) {
      AppLogger.logError('${HomeScreen.TAG}: Error loading initial data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<HomeViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const LoadingIndicator();
            }

            if (viewModel.error.isNotEmpty) {
              return ErrorDisplay(
                error: viewModel.error,
                onRetry: _initializeData,
              );
            }

            if (viewModel.storeData == null) {
              return const Center(child: Text('No store data available'));
            }

            return _buildContent(context, viewModel);
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, HomeViewModel viewModel) {
    return RefreshIndicator(
      onRefresh: () => viewModel.fetchStores(forceRefresh: true),
      child: CustomScrollView(
        slivers: [
          // _buildAppBar(),
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

  // Widget _buildWelcomeSection() {
  //   return Consumer<StoreProvider>(
  //     builder: (context, storeProvider, child) {
  //       final userName = storeProvider.userName;
  //       return Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               if (userName != null) ...[
  //                 Text(
  //                   'Hello, $userName',
  //                   style: AppTextStyles.h2,
  //                 ),
  //                 const SizedBox(height: 4),
  //               ],
  //               Text(
  //                 'What would you like to eat?',
  //                 style: AppTextStyles.h4,
  //               ),
  //             ],
  //           ),
  //           Row(
  //             children: [
  //               const SearchIcon(),
  //               const SizedBox(width: 8),
  //               GestureDetector(
  //                 onTap: () {
  //                   _navigateToScreen(context, const ProfileScreen());
  //                 },
  //
  //                 child: Container(
  //                   width: 30, // Set the desired width
  //                   height: 30, // Set the desired height
  //                   margin: const EdgeInsets.only(
  //                       right: 12), // Optional: Add margin if needed
  //                   // child: Image.asset('assets/images/ic_user.png', // Your image path
  //                   child: Image.asset(
  //                     'assets/images/user_avatar.png', // Your image path
  //
  //                     fit: BoxFit
  //                         .cover, // This ensures the image fills the container
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           )
  //         ],
  //       );
  //     },
  //   );
  // }

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
            csBunitId: '',
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

