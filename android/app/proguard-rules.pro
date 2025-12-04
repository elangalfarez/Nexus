# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Isar database rules
-keep class dev.isar.** { *; }
-keep class * extends dev.isar.** { *; }

# Keep model classes (adjust package name as needed)
-keep class com.nexus.app.models.** { *; }
-keepclassmembers class com.nexus.app.models.** { *; }

# JSON serialization
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes EnclosingMethod

# Prevent R8 from removing annotations
-keepattributes RuntimeVisibleAnnotations
-keepattributes RuntimeInvisibleAnnotations
-keepattributes RuntimeVisibleParameterAnnotations
-keepattributes RuntimeInvisibleParameterAnnotations

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep Parcelable
-keepclassmembers class * implements android.os.Parcelable {
    static ** CREATOR;
}

# Keep Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Kotlin specific
-dontwarn kotlin.**
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-keepclassmembers class kotlin.Metadata {
    public <methods>;
}

# Coroutines
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}
-keepclassmembernames class kotlinx.** {
    volatile <fields>;
}

# Flutter Local Notifications
-keep class com.dexterous.** { *; }

# Secure Storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# URL Launcher
-keep class io.flutter.plugins.urllauncher.** { *; }

# Share Plus
-keep class dev.fluttercommunity.plus.share.** { *; }

# Connectivity Plus
-keep class dev.fluttercommunity.plus.connectivity.** { *; }

# File Picker
-keep class com.mr.flutter.plugin.filepicker.** { *; }

# Path Provider
-keep class io.flutter.plugins.pathprovider.** { *; }

# Shared Preferences
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# Permission Handler
-keep class com.baseflow.permissionhandler.** { *; }

# Suppress warnings
-dontwarn org.bouncycastle.**
-dontwarn org.conscrypt.**
-dontwarn org.openjsse.**
-dontwarn javax.annotation.**