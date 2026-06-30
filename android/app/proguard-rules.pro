# Proguard rules for Echo Vision
# ===================================================

# TensorFlow Lite — keep inference API
-keep class org.tensorflow.lite.** { *; }
-dontwarn org.tensorflow.lite.**

# Google ML Kit
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**

# Flutter
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# Telephony plugin
-keep class com.shounakmulay.telephony.** { *; }

# Keep data model classes for JSON serialisation
-keep class com.echovision.app.** { *; }

# Suppress warnings for unused classes in release
-dontwarn com.google.android.gms.**
