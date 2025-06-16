# Flutter-specific rules
-keep class io.flutter.** { *; }
-dontwarn io.flutter.embedding.**

# Keep classes used by your dependencies
-keep class com.example.defakeit.** { *; }
-keep class org.jetbrains.kotlin.** { *; }

# Keep file_picker classes
-keep class com.mr.flutter.plugin.filepicker.** { *; }
-dontwarn com.mr.flutter.plugin.filepicker.**

# Keep flutter_bloc classes
-keep class com.bloc.** { *; }
-dontwarn com.bloc.**

# Keep path_provider classes
-keep class io.flutter.plugins.pathprovider.** { *; }
-dontwarn io.flutter.plugins.pathprovider.**

# Keep permission_handler classes
-keep class com.baseflow.permissionhandler.** { *; }
-dontwarn com.baseflow.permissionhandler.**