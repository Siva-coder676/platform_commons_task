import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/user_response.dart';
import '../models/movie_response.dart';
import 'api_service.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'platformCommons.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            firstName TEXT NOT NULL,
            lastName TEXT NOT NULL,
            job TEXT,
            avatar TEXT,
            email TEXT,
            synced INTEGER DEFAULT 0
          )
        ''');

        await db.execute('''
          CREATE TABLE movies(
            id INTEGER PRIMARY KEY,
            title TEXT,
            overview TEXT,
            poster_path TEXT,
            release_date TEXT,
            vote_average REAL
          )
        ''');
      },
    );
  }

  Future<int> insertUser(UserResponse user) async {
    try {
      final db = await database;
      print('Inserting user: ${user.id}');

      return await db.insert(
        'users',
        user.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error inserting user: $e');
      return -1;
    }
  }

  Future<List<UserResponse>> getOfflineUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'synced = ?',
      whereArgs: [0],
    );

    return List.generate(maps.length, (i) {
      return UserResponse(
        id: maps[i]['id'],
        firstName: maps[i]['firstName'],
        lastName: maps[i]['lastName'],
        job: maps[i]['job'],
        avatar: maps[i]['avatar'],
        email: maps[i]['email'],
      );
    });
  }

  Future<void> markUserAsSynced(int localId, int? remoteId) async {
    final db = await database;
    await db.update(
      'users',
      {
        'synced': 1,
        'id': remoteId,
      },
      where: 'id = ?',
      whereArgs: [localId],
    );
  }

  Future<void> syncOfflineUsers() async {
    final apiService = ApiService();
    final offlineUsers = await getOfflineUsers();

    for (final user in offlineUsers) {
      try {
        final createdUser = await apiService.createUser(user);
        await markUserAsSynced(user.id!, createdUser.id);
      } catch (e) {
        print('Failed to sync user: $e');
      }
    }
  }

  Future<List<UserResponse>> getUsers({required int page, int? limit}) async {
    final db = await database;
    final offset = (page - 1) * limit!;

    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      limit: limit,
      offset: offset,
    );

    return List.generate(maps.length, (i) {
      return UserResponse.fromJson(maps[i]);
    });
  }

  Future<int> insertMovie(MovieResponse movie) async {
    try {
      final db = await database;
      print('Inserting movie: ${movie.id}');

      return await db.insert(
        'movies',
        movie.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error inserting movie: ${e.toString()}');
      return -1;
    }
  }

  Future<List<MovieResponse>> getMovies({required int page, int? limit}) async {
    try {
      final db = await database;
      final offset =
          (page - 1) * (limit ?? 20); // Default 20 if limit not passed

      final List<Map<String, dynamic>> maps = await db.query(
        'movies',
        limit: limit,
        offset: offset,
      );

      return List.generate(maps.length, (i) {
        return MovieResponse.fromJson(maps[i]);
      });
    } catch (e) {
      print('Error retrieving movies from database: $e');
      return [];
    }
  }
}
