# TensorFlow Lite
-keep class org.tensorflow.lite.** { *; }
-dontwarn org.tensorflow.lite.**

# TensorFlow Lite GPU
-keep class org.tensorflow.lite.gpu.** { *; }
-dontwarn org.tensorflow.lite.gpu.**

# Prevent stripping of delegate options
-keepclassmembers class * {
    @org.tensorflow.lite.support.annotation.* <fields>;
    @org.tensorflow.lite.support.annotation.* <methods>;
}

# Google libraries used by TFLite
-keep class com.google.android.** { *; }
-dontwarn com.google.android.**
