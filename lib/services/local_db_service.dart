import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDbService {
  LocalDbService._();
  static final LocalDbService instance = LocalDbService._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'fitness_tracker.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            password TEXT NOT NULL,
            role TEXT NOT NULL DEFAULT 'user'
          )
        ''');

        await db.execute('''
          CREATE TABLE workouts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            type TEXT NOT NULL,
            duration INTEGER NOT NULL,
            frequency_per_week INTEGER NOT NULL,
            date TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE workout_types (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL UNIQUE
          )
        ''');

        await db.insert('workout_types', {'name': 'Running'});
        await db.insert('workout_types', {'name': 'Weight Training'});
        await db.insert('workout_types', {'name': 'Yoga'});

        await db.insert('users', {
          'username': 'admin',
          'email': 'admin@fitness.com',
          'password': 'admin123',
          'role': 'admin',
        });
      },
    );
  }
}

