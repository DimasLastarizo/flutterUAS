enum LevelStatus { selesai, aktif, terkunci }

class LevelData {
  final int id;
  final String title;
  final String topic;
  final LevelStatus status;
  final int questions;
  final int stars;

  /// Indeks kategori topik (0–4) untuk emoji/nama di dialog game.
  final int moduleIndex;

  /// Indeks kursus di tab Materi (0-based).
  final int courseIndex;

  /// Indeks modul materi dalam kursus (0-based).
  final int materialIndex;

  /// ID kursus/materi dari Supabase untuk deep link yang tidak bergantung urutan list.
  final int? courseId;
  final int? materialId;

  const LevelData({
    required this.id,
    required this.title,
    required this.topic,
    required this.status,
    required this.questions,
    required this.stars,
    required this.moduleIndex,
    this.courseIndex = 0,
    this.materialIndex = 0,
    this.courseId,
    this.materialId,
  });
}

const List<LevelData> kFallbackLevels = [
  LevelData(
    id: 1,
    title: 'Pemanasan',
    topic: 'Dasar Komputer',
    status: LevelStatus.selesai,
    questions: 10,
    stars: 3,
    moduleIndex: 0,
    courseIndex: 0,
    materialIndex: 0,
  ),
  LevelData(
    id: 2,
    title: 'Konsep Inti',
    topic: 'Algoritma',
    status: LevelStatus.selesai,
    questions: 10,
    stars: 3,
    moduleIndex: 1,
    courseIndex: 1,
    materialIndex: 0,
  ),
  LevelData(
    id: 3,
    title: 'Latihan Cepat',
    topic: 'Pemrograman',
    status: LevelStatus.selesai,
    questions: 10,
    stars: 2,
    moduleIndex: 2,
    courseIndex: 0,
    materialIndex: 1,
  ),
  LevelData(
    id: 4,
    title: 'Misi Aktif',
    topic: 'Jaringan Komputer',
    status: LevelStatus.aktif,
    questions: 10,
    stars: 0,
    moduleIndex: 3,
    courseIndex: 3,
    materialIndex: 0,
  ),
  LevelData(
    id: 5,
    title: 'Tantangan Baru',
    topic: 'Keamanan Digital',
    status: LevelStatus.terkunci,
    questions: 10,
    stars: 0,
    moduleIndex: 4,
    courseIndex: 3,
    materialIndex: 3,
  ),
  LevelData(
    id: 6,
    title: 'Combo Soal',
    topic: 'Dasar Komputer',
    status: LevelStatus.terkunci,
    questions: 10,
    stars: 0,
    moduleIndex: 0,
    courseIndex: 0,
    materialIndex: 2,
  ),
  LevelData(
    id: 7,
    title: 'Mode Fokus',
    topic: 'Algoritma',
    status: LevelStatus.terkunci,
    questions: 10,
    stars: 0,
    moduleIndex: 1,
    courseIndex: 1,
    materialIndex: 1,
  ),
  LevelData(
    id: 8,
    title: 'Boss Quiz',
    topic: 'Pemrograman',
    status: LevelStatus.terkunci,
    questions: 10,
    stars: 0,
    moduleIndex: 2,
    courseIndex: 0,
    materialIndex: 3,
  ),
  LevelData(
    id: 9,
    title: 'Speed Run',
    topic: 'Jaringan Komputer',
    status: LevelStatus.terkunci,
    questions: 10,
    stars: 0,
    moduleIndex: 3,
    courseIndex: 3,
    materialIndex: 1,
  ),
  LevelData(
    id: 10,
    title: 'Final Stage',
    topic: 'Keamanan Digital',
    status: LevelStatus.terkunci,
    questions: 10,
    stars: 0,
    moduleIndex: 4,
    courseIndex: 3,
    materialIndex: 2,
  ),
  LevelData(
    id: 11,
    title: 'Bonus Map',
    topic: 'Dasar Komputer',
    status: LevelStatus.terkunci,
    questions: 10,
    stars: 0,
    moduleIndex: 0,
    courseIndex: 1,
    materialIndex: 2,
  ),
  LevelData(
    id: 12,
    title: 'Master Quiz',
    topic: 'Algoritma',
    status: LevelStatus.terkunci,
    questions: 10,
    stars: 0,
    moduleIndex: 1,
    courseIndex: 1,
    materialIndex: 3,
  ),
];
