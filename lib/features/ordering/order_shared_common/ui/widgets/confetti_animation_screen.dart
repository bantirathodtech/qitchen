import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

class CardConfetti extends StatefulWidget {
  final Widget child;
  final bool showLeftConfetti;
  final bool showRightConfetti;
  final bool showTopConfetti;
  final Duration duration;

  const CardConfetti({
    super.key,
    required this.child,
    this.showLeftConfetti = true,
    this.showRightConfetti = true,
    this.showTopConfetti = true,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<CardConfetti> createState() => _CardConfettiState();
}

class _CardConfettiState extends State<CardConfetti> {
  late ConfettiController _controllerLeft;
  late ConfettiController _controllerRight;
  late ConfettiController _controllerTop;

  @override
  void initState() {
    super.initState();
    _controllerLeft = ConfettiController(duration: widget.duration);
    _controllerRight = ConfettiController(duration: widget.duration);
    _controllerTop = ConfettiController(duration: widget.duration);

    // Start confetti after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.showLeftConfetti) _controllerLeft.play();
      if (widget.showRightConfetti) _controllerRight.play();
      if (widget.showTopConfetti) _controllerTop.play();
    });
  }

  @override
  void dispose() {
    _controllerLeft.dispose();
    _controllerRight.dispose();
    _controllerTop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // The actual card/content
        widget.child,

        // Left confetti
        if (widget.showLeftConfetti)
          Align(
            alignment: Alignment.centerLeft,
            child: ConfettiWidget(
              confettiController: _controllerLeft,
              blastDirection: -pi / 4, // Shoots up-right
              emissionFrequency: 0.3,
              numberOfParticles: 10,
              maxBlastForce: 100,
              minBlastForce: 80,
              gravity: 0.3,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
                Colors.yellow,
              ],
            ),
          ),

        // Right confetti
        if (widget.showRightConfetti)
          Align(
            alignment: Alignment.centerRight,
            child: ConfettiWidget(
              confettiController: _controllerRight,
              blastDirection: -3 * pi / 4, // Shoots up-left
              emissionFrequency: 0.3,
              numberOfParticles: 10,
              maxBlastForce: 100,
              minBlastForce: 80,
              gravity: 0.3,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
                Colors.yellow,
              ],
            ),
          ),

        // Top center confetti
        if (widget.showTopConfetti)
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _controllerTop,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.3,
              numberOfParticles: 10,
              maxBlastForce: 100,
              minBlastForce: 80,
              gravity: 0.3,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
                Colors.yellow,
              ],
            ),
          ),
      ],
    );
  }
}
