# uCrop ProGuard rules
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn com.yalantis.ucrop.**
-keep class com.yalantis.ucrop.** { *; }
-keep interface com.yalantis.ucrop.** { *; }

# JNA ProGuard rules
-dontwarn com.sun.jna.**
-keep class com.sun.jna.** { *; }
-keepclassmembers class * extends com.sun.jna.** {
    public *;
}

# Vosk ProGuard rules
-dontwarn org.vosk.**
-keep class org.vosk.** { *; }
-keep interface org.vosk.** { *; }
