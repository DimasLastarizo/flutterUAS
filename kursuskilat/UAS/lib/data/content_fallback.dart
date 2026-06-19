import '../models/level_data.dart';
import '../screens/quiz_page.dart';
import '../screens/materi_page.dart';
import '../screens/leaderboard_page.dart';

List<LevelData> get fallbackLevels => List<LevelData>.from(kFallbackLevels);

List<QuizQuestion> get fallbackQuestions =>
    List<QuizQuestion>.from(questionBank);

List<KursusData> get fallbackCourses => buildCourses();

Map<LeaderboardPeriod, List<LeaderboardUser>> get fallbackLeaderboard =>
    Map<LeaderboardPeriod, List<LeaderboardUser>>.from(leaderboardFallback);
