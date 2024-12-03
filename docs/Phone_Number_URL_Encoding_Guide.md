# Phone Number URL Encoding Guide

## Overview

When handling phone numbers in URLs, special consideration is needed for numbers that include
country codes with '+' symbols. This document explains how to properly encode phone numbers for URL
parameters to ensure consistent API functionality.

## Problem Statement

When passing phone numbers to API endpoints, two different formats need to be handled:

1. Numbers with country code (e.g., `+919876543210`)
2. Numbers without country code (e.g., `9876543210`)

The '+' symbol in URLs requires special encoding as it's a reserved character.

## Examples

### Without Encoding

```
Original Number: +919876543210
Resulting URL: https://api.example.com/verify?mobile_number=+919876543210
Issue: '+' is treated as a space in URLs
```

### With Proper Encoding

```
Original Number: +919876543210
Encoded Number: %2B919876543210
Correct URL: https://api.example.com/verify?mobile_number=%2B919876543210
```

### Numbers Without Country Code

```
Original Number: 9876543210
Encoded Number: 9876543210 (no encoding needed)
URL: https://api.example.com/verify?mobile_number=9876543210
```

## Implementation

### Dart/Flutter Solution

```dart
// Properly encode the phone number for URL
final encodedPhoneNumber = Uri.encodeQueryComponent(phoneNumber);

// Use in URL
final String url = '${baseUrl}?mobile_number=$encodedPhoneNumber';
```

### Common Cases

| Input Number   | Encoded Result   | Works With API |
|----------------|------------------|----------------|
| +919876543210  | %2B919876543210  | ✅              |
| 9876543210     | 9876543210       | ✅              |
| +1-234-567-890 | %2B1-234-567-890 | ✅              |

## Best Practices

1. **Always Encode**: Use `Uri.encodeQueryComponent()` for all phone numbers, even those without
   special characters.
   ```dart
   final encodedPhoneNumber = Uri.encodeQueryComponent(phoneNumber);
   ```

2. **Logging**: Include both original and encoded numbers in logs for debugging.
   ```dart
   AppLogger.logDebug('Original number: $phoneNumber');
   AppLogger.logDebug('Encoded number: $encodedPhoneNumber');
   ```

3. **Validation**: Before encoding, validate phone number format:
   ```dart
   // Example validation regex for phone numbers with optional country code
   final bool isValid = RegExp(r'^\+?\d{10,}$').hasMatch(phoneNumber);
   ```

## Common Issues and Solutions

### 1. Double Encoding

**Problem**: Encoding an already encoded number

```dart
// DON'T do this
encodedNumber = Uri.encodeQueryComponent
(
Uri
.
encodeQueryComponent
(
"
+919876543210
"
)
);
```

**Solution**: Encode only once

```dart
// DO this
encodedNumber = Uri.encodeQueryComponent
("+919876543210
"
);
```

### 2. Manual String Replacement

**Problem**: Manually replacing '+' with '%2B'

```dart
// DON'T do this
encodedNumber = phoneNumber.replaceAll
('+
'
,
'
%2B
'
);
```

**Solution**: Use proper URL encoding

```dart
// DO this
encodedNumber = Uri.encodeQueryComponent
(
phoneNumber
);
```

## Testing

Test both formats to ensure proper handling:

```dart
void testPhoneNumberEncoding() {
  final cases = {
    '+919876543210': '%2B919876543210',
    '9876543210': '9876543210',
    '+1-234-567-890': '%2B1-234-567-890'
  };

  for (var entry in cases.entries) {
    final encoded = Uri.encodeQueryComponent(entry.key);
    assert(encoded == entry.value, 'Encoding failed for ${entry.key}');
  }
}
```

## Links to Related Documentation

- [Dart URI Documentation](https://api.dart.dev/stable/dart-core/Uri-class.html)
- [URL Encoding Standards](https://www.w3.org/Addressing/URL/uri-spec.html)

## Remember

- Always use proper URL encoding instead of manual string manipulation
- Test with both phone number formats
- Include proper error handling for invalid phone numbers
- Log both original and encoded values for debugging