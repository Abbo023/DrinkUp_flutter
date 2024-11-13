import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/Personal.dart';
import '../models/ShopIngredient.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper.internal();
  static Database? _database;

  factory DatabaseHelper() {
    return instance;
  }

  DatabaseHelper.internal();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'app_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE personal (
            id TEXT PRIMARY KEY,
            name TEXT,
            autore TEXT,
            instruction TEXT,
            image TEXT,
            ingredients TEXT,
            likes INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE ingredients (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            quantity INTEGER
          )
        ''');
      },
    );
  }

  //metodi per le ricette personali
  Future<List<Personal>> getPersonals() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('personal');
    return List.generate(maps.length, (i) {
      return Personal.fromMap(maps[i]);
    });
  }

  Future<void> insertPersonal(Personal personal) async {
    final db = await database;
    await db.insert(
      'personal',
      personal.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updatePersonal(Personal personal) async {
    final db = await database;
    await db.update(
      'personal',
      personal.toMap(),
      where: 'id = ?',
      whereArgs: [personal.id],
    );
  }

  Future<void> deletePersonal(String id) async {
    final db = await database;
    await db.delete(
      'personal',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  //metodi per gli Ingredienti
  Future<List<ShopIngredient>> getIngredients() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('ingredients');
    return List.generate(maps.length, (i) {
      return ShopIngredient.fromMap(maps[i]);
    });
  }

  Future<void> insertIngredient(ShopIngredient ingredient) async {
    final db = await database;
    await db.insert(
      'ingredients',
      ingredient.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateIngredient(ShopIngredient ingredient) async {
    final db = await database;
    await db.update(
      'ingredients',
      ingredient.toMap(),
      where: 'id = ?',
      whereArgs: [ingredient.id],
    );
  }

  Future<void> deleteIngredient(int id) async {
    final db = await database;
    await db.delete(
      'ingredients',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
