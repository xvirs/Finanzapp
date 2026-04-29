import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'app.dart';
import 'config/supabase_config.dart';
import 'core/biometric_service.dart';
import 'core/secure_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await initializeDateFormatting('es_AR');

  // Timezone: necesario para schedulear notificaciones a una hora local
  // específica. tzdata trae todas las zonas; flutter_timezone nos dice
  // cuál es la del dispositivo.
  tzdata.initializeTimeZones();
  try {
    final localTz = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTz));
  } catch (_) {
    // Fallback a UTC si el SO no devuelve la zona.
    tz.setLocalLocation(tz.UTC);
  }

  // Plugin de notificaciones locales — init temprano. El servicio que
  // las orquesta se construye en app.dart.
  final notifications = FlutterLocalNotificationsPlugin();
  await notifications.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    ),
  );

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
    // Override del storage default (SharedPreferences en plaintext)
    // por flutter_secure_storage:
    //   - iOS: Keychain.
    //   - Android: EncryptedSharedPreferences.
    // Importa: con esto, users que vienen de versiones previas
    // (que usaban SharedPreferences) van a quedar deslogueados al
    // actualizar — la primera vez tienen que re-autenticar. Como es
    // la primera release, no hay base instalada; aceptable.
    authOptions: FlutterAuthClientOptions(
      localStorage: SecureLocalStorage(),
      pkceAsyncStorage: SecureGotrueAsyncStorage(),
    ),
  );

  // Refresh el cache del flag biométrico antes de runApp para que el
  // AppLockGate pueda decidir sincronicamente si bloquear.
  final biometricService = BiometricService();
  await biometricService.refreshEnabledCache();

  runApp(FinanzappApp(
    notifications: notifications,
    biometricService: biometricService,
  ));
}
