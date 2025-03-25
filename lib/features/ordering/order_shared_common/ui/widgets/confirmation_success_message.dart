import 'package:flutter/material.dart';

import 'confetti_animation_screen.dart';

class ConfirmationSuccessMessage extends StatelessWidget {
  final String orderId;

  const ConfirmationSuccessMessage({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: CardConfetti(
        duration: const Duration(seconds: 5),
        showLeftConfetti: true,
        showRightConfetti: true,
        showTopConfetti: false, // Not using top confetti as per original design
        child: Card(
          elevation: 4,
          margin: EdgeInsets.zero,
          // color: Colors.green[50],
          color: Color.fromRGBO(55, 84, 211, 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  // color: Colors.green,
                  color: Colors.white,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  'Your order_shared_common has been placed',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        // color: Colors.green[800],
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Order ID: $orderId',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        // color: Colors.grey[700],
                        color: Colors.white,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// import 'dart:math';
//
// import 'package:confetti/confetti.dart';
// import 'package:flutter/material.dart';
//
// class ConfirmationSuccessMessage extends StatefulWidget {
//   final String orderId;
//
//   const ConfirmationSuccessMessage({
//     super.key,
//     required this.orderId,
//   });
//
//   @override
//   State<ConfirmationSuccessMessage> createState() =>
//       _ConfirmationSuccessMessageState();
// }
//
// class _ConfirmationSuccessMessageState
//     extends State<ConfirmationSuccessMessage> {
//   late ConfettiController _confettiController;
//   final Random _random = Random();
//
//   @override
//   void initState() {
//     super.initState();
//     _confettiController = ConfettiController(
//       duration: const Duration(seconds: 5),
//     );
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _confettiController.play();
//     });
//   }
//
//   @override
//   void dispose() {
//     _confettiController.dispose();
//     super.dispose();
//   }
//
//   Path drawStar(Size size) {
//     double degToRad(double deg) => deg * (pi / 180.0);
//
//     const numberOfPoints = 5;
//     final halfWidth = size.width / 2;
//     final externalRadius = halfWidth;
//     final internalRadius = halfWidth / 2.5;
//     final degreesPerStep = degToRad(360 / numberOfPoints);
//     final halfDegreesPerStep = degreesPerStep / 2;
//     final path = Path();
//     final fullAngle = degToRad(360);
//     path.moveTo(size.width, halfWidth);
//
//     for (double step = 0; step < fullAngle; step += degreesPerStep) {
//       path.lineTo(halfWidth + externalRadius * cos(step),
//           halfWidth + externalRadius * sin(step));
//       path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep),
//           halfWidth + internalRadius * sin(step + halfDegreesPerStep));
//     }
//     path.close();
//     return path;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: double.infinity, // Ensures the widget takes full width
//       child: Stack(
//         alignment: Alignment.center, // Center aligns the stack contents
//         children: [
//           // Left confetti
//           Align(
//             alignment: Alignment.centerLeft,
//             child: ConfettiWidget(
//               confettiController: _confettiController,
//               blastDirection: -pi / 4,
//               emissionFrequency: 0.3,
//               numberOfParticles: 20,
//               maxBlastForce: 100,
//               minBlastForce: 80,
//               gravity: 0.3,
//               createParticlePath: drawStar,
//               colors: const [
//                 Colors.orange,
//                 Colors.blue,
//                 Colors.pink,
//                 Colors.purple,
//                 Colors.red,
//                 Colors.yellow,
//               ],
//             ),
//           ),
//           // Right confetti
//           Align(
//             alignment: Alignment.centerRight,
//             child: ConfettiWidget(
//               confettiController: _confettiController,
//               blastDirection: -3 * pi / 4,
//               emissionFrequency: 0.3,
//               numberOfParticles: 20,
//               maxBlastForce: 100,
//               minBlastForce: 80,
//               gravity: 0.3,
//               createParticlePath: drawStar,
//               colors: const [
//                 Colors.green,
//                 Colors.cyan,
//                 Colors.teal,
//                 Colors.indigo,
//                 Colors.orange,
//                 Colors.yellow,
//               ],
//             ),
//           ),
//           // Success message card
//           Card(
//             elevation: 4,
//             margin: EdgeInsets.zero, // Removes default card margin
//             color: Colors.green[50],
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Container(
//               // Added Container for full width
//               width: double.infinity,
//               padding:
//                   const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Icon(
//                     Icons.check_circle_outline,
//                     color: Colors.green,
//                     size: 64,
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'Order Confirmed!',
//                     style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                           color: Colors.green[800],
//                           fontWeight: FontWeight.bold,
//                         ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Order ID: ${widget.orderId}',
//                     style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                           color: Colors.grey[700],
//                         ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
