import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/level_data.dart';
import '../screens/quiz_page.dart';
import '../screens/materi_page.dart';
import '../screens/leaderboard_page.dart';

class ContentService {
  static SupabaseClient get _client => Supabase.instance.client;

  /// Reset season bulanan jika bulan berganti (no-op jika masih season yang sama).
  static Future<void> ensureSeasonCurrent() async {
    try {
      await _client.rpc('reset_season_if_needed');
    } catch (_) {}
  }

  static Future<List<LevelData>> fetchLevels({String? userId}) async {
    if (userId != null) {
      await ensureSeasonCurrent();
      try {
        await _client.rpc('ensure_user_progress');
      } catch (_) {}
    }

    final rows = await _client
        .from('game_levels')
        .select('*, materials!inner(course_id)')
        .eq('is_published', true)
        .order('level_number');

    Map<int, Map<String, dynamic>> progress = {};
    if (userId != null) {
      final prog = await _client
          .from('user_level_progress')
          .select('level_number, status, stars')
          .eq('user_id', userId);
      for (final p in prog as List) {
        progress[p['level_number'] as int] = p as Map<String, dynamic>;
      }
    }

    final result = <LevelData>[];
    for (final row in rows as List) {
      final levelNum = row['level_number'] as int;
      final progRow = progress[levelNum];
      String statusRaw;
      if (progRow != null) {
        statusRaw = progRow['status'] as String;
      } else if (userId != null) {
        statusRaw = levelNum == 1 ? 'aktif' : 'terkunci';
      } else {
        statusRaw = row['default_status'] as String;
      }

      result.add(
        LevelData(
          id: levelNum,
          title: row['title'] as String,
          topic: row['topic'] as String,
          status: _parseStatus(statusRaw),
          questions: row['questions_count'] as int? ?? 10,
          stars: progRow?['stars'] as int? ?? row['default_stars'] as int,
          moduleIndex:
              row['topic_category_index'] as int? ??
              row['module_index'] as int? ??
              0,
          courseIndex: row['course_index'] as int? ?? 0,
          materialIndex: row['material_index'] as int? ?? 0,
          courseId:
              (row['materials'] as Map<String, dynamic>?)?['course_id'] as int?,
          materialId: row['material_id'] as int?,
        ),
      );
    }
    result.sort((a, b) => a.id.compareTo(b.id));
    return result;
  }

  static Future<Map<int, List<QuizQuestion>>> fetchQuestionsByLevel() async {
    final rows = await _client
        .from('questions')
        .select('*, game_levels!inner(level_number)')
        .eq('is_published', true)
        .order('level_id')
        .order('sort_order');

    final result = <int, List<QuizQuestion>>{};
    for (final row in rows as List) {
      final levelNum =
          (row['game_levels'] as Map<String, dynamic>)['level_number'] as int;
      result
          .putIfAbsent(levelNum, () => [])
          .add(
            QuizQuestion(
              category: row['category'] as String,
              question: row['question'] as String,
              options: List<String>.from(row['options'] as List),
              answerIndex: row['answer_index'] as int,
              explanation: row['explanation'] as String? ?? '',
            ),
          );
    }
    return result;
  }

  static Future<List<KursusData>> fetchCourses() async {
    final rows = await _client
        .from('courses')
        .select()
        .eq('is_published', true)
        .order('sort_order');

    final list = rows as List;
    return [
      for (var i = 0; i < list.length; i++)
        _mapCourse(list[i] as Map<String, dynamic>, i),
    ];
  }

  static Future<Map<int, List<ModulMateri>>> fetchMaterialsByCourse() async {
    final rows = await _client
        .from('materials')
        .select('*, courses!inner(id, title)')
        .eq('is_published', true)
        .order('course_id')
        .order('sort_order');

    final result = <int, List<ModulMateri>>{};
    for (final row in rows as List) {
      final courseId = row['course_id'] as int;
      final courseTitle =
          (row['courses'] as Map<String, dynamic>)['title'] as String;
      final keyPoints = List<String>.from(
        row['key_points'] as List? ?? const [],
      );
      result
          .putIfAbsent(courseId, () => [])
          .add(
            ModulMateri(
              id: row['id'] as int,
              title: row['title'] as String,
              emoji: row['emoji'] as String? ?? '📘',
              totalDuration: row['duration_label'] as String? ?? 'Ringkas',
              videoTitle: 'Istilah inti $courseTitle',
              videoDescription: 'Kumpulan konsep awal yang perlu dipahami.',
              subMateri: [
                SubMateri(
                  title: row['title'] as String,
                  duration: row['duration_label'] as String? ?? 'Ringkas',
                  content: row['content'] as String? ?? '',
                  keyPoints: keyPoints,
                ),
              ],
            ),
          );
    }
    return result;
  }

  static Future<Map<LeaderboardPeriod, List<LeaderboardUser>>>
  fetchLeaderboard({String? currentUserId, String? currentUserName}) async {
    final result = <LeaderboardPeriod, List<LeaderboardUser>>{};
    const periods = {
      LeaderboardPeriod.minggu: 'minggu',
      LeaderboardPeriod.bulan: 'bulan',
      LeaderboardPeriod.semua: 'semua',
    };

    int? currentUserXp;
    if (currentUserId != null) {
      final profile = await _client
          .from('profiles')
          .select('xp, nama')
          .eq('id', currentUserId)
          .maybeSingle();
      if (profile != null) {
        currentUserXp = profile['xp'] as int? ?? 0;
      }
    }

    for (final entry in periods.entries) {
      final rows = await _client
          .from('leaderboard_entries')
          .select()
          .eq('period_type', entry.value)
          .order('xp', ascending: false)
          .limit(10);

      final rowList = rows as List;
      final userIds = <String>[];
      for (final row in rowList) {
        if (row["user_id"] != null) {
          userIds.add(row["user_id"] as String);
        }
      }
      if (currentUserId != null) {
        userIds.add(currentUserId);
      }
      final uniqueUserIds = userIds.toSet().toList();

      final gameLevels = await _fetchGameLevelsForUsers(uniqueUserIds);

      var users = [
        for (final row in rowList)
          LeaderboardUser(
            name: row['display_name'] as String,
            initials: row['initials'] as String,
            xp: row['xp'] as int,
            level: gameLevels[row['user_id'] as String?] ?? 1,
            badges: List<String>.from(row['badges'] as List? ?? []),
            avatarBg: Color(row['avatar_bg'] as int),
            avatarText: Color(row['avatar_text'] as int),
            isMe: currentUserId != null && row['user_id'] == currentUserId,
          ),
      ];

      if (currentUserId != null &&
          currentUserName != null &&
          !users.any((u) => u.isMe)) {
        users = [
          ...users,
          LeaderboardUser(
            name: currentUserName,
            initials: _initials(currentUserName),
            xp: currentUserXp ?? 0,
            level: gameLevels[currentUserId] ?? 1,
            badges: const [],
            avatarBg: const Color(0xFF081828),
            avatarText: const Color(0xFF4E9DFF),
            isMe: true,
          ),
        ];
      }

      result[entry.key] = users;
    }

    return result;
  }

  static Future<Map<String, int>> _fetchGameLevelsForUsers(
    List<String> userIds,
  ) async {
    if (userIds.isEmpty) return {};

    final prog = await _client
        .from('user_level_progress')
        .select('user_id, level_number, status')
        .inFilter('user_id', userIds);

    final byUser = <String, List<Map<String, dynamic>>>{};
    for (final row in prog as List) {
      final uid = row['user_id'] as String;
      byUser.putIfAbsent(uid, () => []).add(row as Map<String, dynamic>);
    }

    return {
      for (final id in userIds)
        id: gameLevelFromProgressRows(byUser[id] ?? const []),
    };
  }

  static LevelStatus _parseStatus(String raw) {
    switch (raw) {
      case 'selesai':
        return LevelStatus.selesai;
      case 'aktif':
        return LevelStatus.aktif;
      default:
        return LevelStatus.terkunci;
    }
  }

  static KursusData _mapCourse(Map<String, dynamic> row, int index) {
    return KursusData(
      id: row['id'] as int,
      emoji: row['emoji'] as String,
      category: row['category'] as String,
      title: row['title'] as String,
      instructor: row['instructor'] as String? ?? 'KursusKilat',
      progress: 0.0,
      totalDuration: row['total_duration'] as String? ?? '',
      modulesTotal: row['modules_total'] as int? ?? 4,
      modulesDone: 0,
      rating: row['rating'] as String? ?? '-',
      status: CourseStatus.notStarted,
      accentStart: Color(row['accent_start'] as int),
      accentEnd: Color(row['accent_end'] as int),
      lastAccessed: '',
      totalStudents: row['total_students'] as String? ?? '',
      description: row['description'] as String? ?? '',
      introVideoUrl: row['intro_video_url'] as String? ?? '',
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'YO';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
