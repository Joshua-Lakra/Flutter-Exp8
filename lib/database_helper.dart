import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('students.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE students (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            course TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // CREATE
  Future<int> insertStudent(Map<String, dynamic> student) async {
    final db = await database;
    return await db.insert('students', student);
  }

  // READ
  Future<List<Map<String, dynamic>>> getStudents() async {
    final db = await database;
    return await db.query('students', orderBy: 'id DESC');
  }

  // UPDATE
  Future<int> updateStudent(
      int id, Map<String, dynamic> student) async {
    final db = await database;

    return await db.update(
      'students',
      student,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // DELETE
  Future<int> deleteStudent(int id) async {
    final db = await database;

    return await db.delete(
      'students',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}