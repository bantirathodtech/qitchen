import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final VoidCallback onSearchTap;
  final ValueChanged<String> onSearchQueryChanged;

  SearchBarWidget({
    super.key,
    required this.onSearchTap,
    required this.onSearchQueryChanged,
  });

  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: onSearchTap,
        child: Container(
          // height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFB),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              // color: Colors.grey.withOpacity(0.2),
              color: Colors.white,
              width: 1,
            ),
          ),
          child: TextField(
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: 'Search...',
              hintStyle: const TextStyle(
                color: Color.fromRGBO(189, 189, 189, 1),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: const Icon(Icons.search,
                  color: Color.fromRGBO(189, 189, 189, 1)),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      // Perform action when close icon is tapped
                    },
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(255, 233, 233, 1),
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Color.fromRGBO(254, 33, 33, 1),
                        size: 16,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Icon(Icons.mic, color: Colors.grey),
                  ),
                ],
              ),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: onSearchQueryChanged,
          ),
        ),
      ),
    );
  }
}
