import 'package:supabase_flutter/supabase_flutter.dart';

class LevelResult {
  final int levelNumber;
  final int correctCount;
  final int stars;
  final int xpDelta;
  final int totalXp;
  final int userLevel;
  final bool unlockedNext;

  const LevelResult({
    required this.levelNumber,
    required this.correctCount,
    required this.stars,
    required this.xpDelta,
    required this.totalXp,
    required this.userLevel,
    required this.unlockedNext,
  });

  factory LevelResult.fromJson(Map<String, dynamic> json) => LevelResult(
        levelNumber: json['level_number'] as int,
        correctCount: json['correct_count'] as int,
        stars: json['stars'] as int,
        xpDelta: json['xp_delta'] as int,
        totalXp: json['total_xp'] as int,
        userLevel: json['user_level'] as int,
        unlockedNext: json['unlocked_next'] as bool? ?? false,
      );
}

class ProgressService {
  static SupabaseClient get _client => Supabase.instance.client;

  static Future<void> ensureUserProgress() async {
    await _client.rpc('ensure_user_progress');
  }

  static Future<LevelResult?> submitLevelResult({
    required int levelNumber,
    required int correctCount,
  }) async {
    final raw = await _client.rpc(
      'submit_level_result',
      params: {
        'p_level_number': levelNumber,
        'p_correct_count': correctCount,
      },
    );
    if (raw == null) return null;
    return LevelResult.fromJson(Map<String, dynamic>.from(raw as Map));
  }
}
