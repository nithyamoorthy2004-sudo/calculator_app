import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('calculator.db');
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

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        calculation TEXT
      )
    ''');
  }

  // 🔹 INSERT
  Future<void> insert(String calculation) async {
    final db = await instance.database;
    await db.insert('history', {'calculation': calculation});
  }

  // 🔹 GET HISTORY
  Future<List<Map<String, dynamic>>> getHistory() async {
    final db = await instance.database;
    return await db.query('history', orderBy: 'id DESC');
  }

  // 🔹 DELETE SINGLE ITEM
  Future<void> delete(int id) async {
    final db = await instance.database;
    await db.delete('history', where: 'id = ?', whereArgs: [id]);
  }

  // 🔹 CLEAR ALL HISTORY
  Future<void> clearAll() async {
    final db = await instance.database;
    await db.delete('history');
  }
}
