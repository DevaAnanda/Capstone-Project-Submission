import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/mood_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('moodtrack.db');
    return _database!;
  }

  // Initialize database
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // Create database tables
  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textTypeNull = 'TEXT';

    await db.execute('''
      CREATE TABLE moods (
        id $idType,
        mood $textType,
        note $textType,
        date $textType,
        imagePath $textTypeNull
      )
    ''');
  }

  // Create - Insert mood entry
  Future<MoodEntry> create(MoodEntry mood) async {
    final db = await instance.database;
    final id = await db.insert('moods', mood.toMap());
    return mood.copyWith(id: id);
  }

  // Read - Get single mood entry
  Future<MoodEntry?> readMood(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'moods',
      columns: ['id', 'mood', 'note', 'date', 'imagePath'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return MoodEntry.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // Read - Get all mood entries
  Future<List<MoodEntry>> readAllMoods() async {
    final db = await instance.database;
    const orderBy = 'date DESC';
    final result = await db.query('moods', orderBy: orderBy);
    return result.map((json) => MoodEntry.fromMap(json)).toList();
  }

  // Read - Get moods by date range
  Future<List<MoodEntry>> readMoodsByDateRange(
      DateTime start, DateTime end) async {
    final db = await instance.database;
    final result = await db.query(
      'moods',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date DESC',
    );
    return result.map((json) => MoodEntry.fromMap(json)).toList();
  }

  // Update - Update mood entry
  Future<int> update(MoodEntry mood) async {
    final db = await instance.database;
    return db.update(
      'moods',
      mood.toMap(),
      where: 'id = ?',
      whereArgs: [mood.id],
    );
  }

  // Delete - Delete mood entry
  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      'moods',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get mood count by type
  Future<Map<String, int>> getMoodStatistics() async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT mood, COUNT(*) as count
      FROM moods
      GROUP BY mood
    ''');

    Map<String, int> statistics = {};
    for (var row in result) {
      statistics[row['mood'] as String] = row['count'] as int;
    }
    return statistics;
  }

  // Close database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
