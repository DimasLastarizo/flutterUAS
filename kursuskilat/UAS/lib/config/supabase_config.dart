import 'dart:io';

import 'package:flutter/foundation.dart';

/// URL dan anon key Supabase local.
///
/// Default Android dibuat untuk HP fisik di WiFi yang sama dengan laptop.
/// Kalau nanti pakai Android Emulator, jalankan dengan:
/// `flutter run --dart-define=SUPABASE_USE_ANDROID_EMULATOR=true`
class SupabaseConfig {
  static const anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0';

  static const lanHost = String.fromEnvironment(
    'SUPABASE_LAN_HOST',
    defaultValue: '192.168.10.102',
  );

  static const customUrl = String.fromEnvironment('SUPABASE_URL');
  static const useAndroidEmulator = bool.fromEnvironment(
    'SUPABASE_USE_ANDROID_EMULATOR',
    defaultValue: false,
  );

  static const _port = 54321;

  static String resolveUrl() {
    if (customUrl.isNotEmpty) return customUrl;
    if (kIsWeb) return 'http://127.0.0.1:$_port';

    if (Platform.isAndroid) {
      if (useAndroidEmulator) return 'http://10.0.2.2:$_port';
      return 'http://$lanHost:$_port';
    }

    return 'http://127.0.0.1:$_port';
  }
}
