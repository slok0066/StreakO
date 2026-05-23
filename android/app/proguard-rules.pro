# Keep Flutter engine and plugin classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.provider.** { *; }

# Keep our widget provider and service
-keep class com.streako.streako.StreakOWidgetProvider { *; }
-keep class com.streako.streako.StreakOWidgetService { *; }
-keep class com.streako.streako.StreakOWidgetFactory { *; }
-keep class com.streako.streako.MainActivity { *; }

# Keep Android Support / AndroidX classes
-keep class androidx.lifecycle.** { *; }
-keep class androidx.annotation.** { *; }
-keep class androidx.core.** { *; }

# Ignore warnings from missing Play Store classes referenced by Flutter engine
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.engine.deferredcomponents.**

# Keep flutter_local_notifications classes
-keep class com.dexterous.flutterlocalnotifications.** { *; }
