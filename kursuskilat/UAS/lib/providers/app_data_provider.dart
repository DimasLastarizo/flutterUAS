import 'package:flutter/foundation.dart';

import '../data/content_fallback.dart';
import '../services/auth_service.dart';
import '../services/content_service.dart';
import '../models/level_data.dart';
import '../screens/quiz_page.dart';
import '../screens/materi_page.dart';
import '../screens/leaderboard_page.dart';

class AppDataProvider extends ChangeNotifier {
  bool isLoading = false;
  bool isLoaded = false;
  String? loadError;

  List<LevelData> levels = fallbackLevels;
  Map<int, List<QuizQuestion>> questionsByLevel = {};
  List<QuizQuestion> questions = fallbackQuestions;
  List<KursusData> courses = fallbackCourses;
  Map<int, List<ModulMateri>> materialsByCourseId = {};
  Map<LeaderboardPeriod, List<LeaderboardUser>> leaderboard =
      fallbackLeaderboard;

  /// XP profil user saat ini (dari Supabase).
  int userXp = 0;
  int userLevel = 1;
  int totalCompletedLevels = 0;

  Future<void> load() async {
    if (isLoading) return;
    isLoading = true;
    loadError = null;
    notifyListeners();

    final userId = AuthService.currentUser?.id;
    if (userId != null) {
      await ContentService.ensureSeasonCurrent();
    }

    final profile = await AuthService.fetchProfile();
    final userName = profile?['nama'] as String?;

    if (profile != null) {
      userXp = profile['xp'] as int? ?? 0;
      userLevel = profile['level'] as int? ?? 1;
      totalCompletedLevels = profile['total_completed_levels'] as int? ?? 0;
    }

    try {
      final fetchedLevels = await ContentService.fetchLevels(userId: userId);
      final fetchedQuestionsByLevel =
          await ContentService.fetchQuestionsByLevel();
      final fetchedCourses = await ContentService.fetchCourses();
      final fetchedMaterials = await ContentService.fetchMaterialsByCourse();
      final fetchedLeaderboard = await ContentService.fetchLeaderboard(
        currentUserId: userId,
        currentUserName: userName,
      );

      if (fetchedLevels.isNotEmpty) {
        levels = [...fetchedLevels]..sort((a, b) => a.id.compareTo(b.id));
      }
      if (fetchedQuestionsByLevel.isNotEmpty) {
        questionsByLevel = fetchedQuestionsByLevel;
        questions = fetchedQuestionsByLevel.values.expand((q) => q).toList();
      }
      if (fetchedCourses.isNotEmpty) courses = fetchedCourses;
      if (fetchedMaterials.isNotEmpty) materialsByCourseId = fetchedMaterials;
      if (fetchedLeaderboard.isNotEmpty) leaderboard = fetchedLeaderboard;

      isLoaded = true;
    } catch (e) {
      loadError = e.toString();
      if (kDebugMode) {
        debugPrint('Supabase load fallback: $e');
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Reload progress, profil, dan leaderboard setelah quiz selesai.
  Future<void> refreshAfterQuiz() async {
    final userId = AuthService.currentUser?.id;
    try {
      final fetchedLevels = await ContentService.fetchLevels(userId: userId);
      if (fetchedLevels.isNotEmpty) {
        levels = [...fetchedLevels]..sort((a, b) => a.id.compareTo(b.id));
      }
      final profile = await AuthService.fetchProfile();
      final userName = profile?['nama'] as String?;
      if (profile != null) {
        userXp = profile['xp'] as int? ?? userXp;
        userLevel = profile['level'] as int? ?? userLevel;
        totalCompletedLevels =
            profile['total_completed_levels'] as int? ?? totalCompletedLevels;
      }
      final fetchedLeaderboard = await ContentService.fetchLeaderboard(
        currentUserId: userId,
        currentUserName: userName,
      );
      if (fetchedLeaderboard.isNotEmpty) leaderboard = fetchedLeaderboard;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) debugPrint('refreshAfterQuiz: $e');
    }
  }

  /// @deprecated use [refreshAfterQuiz]
  Future<void> refreshLevels() => refreshAfterQuiz();

  List<ModulMateri> modulesForCourse(KursusData course) {
    final fromDb = materialsByCourseId[course.id];
    if (fromDb != null && fromDb.isNotEmpty) return fromDb;
    return buildModules(course.title);
  }

  QuizQuestion questionForLevel(LevelData level, int index) {
    final levelQuestions = questionsByLevel[level.id];
    if (levelQuestions != null && levelQuestions.isNotEmpty) {
      final safeIndex = index.clamp(0, levelQuestions.length - 1);
      return levelQuestions[safeIndex];
    }
    if (questions.isEmpty) return questionForLevelFallback(level, index);
    return questionForLevelFallback(level, index);
  }

  void reset() {
    isLoaded = false;
    levels = fallbackLevels;
    questionsByLevel = {};
    questions = fallbackQuestions;
    courses = fallbackCourses;
    materialsByCourseId = {};
    leaderboard = fallbackLeaderboard;
    userXp = 0;
    userLevel = 1;
    totalCompletedLevels = 0;
    notifyListeners();
  }
}
