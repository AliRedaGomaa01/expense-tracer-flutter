import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class KeyValueDatabase {
  static final KeyValueDatabase _instance = KeyValueDatabase._internal();
  static Database? _database;

  KeyValueDatabase._internal();

  factory KeyValueDatabase() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'key_value_cache.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE key_value (
            key TEXT PRIMARY KEY,
            value TEXT
          )
        ''');
      },
    );
  }

  Future<void> setValue(String key, String value) async {
    final db = await database;
    await db.insert(
      'key_value',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getValue(String key) async {
    final db = await database;
    final result = await db.query(
      'key_value',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [key],
    );
    if (result.isNotEmpty) {
      return result.first['value'] as String?;
    }
    return null;
  }

  Future<void> deleteValue(String key) async {
    final db = await database;
    await db.delete(
      'key_value',
      where: 'key = ?',
      whereArgs: [key],
    );
  }

  Future<void> clear() async {
    final db = await database;
    await db.delete('key_value');
  }
}

/*
********************** Usage

  final db = KeyValueDatabase();

  // Set a value
  await db.setValue('username', 'JohnDoe');
  await db.setValue('theme', 'dark');

  // Get a value
  String? username = await db.getValue('username');
  print('Username: $username'); // Output: JohnDoe

  // Delete a value
  await db.deleteValue('theme');

  // Clear all data
  await db.clear();
*/
