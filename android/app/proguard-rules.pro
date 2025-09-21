# Flutter engine and plugin APIs
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.plugin.common.** { *; }

# Core plugins you use
-keep class com.dexterous.** { *; }                      # flutter_local_notifications
-keep class com.baseflow.permissionhandler.** { *; }     # permission_handler
-keep class io.flutter.plugins.sharedpreferences.** { *; }# shared_preferences
-keep class io.flutter.plugins.imagepicker.** { *; }     # image_picker
-keep class io.flutter.plugins.camera.** { *; }          # camera

# TensorFlow Lite (yours) + Support/Task + FlatBuffers
-keep class org.tensorflow.lite.** { *; }
-dontwarn org.tensorflow.lite.**
-keep class org.tensorflow.lite.gpu.** { *; }
-dontwarn org.tensorflow.lite.gpu.**
-keep class org.tensorflow.lite.support.** { *; }
-keep class org.tensorflow.lite.task.** { *; }
-dontwarn org.tensorflow.lite.support.**
-dontwarn org.tensorflow.lite.task.**
-keep class com.google.flatbuffers.** { *; }
-dontwarn com.google.flatbuffers.**

# Prevent stripping of delegate options (already present)
-keepclassmembers class * {
    @org.tensorflow.lite.support.annotation.* <fields>;
    @org.tensorflow.lite.support.annotation.* <methods>;
}

# Google libs used by TFLite (already present)
-keep class com.google.android.** { *; }
-dontwarn com.google.android.**
