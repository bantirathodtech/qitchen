import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../2/search_overlay_dialog.dart';

class SearchIcon extends StatelessWidget {
  const SearchIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showSearchOverlayDialog(context);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SvgPicture.asset(
          'assets/icons/ic_search.svg',
        ),
      ),
    );
  }
}
