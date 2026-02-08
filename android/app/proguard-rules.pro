############################################
# Flutter base rules
############################################

-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.util.** { *; }
-dontwarn io.flutter.embedding.**

############################################
# Google ML Kit – Text Recognition (CRITICAL)
############################################

# Core ML Kit
-keep class com.google.mlkit.common.** { *; }
-dontwarn com.google.mlkit.common.**

# Text recognition base
-keep class com.google.mlkit.vision.text.** { *; }
-dontwarn com.google.mlkit.vision.text.**

# Internal ML Kit classes (required for release)
-keep class com.google.android.gms.internal.mlkit_vision_text_common.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_common.** { *; }
-dontwarn com.google.android.gms.internal.mlkit_vision_text_common.**
-dontwarn com.google.android.gms.internal.mlkit_vision_common.**

############################################
# Language-specific recognizers
# (These caused your R8 error)
############################################

-keep class com.google.mlkit.vision.text.chinese.** { *; }
-keep class com.google.mlkit.vision.text.devanagari.** { *; }
-keep class com.google.mlkit.vision.text.japanese.** { *; }
-keep class com.google.mlkit.vision.text.korean.** { *; }

############################################
# Camera / Image processing safety
############################################

-keep class androidx.camera.** { *; }
-dontwarn androidx.camera.**

############################################
# Google Play Services (safe keep)
############################################

-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

############################################
# General safety rules
############################################

# Keep annotations (needed for some plugins)
-keepattributes *Annotation*

# Keep line numbers for crash reports
-keepattributes SourceFile,LineNumberTable

############################################
# END OF FILE
############################################
