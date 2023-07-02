// database_helper.dart
import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../model/exercise.dart';
import '../model/exercise_session.dart';
import '../model/session.dart';
import '../model/weight_reps_pair.dart';

class DatabaseHelper {
  static const _databaseName = "GymTracker.db";
  static const _databaseVersion = 1;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Exercise (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        lastWeight INTEGER,
        imageUrl TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE Session (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ExerciseSession (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sessionId INTEGER NOT NULL,
        exerciseId INTEGER NOT NULL,
        exerciseName TEXT NOT NULL,
        FOREIGN KEY (sessionId) REFERENCES Session (id) ON DELETE CASCADE,
        FOREIGN KEY (exerciseId) REFERENCES Exercise (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE WeightRepsPairs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        exerciseSessionId INTEGER NOT NULL,
        repetitions INTEGER NOT NULL,
        weight REAL NOT NULL,
        FOREIGN KEY (exerciseSessionId) REFERENCES ExerciseSession (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> purgeDatabase() async {
    final db = await database;
    // Assuming you have tables 'exercises', 'sessions', 'weight_reps_pairs', and 'exercise_sessions'
    await db.rawQuery('DELETE FROM WeightRepsPairs');
    await db.rawQuery('DELETE FROM ExerciseSession');
    await db.rawQuery('DELETE FROM Session');
    await db.rawQuery('DELETE FROM Exercise');
  }

  // use this in order to change the db schema
  Future<void> recreateDatabase() async {
    final db = await database;
    // Assuming you have tables 'exercises', 'sessions', 'weight_reps_pairs', and 'exercise_sessions'
    await db.rawQuery('DROP TABLE IF EXISTS WeightRepsPairs');
    await db.rawQuery('DROP TABLE IF EXISTS ExerciseSession');
    await db.rawQuery('DROP TABLE IF EXISTS Session');
    await db.rawQuery('DROP TABLE IF EXISTS Exercise');

    _onCreate(db, 0);
  }

  // Exercise methods
  Future<int> insertExercise(Exercise exercise) async {
    Database db = await database;
    return await db.insert('Exercise', exercise.toJson());
  }

  Future<int> updateExercise(Exercise exercise) async {
    Database db = await database;
    return await db.update(
      'Exercise',
      exercise.toJson(),
      where: 'id = ?',
      whereArgs: [exercise.id],
    );
  }

  Future<List<Exercise>> getExercises() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('Exercise', orderBy: "name");
    return maps.map((map) => Exercise.fromJson(map)).toList();
  }

  Future<Exercise?> getExerciseById(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps =
    await db.query('Exercise', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Exercise.fromJson(maps.first);
    } else {
      return null;
    }
  }

  Future<int> deleteExercise(int id) async {
    Database db = await database;
    return await db.delete('Exercise', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateSession(Session session) async {
    Database db = await database;
    return await db.update(
      'Session',
      session.toJson(),
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

// Session methods
  Future<int> insertSession(Session session) async {
    Database db = await database;
    return await db.insert('Session', session.toJson());
  }

  Future<Session?> getSessionById(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps =
    await db.query('Session', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Session.fromJson(maps.first);
    } else {
      return null;
    }
  }

  Future<List<Session>> getSessions() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('Session', orderBy: "date DESC");
    return maps.map((map) => Session.fromJson(map)).toList();
  }

  Future<int> deleteSession(int id) async {
    Database db = await database;
    return await db.delete('Session', where: 'id = ?', whereArgs: [id]);
  }

// ExerciseSession methods
  Future<int> insertExerciseSession(ExerciseSession exerciseSession) async {
    Database db = await database;
    final int exerciseSessionId = await db.insert('ExerciseSession', exerciseSession.toJson());
    for (final pair in exerciseSession.weightRepsPairs) {
      await db.insert('WeightRepsPairs', {
        'exerciseSessionId': exerciseSessionId,
        'repetitions': pair.repetitions,
        'weight': pair.weight,
      });
    }
    return exerciseSessionId;
  }

  Future<List<ExerciseSession>> getExerciseSessions(int sessionId) async {
    Database db = await database;
    List<Map> maps = await db.query('ExerciseSession', where: 'sessionId = ?', whereArgs: [sessionId]);
    List<ExerciseSession> exerciseSessions = [];
    for (final map in maps) {
      List<Map<String, dynamic>> weightRepsPairsMaps = await db.query('WeightRepsPairs', where: 'exerciseSessionId = ?', whereArgs: [map['id']]);
      List<WeightRepsPair> weightRepsPairs = weightRepsPairsMaps.map((pairJson) => WeightRepsPair.fromJson(pairJson)).toList();
      exerciseSessions.add(ExerciseSession.fromJson({...map, 'weightRepsPairs': weightRepsPairs}));
    }
    return exerciseSessions;
  }

  Future<int> deleteExerciseSession(int id) async {
    Database db = await database;
    await db.delete('WeightRepsPairs', where: 'exerciseSessionId = ?', whereArgs: [id]);
    return await db.delete('ExerciseSession', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateExerciseSession(ExerciseSession exerciseSession) async {
    Database db = await database;

    // Update the ExerciseSession itself
    int result = await db.update(
      'ExerciseSession',
      exerciseSession.toJson(),
      where: 'id = ?',
      whereArgs: [exerciseSession.id],
    );

    // Update or insert the WeightRepsPairs associated with this ExerciseSession
    for (final pair in exerciseSession.weightRepsPairs) {
      if (pair.id != null) {
        await db.update(
          'WeightRepsPairs',
          pair.toJson(),
          where: 'id = ?',
          whereArgs: [pair.id],
        );
      } else {
        await db.insert('WeightRepsPairs', {
          'exerciseSessionId': exerciseSession.id,
          'repetitions': pair.repetitions,
          'weight': pair.weight,
        });
      }
    }

    return result;
  }

  Future<List<ExerciseSession>> getExerciseSessionsByExerciseId(int exerciseId) async {
    Database db = await database;
    List<Map> maps = await db.query('ExerciseSession', where: 'exerciseId = ?', whereArgs: [exerciseId]);
    List<ExerciseSession> exerciseSessions = [];
    for (final map in maps) {
      List<Map<String, dynamic>> weightRepsPairsMaps = await db.query('WeightRepsPairs', where: 'exerciseSessionId = ?', whereArgs: [map['id']]);
      List<WeightRepsPair> weightRepsPairs = weightRepsPairsMaps.map((pairJson) => WeightRepsPair.fromJson(pairJson)).toList();
      exerciseSessions.add(ExerciseSession.fromJson({...map, 'weightRepsPairs': weightRepsPairs}));
    }
    return exerciseSessions;
  }

  Future<List<ExerciseSession>> getExerciseSessionsBySessionId(int sessionId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('ExerciseSession', where: 'sessionId = ?', whereArgs: [sessionId]);
    List<ExerciseSession> exerciseSessions = [];
    for (var map in maps) {
      List<Map<String, dynamic>> weightRepsPairsMaps = await db.query('WeightRepsPairs', where: 'exerciseSessionId = ?', whereArgs: [map['id']]);
      List<WeightRepsPair> weightRepsPairs = weightRepsPairsMaps.map((pairJson) => WeightRepsPair.fromJson(pairJson)).toList();
      Exercise? exercise = await getExerciseById(map['exerciseId']);
      Map<String, dynamic> newMap = {};
      newMap.addAll(map);
      newMap.addAll({'exerciseName':exercise!.name});
      exerciseSessions.add(ExerciseSession.fromJson(newMap, weightRepsPairs: weightRepsPairs));
    }
    return exerciseSessions;
  }

// WeightRepsPair methods
  Future<int> insertWeightRepsPair(WeightRepsPair weightRepsPair) async {
    Database db = await database;
    return await db.insert('WeightRepsPairs', weightRepsPair.toJson());
  }

  Future<List<WeightRepsPair>> getWeightRepsPairsByExerciseSessionId(int exerciseSessionId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('WeightRepsPairs', where: 'exerciseSessionId = ?', whereArgs: [exerciseSessionId]);
    return maps.map((map) => WeightRepsPair.fromJson(map)).toList();
  }

  Future<int> updateWeightRepsPair(WeightRepsPair weightRepsPair) async {
    Database db = await database;
    return await db.update('WeightRepsPairs', weightRepsPair.toJson(), where: 'id = ?', whereArgs: [weightRepsPair.id]);
  }

  Future<int> deleteWeightRepsPair(int id) async {
    Database db = await database;
    return await db.delete('WeightRepsPairs', where: 'id = ?', whereArgs: [id]);
  }

  Future<WeightRepsPair?> getLastWeightRepsPair(int exerciseId) async {
    final db = await database;

    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT WeightRepsPairs.*
    FROM ExerciseSession
    JOIN Exercise ON Exercise.id = ExerciseSession.exerciseId
    JOIN WeightRepsPairs ON WeightRepsPairs.exerciseSessionId = ExerciseSession.id
    WHERE Exercise.id = ?
    ORDER BY WeightRepsPairs.id DESC
    LIMIT 1
  ''', [exerciseId]);

    if (result.isNotEmpty) {
      return WeightRepsPair.fromJson(result.first);
    } else {
      return null;
    }
  }

  Future<void> updateLastWeight(int exerciseId) async {
    final db = await database;
    Exercise? exercise = await DatabaseHelper.instance.getExerciseById(exerciseId);
    WeightRepsPair? lastWeightRepsPair = await getLastWeightRepsPair(exercise?.id ?? 0);

    if (lastWeightRepsPair != null) {
      double newLastWeight = lastWeightRepsPair.weight;
      Exercise updatedExercise = Exercise(
        id: exercise?.id,
        name: exercise?.name ?? "",
        lastWeight: newLastWeight.toInt(),
        imageUrl: exercise?.imageUrl ?? "",
      );

      await db.update(
        'Exercise',
        updatedExercise.toJson(),
        where: 'id = ?',
        whereArgs: [exercise?.id],
      );
    }
  }

}
