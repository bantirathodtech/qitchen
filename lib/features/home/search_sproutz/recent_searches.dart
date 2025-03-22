import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecentSearches extends StatefulWidget {
  final Function(String) onSearchSelected;

  const RecentSearches({
    super.key,
    required this.onSearchSelected,
  });

  @override
  State<RecentSearches> createState() => _RecentSearchesState();
}

class _RecentSearchesState extends State<RecentSearches> {
  List<String> _recentSearches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  Future<void> _loadRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _recentSearches = prefs.getStringList('recent_searches') ?? [];
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading recent searches: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _clearRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('recent_searches');
      setState(() {
        _recentSearches = [];
      });
    } catch (e) {
      print('Error clearing recent searches: $e');
    }
  }

  Future<void> _removeSearch(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _recentSearches.remove(query);
      });
      await prefs.setStringList('recent_searches', _recentSearches);
    } catch (e) {
      print('Error removing search: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_recentSearches.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Searches',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_recentSearches.isNotEmpty)
                TextButton(
                  onPressed: _clearRecentSearches,
                  child: const Text(
                    'Clear All',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _recentSearches.length > 5 ? 5 : _recentSearches.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: const Icon(Icons.history, color: Colors.grey),
              title: Text(
                _recentSearches[index],
                style: const TextStyle(fontSize: 16),
              ),
              onTap: () {
                widget.onSearchSelected(_recentSearches[index]);
              },
              trailing: IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () {
                  _removeSearch(_recentSearches[index]);
                },
              ),
            );
          },
        ),
      ],
    );
  }
}