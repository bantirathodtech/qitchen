// // File: widgets/status_badge.dart
// import 'package:flutter/material.dart';
//
// import '../../../../../../../common/styles/app_text_styles.dart';
//
// class StatusBadge extends StatelessWidget {
//   final bool isOpen;
//   final String text;
//
//   const StatusBadge({
//     super.key,
//     required this.isOpen,
//     required this.text,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(
//         horizontal: 8,
//         vertical: 4,
//       ),
//       decoration: BoxDecoration(
//         color: isOpen ? Colors.green : Colors.red,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Text(
//         text,
//         style: AppTextStyles.statusTextStyle.copyWith(
//           color: Colors.white,
//         ),
//       ),
//     );
//   }
// }
