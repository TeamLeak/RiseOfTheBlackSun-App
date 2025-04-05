# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.plugin.editing.** { *; }
-keep class io.flutter.embedding.** { *; }

# Permission Handler Plugin
-keep class com.baseflow.permissionhandler.** { *; }

# Error Prone Annotations
-keep class com.google.errorprone.annotations.** { *; }

# JetBrains Annotations
-keep class org.jetbrains.annotations.** { *; }

# JSR-305 Annotations
-keep class javax.annotation.** { *; }

# Keep Google Crypto Tink
-keep class com.google.crypto.tink.** { *; }

# Keep entry points
-keep class * extends io.flutter.embedding.engine.plugins.FlutterPlugin { *; }
-keep class * implements io.flutter.plugin.common.MethodChannel.MethodCallHandler { *; }

# Keep interfaces crucial for Flutter plugins to work
-keep interface io.flutter.plugin.common.** { *; }
