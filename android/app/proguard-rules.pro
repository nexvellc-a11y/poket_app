# Razorpay ProGuard Rules
-keep class com.razorpay.** { *; }
-keep class proguard.annotation.** { *; }
-keepclassmembers class * {
    @proguard.annotation.Keep *;
    @proguard.annotation.KeepClassMembers *;
}

# Additional Razorpay rules
-keep class com.razorpay.AnalyticsEvent { *; }
-dontwarn com.razorpay.**

# Keep Firebase models
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Keep Gson model classes
-keep class com.example.poketstore.model.** { *; }

# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# General rules
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Application
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider
-keep public class * extends android.view.View

# Google Play Core rules
-keep class com.google.android.play.core.** { *; }
-keep class com.google.android.play.** { *; }
-dontwarn com.google.android.play.**