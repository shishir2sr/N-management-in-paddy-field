# Keep TensorFlow Lite GPU delegate classes
-keep class org.tensorflow.lite.** { *; }
-dontwarn org.tensorflow.lite.**

# Sometimes also needed for TFLite support libraries
-keep class com.google.android.** { *; }
-dontwarn com.google.android.**
