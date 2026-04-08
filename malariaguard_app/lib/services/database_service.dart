import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'malariaguard.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE diagnoses(id INTEGER PRIMARY KEY AUTOINCREMENT, patientName TEXT, weight REAL, rdtResult TEXT, dosage TEXT, isEmergency INTEGER, timestamp TEXT)',
        );
      },
    );
  }

  Future<void> saveDiagnosis(Map<String, dynamic> diagnosis) async {
    final db = await database;
    await db.insert(
      'diagnoses',
      diagnosis,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> fetchDiagnoses() async {
    final db = await database;
    return await db.query('diagnoses', orderBy: 'timestamp DESC');
  }
}
