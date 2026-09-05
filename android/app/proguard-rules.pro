# Flutter engine and embedding
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.**

# TensorFlow Lite. The interpreters are created over FFI from Dart
# (Interpreter.fromFile), but the Java/JNI classes still have to survive R8 or
# libtensorflowlite_jni.so cannot be loaded.
-keep class org.tensorflow.lite.** { *; }
-dontwarn org.tensorflow.lite.**

# TensorFlow Lite GPU (present in the AAR even though no GPU delegate is used)
-keep class org.tensorflow.lite.gpu.** { *; }
-dontwarn org.tensorflow.lite.gpu.**

# Prevent stripping of delegate options
-keepclassmembers class * {
    @org.tensorflow.lite.support.annotation.* <fields>;
    @org.tensorflow.lite.support.annotation.* <methods>;
}

# FlatBuffers — the .tflite model format
-keep class com.google.flatbuffers.** { *; }
-dontwarn com.google.flatbuffers.**

# Google libraries used by TFLite
-keep class com.google.android.** { *; }
-dontwarn com.google.android.**

# Guava references j2objc annotations (iOS-only, optional annotation lib) —
# safe to ignore, never invoked at runtime on Android
-dontwarn com.google.j2objc.annotations.**

# Plugins with reflective or JNI entry points
-keep class androidx.camera.** { *; }
-dontwarn androidx.camera.**
-keep class io.flutter.plugins.camerax.** { *; }
-keep class io.flutter.plugins.imagepicker.** { *; }
-keep class com.baseflow.permissionhandler.** { *; }
-keep class dev.fluttercommunity.plus.device_info.** { *; }
-keep class io.flutter.plugins.pathprovider.** { *; }
-keep class io.flutter.plugins.sharedpreferences.** { *; }
-keep class com.dexterous.** { *; }
-dontwarn com.dexterous.**

# flutter_local_notifications serialises its scheduled notifications with Gson
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**
