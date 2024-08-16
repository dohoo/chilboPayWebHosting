# Flutter 기본 설정
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.embedding.android.** { *; }
-keep class io.flutter.embedding.engine.** { *; }
-keep class io.flutter.embedding.engine.dart.** { *; }
-keep class io.flutter.embedding.engine.plugins.** { *; }
-keep class io.flutter.embedding.engine.plugins.shim.** { *; }
-keep class io.flutter.embedding.engine.systemchannels.** { *; }

# HTTP 통신을 위한 설정
-keep class okhttp3.** { *; }
-keep class okio.** { *; }
