# AniLoom release build rules. The app has no reflection, no serialization and
# no network stack, so most rules are conservative.

# Keep Flutter embedding entry points used by MainActivity.
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep AndroidX / Material components referenced from XML.
-keep class androidx.** { *; }
-dontwarn androidx.**

# video_player / media3 (ExoPlayer) is reflectively instantiated in places.
-keep class com.google.android.exoplayer2.** { *; }
-dontwarn com.google.android.exoplayer2.**
-keep class androidx.media3.** { *; }
-dontwarn androidx.media3.**

# url_launcher uses intents only.
-dontwarn org.jetbrains.annotations.**

# Optional Play Core deferred-component APIs referenced by the Flutter engine
# but unused by AniLoom. R8 only needs to be told these are optional.
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
