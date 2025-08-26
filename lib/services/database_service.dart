import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/person.dart';
import '../models/cue.dart';
import '../models/asset.dart';
import '../models/activity.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('cue_collector.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // People table
    await db.execute('''
      CREATE TABLE people(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Cues table
    await db.execute('''
      CREATE TABLE cues(
        id TEXT PRIMARY KEY,
        person_id TEXT NOT NULL,
        type TEXT NOT NULL,
        content TEXT NOT NULL,
        audio_path TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (person_id) REFERENCES people (id)
      )
    ''');

    // Assets table
    await db.execute('''
      CREATE TABLE assets(
        id TEXT PRIMARY KEY,
        person_id TEXT NOT NULL,
        name TEXT NOT NULL,
        status TEXT NOT NULL,
        progress REAL NOT NULL DEFAULT 0.0,
        total_amount REAL,
        current_amount REAL DEFAULT 0.0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (person_id) REFERENCES people (id)
      )
    ''');

    // Activities table
    await db.execute('''
      CREATE TABLE activities(
        id TEXT PRIMARY KEY,
        person_id TEXT NOT NULL,
        name TEXT NOT NULL,
        is_current INTEGER NOT NULL DEFAULT 0,
        started_at TEXT,
        ended_at TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (person_id) REFERENCES people (id)
      )
    ''');

    // Numeric inputs table (for +/- tracking)
    await db.execute('''
      CREATE TABLE numeric_inputs(
        id TEXT PRIMARY KEY,
        person_id TEXT NOT NULL,
        amount REAL NOT NULL,
        reason TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (person_id) REFERENCES people (id)
      )
    ''');
  }

  Future<void> initDatabase() async {
    await database;
  }

  // Person CRUD operations
  Future<String> createPerson(Person person) async {
    final db = await database;
    await db.insert('people', person.toMap());
    return person.id;
  }

  Future<List<Person>> getAllPeople() async {
    final db = await database;
    final result = await db.query('people', orderBy: 'name ASC');
    return result.map((map) => Person.fromMap(map)).toList();
  }

  Future<Person?> getPerson(String id) async {
    final db = await database;
    final result = await db.query(
      'people',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return Person.fromMap(result.first);
    }
    return null;
  }

  // Cue CRUD operations
  Future<String> createCue(Cue cue) async {
    final db = await database;
    await db.insert('cues', cue.toMap());
    return cue.id;
  }

  Future<List<Cue>> getCuesForPerson(String personId) async {
    final db = await database;
    final result = await db.query(
      'cues',
      where: 'person_id = ?',
      whereArgs: [personId],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => Cue.fromMap(map)).toList();
  }

  // Asset CRUD operations
  Future<String> createAsset(Asset asset) async {
    final db = await database;
    await db.insert('assets', asset.toMap());
    return asset.id;
  }

  Future<List<Asset>> getAssetsForPerson(String personId) async {
    final db = await database;
    final result = await db.query(
      'assets',
      where: 'person_id = ?',
      whereArgs: [personId],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => Asset.fromMap(map)).toList();
  }

  Future<void> updateAsset(Asset asset) async {
    final db = await database;
    await db.update(
      'assets',
      asset.toMap(),
      where: 'id = ?',
      whereArgs: [asset.id],
    );
  }

  // Activity CRUD operations
  Future<String> createActivity(Activity activity) async {
    final db = await database;
    await db.insert('activities', activity.toMap());
    return activity.id;
  }

  Future<List<Activity>> getActivitiesForPerson(String personId) async {
    final db = await database;
    final result = await db.query(
      'activities',
      where: 'person_id = ?',
      whereArgs: [personId],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => Activity.fromMap(map)).toList();
  }

  Future<void> setCurrentActivity(String personId, String activityId) async {
    final db = await database;
    // First, clear all current activities for this person
    await db.update(
      'activities',
      {'is_current': 0, 'ended_at': DateTime.now().toIso8601String()},
      where: 'person_id = ? AND is_current = 1',
      whereArgs: [personId],
    );
    
    // Then set the new current activity
    await db.update(
      'activities',
      {
        'is_current': 1, 
        'started_at': DateTime.now().toIso8601String(),
        'ended_at': null
      },
      where: 'id = ?',
      whereArgs: [activityId],
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
