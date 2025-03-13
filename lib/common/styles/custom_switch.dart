import 'package:flutter/material.dart';

class CustomSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const CustomSwitch({super.key, required this.value, required this.onChanged});

  @override
  CustomSwitchState createState() => CustomSwitchState();
}

class CustomSwitchState extends State<CustomSwitch> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onChanged(!widget.value),
      child: Stack(
        clipBehavior: Clip.none, // Allow content to overflow the bounds
        alignment: widget.value ? Alignment.centerRight : Alignment.centerLeft,
        children: [
          // Background track
          Container(
            width: 36, // Width of the switch track
            height: 16, // Height of the switch track
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: widget.value
                  ? Colors.green.withOpacity(0.3) // Active track color
                  : Colors.grey.withOpacity(0.3), // Inactive track color
            ),
          ),
          // Toggle circle
          Positioned(
            top: -5, // Adjust vertical alignment
            left: widget.value ? null : -5, // Allow overlap on the left
            right: widget.value ? -5 : null, // Allow overlap on the right
            child: Container(
              width: 24, // Width of the toggle circle
              height: 24, // Height of the toggle circle
              // decoration: BoxDecoration(
              //   shape: BoxShape.circle,
              //   color: widget.value ? Colors.green : Colors.grey,
              // ),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white, // Inside of the circle will be white
                border: Border.all(
                  color: widget.value
                      ? Colors.green
                      : Colors.grey, // Green or grey border
                  width: 3, // Border width
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
