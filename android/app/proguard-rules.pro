# Step 1: Preserve annotations for reflection (used by libraries like Razorpay)
-keepattributes *Annotation*

# Step 2: Suppress warnings for Razorpay classes
# Why: Prevents ProGuard from warning about unresolved references
-dontwarn com.razorpay.**

# Step 3: Keep all Razorpay classes and their members
# Why: Ensures Razorpay payment functionality isn’t stripped out
-keep class com.razorpay.** {*;}

# Step 4: Disable method inlining optimizations
# Why: Prevents issues with Razorpay’s payment flow
-optimizations !method/inlining/

# Step 5: Keep payment callback methods
# Why: Ensures your app can handle payment responses from Razorpay
-keepclasseswithmembers class * {
    public void onPayment*(...);
}