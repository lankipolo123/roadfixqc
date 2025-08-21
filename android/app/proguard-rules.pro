# Preserve TensorFlow Lite and Ultralytics classes
-keep class org.tensorflow.** { *; }
-keep class com.ultralytics.** { *; }

# Avoid warnings during build
-dontwarn org.tensorflow.**
-dontwarn com.ultralytics.**

# Optional: Keep Flutter plugin registrant
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**
