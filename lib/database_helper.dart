import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('personel.db');
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
    CREATE TABLE Personel (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      ad TEXT,
      soyad TEXT,
      departman TEXT,
      maas INTEGER
    )
    ''');
  }

  Future<int> addPersonel(Map<String, dynamic> personel) async {
    final db = await instance.database;
    return await db.insert('Personel', personel);
  }

  Future<int> updatePersonel(Map<String, dynamic> personel) async {
    final db = await instance.database;
    return await db.update(
      'Personel',
      personel,
      where: 'id = ?',
      whereArgs: [personel['id']],
    );
  }

  Future<int> deletePersonel(int id) async {
    final db = await instance.database;
    return await db.delete(
      'Personel',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getAllPersonel() async {
    final db = await instance.database;
    return await db.query('Personel');
  }

  Future<List<Map<String, dynamic>>> getPersonelGroupedByDepartment() async {
    final db = await instance.database;
    return await db.rawQuery('SELECT departman, SUM(maas) as toplam_maas FROM Personel GROUP BY departman');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
