class SupabaseConfig {
  static const String url = 'https://iyuhohfbfhjuiyyrmasj.supabase.co';

  static const String anonKey =
      'sb_publishable_ZoufhqjvaXHgTHtdFs9_Kw_BS91NgIi';

  static const String authCallbackUrl = 'finanzapp://login-callback';

  // Google OAuth Client IDs (Google Cloud Console).
  // iOS Client: registrado para Bundle ID `app.finanzapp.client`.
  // El viejo (`...3te66anat...`) era para `com.xavier.finanzapp` y
  // quedó obsoleto al cambiar el Bundle ID.
  static const String googleIosClientId =
      '637631327229-g7bs1r8b0ujopn548e0643oova4st9sd.apps.googleusercontent.com';
  // Android Client ID: NO se usa en código (Android lo descubre via
  // package + SHA-1). El de `com.xavier.finanzapp` está obsoleto;
  // hay que crear uno nuevo para `app.finanzapp.client` cuando se
  // habilite Google Sign-In en Android release.
  static const String googleAndroidClientId =
      '637631327229-s4l6aih6bjk7bt7i1ali1q6giu678hbc.apps.googleusercontent.com';
  // Web Client ID (usado como `serverClientId` para validar el ID
  // token en Supabase). Independiente del Bundle ID, no cambia.
  static const String googleWebClientId =
      '637631327229-f59f293cjjst6l9sltvleundgugi5983.apps.googleusercontent.com';
}
