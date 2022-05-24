# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# Keep names of all Openreads classes
-keepnames class software.mdev.bookstracker.**.* { *; }
-keepnames interface software.mdev.bookstracker.**.* { *; }

# Keep file names/line numbers
-keepattributes SourceFile,LineNumberTable

# Keep custom exceptions
-keep public class * extends java.lang.Exception

# Keep AndroidX ComponentFactory
-keep class androidx.core.app.CoreComponentFactory { *; }
