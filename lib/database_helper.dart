import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;
  final String tableName = 'favorite_movies';

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = await getDatabasesPath();
    final databasePath = join(path, 'favorite_movies.db');

    return await openDatabase(databasePath, version: 1, onCreate: (db, version) {
      return db.execute(
          'CREATE TABLE $tableName(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, year TEXT, poster TEXT)');
    });
  }

  Future<int> insertFavorite(Map<String, dynamic> movie) async {
    final db = await database;
    return await db.insert(tableName, movie);
  }

  Future<List<Map<String, dynamic>>> getFavoriteMovies() async {
    final db = await database;
    return await db.query(tableName);
  }
}
