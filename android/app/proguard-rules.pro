# ProGuard / R8 keep rules para Finanzapp release.
# Se mergean con las reglas default de Android + las consumer-rules.pro
# que cada plugin Flutter trae embebidas.
#
# Guía: cada bloque dice qué plugin lo necesita y por qué. Si crashea
# en release con NoSuchMethodError o ClassNotFoundException, mirar acá
# antes de tocar nada más.

# === Flutter framework ===
# El engine de Flutter accede a estas clases por JNI. Default rules
# cubren la mayoría, pero por las dudas reforzamos.
-keep class io.flutter.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# === Atributos que ProGuard pierde por default y que rompen
# serialización JSON, reflection y stacktraces legibles. ===
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes EnclosingMethod
-keepattributes InnerClasses
-keepattributes SourceFile,LineNumberTable

# === Kotlin metadata ===
-dontwarn kotlin.**
-dontwarn kotlinx.**
-keep class kotlin.Metadata { *; }

# === flutter_local_notifications ===
# El plugin instancia sus receivers por reflection (BroadcastReceiver
# para alarms scheduleadas + notificaciones que sobreviven reboot).
-keep class com.dexterous.** { *; }
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# === supabase_flutter / gotrue / postgrest / realtime ===
# Supabase usa Dio + WebSocket. Las clases JSON de gotrue se
# (de)serializan via reflection en algunos paths internos. Mantener
# sus modelos.
-keep class io.supabase.** { *; }
-keep class com.supabase.** { *; }
-dontwarn io.supabase.**

# === google_sign_in ===
# Play Services + Google Auth — el bytecode usa reflection para
# encontrar receivers/listeners de OAuth.
-keep class com.google.android.gms.** { *; }
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.api.client.** { *; }
-dontwarn com.google.android.gms.**

# === local_auth (biometric) ===
-keep class androidx.biometric.** { *; }
-keep class androidx.fragment.app.FragmentActivity { *; }

# === Lockfree / RxJava / OkHttp (deps transitivas de Supabase) ===
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**

# === Core library desugaring ===
# Necesario porque tenemos isCoreLibraryDesugaringEnabled = true.
-keep class j$.time.** { *; }
-dontwarn j$.**
