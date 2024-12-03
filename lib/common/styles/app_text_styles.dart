import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

// Global Text Style Parameters
const String _fontFamily = 'Inter';
const Color _defaultTextColor = Colors.black;
const Color _secondaryTextColor = Colors.grey;
const double _defaultFontSize = 16;
const FontWeight _defaultFontWeight = FontWeight.normal;
const Color _errorTextColor = Colors.red;
const Color _linkTextColor = Colors.blue;
const Color _smallTextColor = Colors.black54;

// Text Style Definitions
class AppTextStyles {
  // Reusable base style
  static TextStyle baseStyle({
    double fontSize = _defaultFontSize,
    FontWeight fontWeight = _defaultFontWeight,
    Color color = _defaultTextColor,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontFamily: _fontFamily,
    );
  }

  // 1. Style for main headings
  static final TextStyle heading = baseStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );

  // 2. Style for subheadings
  static final TextStyle subheading = baseStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle h1 = TextStyle(
    fontSize: 24, // H1 size for app
    fontWeight: FontWeight.bold,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 20, // H2 size for app
    fontWeight: FontWeight.bold,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 18, // H3 size for app
    fontWeight: FontWeight.bold,
  );

  static const TextStyle h4 = TextStyle(
    fontSize: 16, // H4 size for app
    fontWeight: FontWeight.w500,
  );

  static const TextStyle h5 = TextStyle(
    fontSize: 14, // H5 size for app
    fontWeight: FontWeight.w500,
  );
  static const TextStyle h5b = TextStyle(
    fontSize: 14, // H5 size for app
    fontWeight: FontWeight.bold,
  );

  static const TextStyle h6 = TextStyle(
    fontSize: 12, // H6 size for app
    fontWeight: FontWeight.w400,
  );

  //Used for Restaurant card open/closed
  static const TextStyle statusTextStyle = TextStyle(
    color: Colors.black,
    fontFamily: 'Inter',
    fontWeight: FontWeight.bold,
    fontSize: 12,
  );

  // 3. Style for bold input text
  static final TextStyle inputTextBold = baseStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  // 4. Style for input text
  static final TextStyle inputText = baseStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  // 5. Style for button text
  static final TextStyle buttonText = baseStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.white, // Override color for buttons
  );

  // 6. Style for labels
  static final TextStyle labelText = baseStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  // 7. Style for captions
  static final TextStyle captionText = baseStyle(
    fontSize: 12,
    color: _secondaryTextColor,
  );

  // 8. Style for body text
  static final TextStyle bodyText = baseStyle(
    fontSize: 14,
  );

  // 9. Style for error messages
  static final TextStyle errorText = baseStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: _errorTextColor,
  );

  // 10. Style for links
  static final TextStyle linkText = baseStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: _linkTextColor,
  );

  // 11. Style for small text
  static final TextStyle smallText = baseStyle(
    fontSize: 12,
    fontWeight: FontWeight.w300,
    color: _smallTextColor,
  );

  // 12. Style for menu options
  static final TextStyle menuOptionStyle = baseStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  // 13. Style for title text
  static final TextStyle titleText = baseStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
  );

  // 14. Style for subtitle text
  static final TextStyle subtitleText = baseStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  // 15. Style for hint text
  static final TextStyle hintText = baseStyle(
    fontSize: 14,
    color: _secondaryTextColor,
  );

  // 16. Style for alert text
  static final TextStyle alertText = baseStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.orange,
  );

  // 17. Style for navigation bar text
  static final TextStyle navigationBarText = baseStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  // 18. Style for dialog titles
  static final TextStyle dialogTitle = baseStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  // 19. Style for dialog content text
  static final TextStyle dialogContentText = baseStyle(
    fontSize: 16,
  );

  // 20. Style for badge text
  static final TextStyle badgeText = baseStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  // 21. Style for chip text
  static final TextStyle chipText = baseStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  // 22. Style for AppBar title
  static final TextStyle appBarTitle = baseStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  // 23. Style for form labels
  static final TextStyle formLabel = baseStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  // 24. Style for tooltip text
  static final TextStyle tooltipText = baseStyle(
    fontSize: 12,
    color: Colors.white,
  );

  // 25. Style for stepper text
  static final TextStyle stepText = baseStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  // 26. Style for card titles
  static final TextStyle cardTitle = baseStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );

  // 27. Style for card subtitles
  static final TextStyle cardSubtitle = baseStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  // 28. Style for tab titles
  static final TextStyle tabTitleText = baseStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  // 29. Style for snackBar text
  static final TextStyle snackBarText = baseStyle(
    fontSize: 14,
    color: Colors.white,
  );

  // 30. Style for drawer menu text
  static final TextStyle drawerMenuText = baseStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  // 31. Style for
  static final TextStyle body2 = TextStyle(
    fontSize: 14,
    color: Colors.black87,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w400,
  );
  // 32. Style for
  static final TextStyle caption = TextStyle(
    fontSize: 12,
    color: Colors.grey[600],
    fontFamily: 'Inter',
    fontWeight: FontWeight.w400,
  );
}

// Input Border Style
OutlineInputBorder editBorderRadius(
    String colorCode, double radius, double width) {
  return OutlineInputBorder(
    borderSide: BorderSide(color: HexColor(colorCode), width: width),
    borderRadius: BorderRadius.all(Radius.circular(radius)),
  );
}
