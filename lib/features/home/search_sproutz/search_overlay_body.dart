import 'package:cw_food_ordering/features/home/search_sproutz/recent_searches.dart';
import 'package:cw_food_ordering/features/home/search_sproutz/search_results_sproutz.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/search_overlay/3/search_overlay_screen.dart';
import '../../../core/search_overlay/8/recent_searches.dart';

class SearchOverlayBody extends StatefulWidget {
  final String searchQuery;

  const SearchOverlayBody({super.key, required this.searchQuery});

  @override
  State<SearchOverlayBody> createState() => _SearchOverlayBodyState();
}

class _SearchOverlayBodyState extends State<SearchOverlayBody> {
  @override
  void didUpdateWidget(SearchOverlayBody oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If the search query has changed and is not empty, save it to recent searches
    if (widget.searchQuery != oldWidget.searchQuery &&
        widget.searchQuery.isNotEmpty) {
      _saveToRecentSearches(widget.searchQuery);
    }

  }

  Future<void> _saveToRecentSearches(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> recentSearches = prefs.getStringList('recent_searches') ?? [];

      // Remove if already exists to avoid duplicates
      recentSearches.remove(query);

      // Add to the beginning of the list
      recentSearches.insert(0, query);

      // Keep only the 10 most recent searches
      if (recentSearches.length > 10) {
        recentSearches = recentSearches.sublist(0, 10);
      }

      await prefs.setStringList('recent_searches', recentSearches);
    } catch (e) {
      print('Error saving recent search: $e');
    }
  }

  void _handleRecentSearchSelected(String query) {
    // Find the SearchOverlayScreen ancestor and update its search query
    final searchOverlayState = context.findAncestorStateOfType<State<SearchOverlayScreen>>();
    if (searchOverlayState != null) {
      // Access the onSearchQueryChanged method dynamically
      final dynamicState = searchOverlayState as dynamic;
      if (dynamicState.onSearchQueryChanged != null) {
        dynamicState.onSearchQueryChanged(query);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Show recent searches only when there's no active search
          if (widget.searchQuery.isEmpty)
            RecentSearches(
              onSearchSelected: _handleRecentSearchSelected,
            ),

          // Always show search results when there's a query
          if (widget.searchQuery.isNotEmpty)
            SearchResults(searchQuery: widget.searchQuery),
        ],
      ),
    );
  }
}