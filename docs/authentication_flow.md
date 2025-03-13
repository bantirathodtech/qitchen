Authentication Flow
Splash Screen:

Check if the user is already logged in by verifying the login session stored in app preferences.
If logged in: Navigate directly to the Main Screen.
If not logged in: Navigate to the Sign In Screen.
Sign In Screen:

Allow the user to enter their phone number for login.
After entering the number, navigate to the OTP Screen.
OTP Screen:

Verify if the user is registered with the entered phone number.
If registered: Verify the OTP and, upon success, navigate to the Main Screen.
If not registered: Navigate to the Sign Up Screen, passing the entered phone number.
Sign Up Screen:

Pre-fill the phone number field with the one from the Sign In Screen.
Collect additional user details required for registration.
On submission, create an account in:
Firebase (for OTP verification).
Your own server (for user registration and verification).
Completion:

After successful registration on both platforms, navigate the user to the Main Screen.
Key Points:
Ensure to handle errors and edge cases throughout this flow, such as invalid OTPs, network issues
during registration, etc.
Consider providing feedback (like loading indicators or error messages) during transitions between
screens and API calls for better user experience.