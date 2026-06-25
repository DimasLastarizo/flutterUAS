import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static SupabaseClient get _client => Supabase.instance.client;
  static const _requestTimeout = Duration(seconds: 8);

  static Future<String?> register({
    required String nama,
    required String username,
    required String email,
    required String sandi,
  }) async {
    try {
      final available = await _client
          .rpc('is_username_available', params: {'p_username': username})
          .timeout(_requestTimeout);
      if (available != true) return 'Username sudah digunakan';

      final res = await _client.auth
          .signUp(
            email: email,
            password: sandi,
            data: {'nama': nama, 'username': username},
          )
          .timeout(_requestTimeout);
      if (res.user == null) return 'Registrasi gagal';
      return null;
    } on AuthException catch (e) {
      if (e.message.toLowerCase().contains('already')) {
        return 'Email sudah terdaftar';
      }
      return e.message;
    } catch (e) {
      return 'Registrasi gagal: $e';
    }
  }

  static Future<String?> login({
    required String username,
    required String sandi,
  }) async {
    try {
      final email =
          await _client
                  .rpc(
                    'get_email_for_username',
                    params: {'p_username': username},
                  )
                  .timeout(_requestTimeout)
              as String?;

      if (email == null || email.isEmpty) {
        return 'Username atau sandi salah';
      }

      await _client.auth
          .signInWithPassword(email: email, password: sandi)
          .timeout(_requestTimeout);
      return null;
    } on AuthException {
      return 'Username atau sandi salah';
    } catch (e) {
      return 'Login gagal: $e';
    }
  }

  static Future<void> logout() => _client.auth.signOut();

  static User? get currentUser => _client.auth.currentUser;

  static Session? get currentSession => _client.auth.currentSession;

  /// True jika ada session tersimpan (termasuk setelah app ditutup).
  static Future<bool> hasPersistedSession() async {
    final session = currentSession;
    if (session == null) return false;
    if (!session.isExpired) return currentUser != null;
    try {
      await _client.auth.refreshSession();
    } catch (_) {
      return false;
    }
    return currentUser != null;
  }

  static Future<Map<String, dynamic>?> fetchProfile() async {
    final user = currentUser;
    if (user == null) return null;

    final row = await _client
        .from('profiles')
        .select(
          'username, nama, email, xp, level, streak, total_completed_levels, created_at',
        )
        .eq('id', user.id)
        .maybeSingle();

    return row;
  }

  static DateTime? memberSinceFromProfile(Map<String, dynamic>? profile) {
    final raw = profile?['created_at'];
    if (raw is DateTime) return raw.toLocal();
    if (raw is String) return DateTime.tryParse(raw)?.toLocal();
    final authCreated = currentUser?.createdAt;
    if (authCreated != null) {
      return DateTime.tryParse(authCreated)?.toLocal();
    }
    return null;
  }

  static String formatMemberSince(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return 'Member sejak ${months[date.month - 1]} ${date.year}';
  }
}
