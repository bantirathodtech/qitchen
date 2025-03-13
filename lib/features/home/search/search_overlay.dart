// import 'package:flutter/material.dart';
//
// class SearchOverlay extends StatefulWidget {
//   const SearchOverlay({super.key});
//
//   @override
//   State<SearchOverlay> createState() => _SearchOverlayState();
// }
//
// class _SearchOverlayState extends State<SearchOverlay>
//     with SingleTickerProviderStateMixin {
//   final TextEditingController _searchController = TextEditingController();
//   final FocusNode _searchFocus = FocusNode();
//   bool _isExpanded = false;
//   late AnimationController _animationController;
//   late Animation<double> _heightFactorAnimation;
//
//   List<Map<String, dynamic>> recentSearches = [
//     {'label': 'Seafood', 'isActive': true},
//     {'label': 'Meat, fish', 'isActive': false},
//     {'label': 'Vegetable', 'isActive': false},
//     {'label': 'Fruit imported', 'isActive': false},
//     {'label': 'Pizza', 'isActive': false},
//     {'label': 'Burgers', 'isActive': false},
//     {'label': 'Bread', 'isActive': false},
//     {'label': 'Drinks', 'isActive': false},
//     {'label': 'Diet Food', 'isActive': false},
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );
//     _heightFactorAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
//     );
//   }
//
//   @override
//   void dispose() {
//     _searchController.dispose();
//     _searchFocus.dispose();
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   void _expandSearch() {
//     setState(() {
//       _isExpanded = true;
//     });
//     _animationController.forward();
//     _searchFocus.requestFocus();
//   }
//
//   void _collapseSearch() {
//     _searchFocus.unfocus();
//     _animationController.reverse().then((_) {
//       setState(() {
//         _isExpanded = false;
//       });
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _animationController,
//       builder: (context, child) {
//         // Calculate heights
//         final statusBarHeight = MediaQuery.of(context).padding.top;
//         final searchBarHeight = 100.0; // Height of search bar
//         final headerPadding = 16.0; // Vertical padding around header
//         final totalInitialHeight =
//             statusBarHeight + searchBarHeight + headerPadding + 8.0;
//
//         return Container(
//           height: _isExpanded
//               ? MediaQuery.of(context).size.height
//               : totalInitialHeight,
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.vertical(
//               bottom: Radius.circular(30),
//             ),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               _buildHeader(),
//               _buildSearchBar(),
//               if (_isExpanded)
//                 Expanded(
//                   child: SingleChildScrollView(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         _buildRecentSearches(),
//                         if (_searchController.text.isNotEmpty)
//                           _buildSearchResults(),
//                       ],
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildHeader() {
//     if (!_isExpanded) {
//       return Container(
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.only(
//             bottomLeft: Radius.circular(12),
//             bottomRight: Radius.circular(12),
//           ),
//         ),
//         child: Column(
//           children: [
//             // Status bar color
//             Container(
//               color: Colors.white,
//               height: MediaQuery.of(context).padding.top,
//             ),
//             // Main content with padding
//             Padding(
//               padding: const EdgeInsets.only(
//                 left: 16,
//                 right: 16,
//                 bottom: 8,
//                 top: 8,
//               ),
//               child: Row(
//                 children: [
//                   GestureDetector(
//                     onTap: () => Navigator.pop(context),
//                     child: const Icon(Icons.arrow_back, color: Colors.black),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: const [
//                             Icon(
//                               Icons.location_on_rounded,
//                               color: Colors.green,
//                               size: 16,
//                             ),
//                             SizedBox(width: 4),
//                             Text(
//                               'Hyderabad,',
//                               style: TextStyle(
//                                 color: Colors.black,
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w700,
//                               ),
//                             ),
//                             SizedBox(width: 4),
//                             Text(
//                               'Prathab',
//                               style: TextStyle(
//                                 color: Colors.black,
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w400,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const Padding(
//                           padding: EdgeInsets.only(left: 20.0),
//                           child: Text(
//                             "Simply Dummy Text Of The Prin...",
//                             style: TextStyle(
//                               color: Colors.grey,
//                               fontSize: 10,
//                               fontWeight: FontWeight.w400,
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Container(
//                     width: 40,
//                     height: 40,
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFE8F5EC),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: const Icon(
//                       Icons.notifications_outlined,
//                       color: Colors.green,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 8),
//           ],
//         ),
//       );
//     }
//
//     // When expanded
//     return Container(
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.only(
//           bottomLeft: Radius.circular(12),
//           bottomRight: Radius.circular(12),
//         ),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // Status bar color
//           Container(
//             color: Colors.white,
//             height: MediaQuery.of(context).padding.top,
//           ),
//           // Main content
//           Padding(
//             padding:
//                 const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//             child: Row(
//               children: [
//                 GestureDetector(
//                   onTap: () => Navigator.pop(context),
//                   child: const Icon(Icons.arrow_back, color: Colors.black),
//                 ),
//                 const SizedBox(width: 12),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: const [
//                         Icon(
//                           Icons.location_on_rounded,
//                           color: Colors.green,
//                           size: 16,
//                         ),
//                         SizedBox(width: 4),
//                         Text(
//                           'Hyderabad,',
//                           style: TextStyle(
//                             color: Colors.black,
//                             fontSize: 14,
//                             fontWeight: FontWeight.w700,
//                           ),
//                         ),
//                         SizedBox(width: 4),
//                         Text(
//                           'Prathab',
//                           style: TextStyle(
//                             color: Colors.black,
//                             fontSize: 14,
//                             fontWeight: FontWeight.w400,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const Padding(
//                       padding: EdgeInsets.only(left: 20.0),
//                       child: Text(
//                         "Simply Dummy Text Of The Prin...",
//                         style: TextStyle(
//                           color: Colors.grey,
//                           fontSize: 10,
//                           fontWeight: FontWeight.w400,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const Spacer(),
//                 Container(
//                   width: 40,
//                   height: 40,
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFE8F5EC),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: const Icon(
//                     Icons.notifications_outlined,
//                     color: Colors.green,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSearchBar() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         // borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             offset: const Offset(0, 2),
//             blurRadius: 4,
//           ),
//         ],
//       ),
//       child: GestureDetector(
//         onTap: _isExpanded ? null : _expandSearch,
//         child: Container(
//           height: 48,
//           decoration: BoxDecoration(
//             color: const Color(0xFFF8FAFB),
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(
//               color: Colors.grey.withOpacity(0.2),
//               width: 1,
//             ),
//           ),
//           child: TextField(
//             controller: _searchController,
//             focusNode: _searchFocus,
//             enabled: _isExpanded,
//             decoration: InputDecoration(
//               hintText: 'Search...',
//               hintStyle: const TextStyle(
//                 color: Color(0xFF8A8D9F),
//                 fontSize: 16,
//               ),
//               prefixIcon: const Icon(Icons.search, color: Colors.grey),
//               suffixIcon: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   if (_searchController.text.isNotEmpty && _isExpanded)
//                     GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           _searchController.clear();
//                         });
//                       },
//                       child: Container(
//                         margin: const EdgeInsets.all(8),
//                         padding: const EdgeInsets.all(4),
//                         decoration: const BoxDecoration(
//                           color: Color(0xFFFFE8E8),
//                           shape: BoxShape.circle,
//                         ),
//                         child: const Icon(
//                           Icons.close,
//                           color: Color(0xFFFF0000),
//                           size: 16,
//                         ),
//                       ),
//                     ),
//                   const Padding(
//                     padding: EdgeInsets.only(right: 8.0),
//                     child: Icon(Icons.mic, color: Colors.grey),
//                   ),
//                 ],
//               ),
//               border: InputBorder.none,
//               contentPadding: const EdgeInsets.symmetric(horizontal: 16),
//             ),
//             onChanged: (value) {
//               setState(() {});
//             },
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildRecentSearches() {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Recent Search',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: Color(0xFF413D32),
//             ),
//           ),
//           const SizedBox(height: 16),
//           Wrap(
//             spacing: 8,
//             runSpacing: 12,
//             children: recentSearches.map((search) {
//               return GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     for (var item in recentSearches) {
//                       item['isActive'] = item['label'] == search['label'];
//                     }
//                     _searchController.text = search['label'];
//                   });
//                 },
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: search['isActive']
//                         ? const Color(0xFF4FA56F)
//                         : Colors.white,
//                     border: Border.all(
//                       color: search['isActive']
//                           ? Colors.transparent
//                           : const Color(0xFF8A8D9F),
//                       width: 1,
//                     ),
//                     borderRadius: BorderRadius.circular(24),
//                   ),
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 8,
//                   ),
//                   child: Text(
//                     search['label'],
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: search['isActive']
//                           ? Colors.white
//                           : const Color(0xFF413D32),
//                     ),
//                   ),
//                 ),
//               );
//             }).toList(),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSearchResults() {
//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: 3,
//       itemBuilder: (context, index) {
//         return ListTile(
//           leading: const Icon(Icons.search, color: Colors.grey),
//           title: Text(
//             'Suggest ${index + 1}',
//             style: const TextStyle(fontSize: 16),
//           ),
//           onTap: () {
//             Navigator.pop(context);
//           },
//         );
//       },
//     );
//   }
// }
