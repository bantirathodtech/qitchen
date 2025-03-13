import 'package:flutter/material.dart';

import '../5/search_bar.dart';
import '../6/header_content.dart';

class SearchOverlayHeader extends StatelessWidget {
  final VoidCallback onSearchTap;
  final ValueChanged<String> onSearchQueryChanged;

  const SearchOverlayHeader({
    super.key,
    required this.onSearchTap,
    required this.onSearchQueryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              title: const HeaderContent(),
            ),
            SearchBarWidget(
              onSearchTap: onSearchTap,
              onSearchQueryChanged: onSearchQueryChanged,
            ),
          ],
        ),
      ),
    );
  }
}
