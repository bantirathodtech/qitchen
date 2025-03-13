import 'package:flutter/material.dart';

import '../../../features/home/search_sproutz/search_overlay_body.dart';
import '../4/search_overlay_header.dart';
import '../7/search_overlay_body.dart';


class SearchOverlayScreen extends StatefulWidget {
  const SearchOverlayScreen({super.key});

  @override
  SearchOverlayScreenState createState() => SearchOverlayScreenState();
}

class SearchOverlayScreenState extends State<SearchOverlayScreen> {
  String searchQuery = '';
  bool showSearchBody = false;

  void onSearchTap() {
    setState(() {
      showSearchBody = true;
    });
  }

  void onSearchQueryChanged(String query) {
    setState(() {
      searchQuery = query;
      showSearchBody = query.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: showSearchBody
                  ? null
                  : const BorderRadius.vertical(
                      bottom: Radius.circular(30),
                    ),
            ),
            child: SearchOverlayHeader(
              onSearchTap: onSearchTap,
              onSearchQueryChanged: onSearchQueryChanged,
            ),
          ),
          if (showSearchBody)
            Expanded(
              child: Container(
                color: Colors.white,
                child: SearchOverlayBody(searchQuery: searchQuery),
              ),
            ),
          if (!showSearchBody) Expanded(child: Container()),
        ],
      ),
    );
  }
}
