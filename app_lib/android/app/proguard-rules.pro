# android/app/proguard-rules.pro

# Flutter/AndroidX keep rules cơ bản
-keep class io.flutter.** { *; }
-keep class androidx.** { *; }
-keep class com.google.** { *; }

# Giữ lớp model/JSON nếu cần (tùy dự án)
# -keepclassmembers class ** {
#   @com.google.gson.annotations.SerializedName <fields>;
# }

# Giữ entry points
-keep class **.MainActivity { *; }
