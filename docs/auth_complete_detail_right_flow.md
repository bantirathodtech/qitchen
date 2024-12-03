Authentication & Registration Flow Summary:

Initial Launch (SplashScreen)

App starts with a splash screen
Checks if user is already logged in by verifying stored user data
If logged in → Routes to MainScreen
If not logged in → Routes to SignInScreen

Phone Number Verification (SignInScreen)

User enters their phone number
Includes country code selection (default +91)
Validates phone number format (10 digits)
Initiates Firebase phone authentication
When verification code is sent → Routes to OTPScreen

OTP Verification (OTPScreen)

Displays 6-digit OTP input field
Shows entered phone number with edit option
Provides options to:

Resend OTP
Verify via call

After OTP entry:

Verifies OTP with Firebase
If successful → Checks user existence in backend

User Verification Process

Backend check flow:

Verifies if user exists in database
For existing users:

Retrieves user profile data
Routes to MainScreen

For new users:

Creates temporary profile
Routes to SignUpScreen

New User Registration (SignUpScreen)

Collects user details:

First Name
Last Name
Email
Phone Number (pre-filled, non-editable)

On submission:

Generates unique B2C Customer ID
Creates user account in backend
Stores user data locally
Routes to MainScreen

Data Management

Local storage handles:

User profile data
Authentication status
Phone number
Wallet ID
Cart data (if applicable)

Error Handling

Network error management
Invalid OTP handling
Duplicate user checking
Session management
API response validation

Security Features

Firebase phone authentication
Secure local storage
API request validation
Session management
Data encryption

This flow ensures secure user authentication and smooth onboarding while maintaining user session
state and handling both new and returning users appropriately.