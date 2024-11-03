import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Database helper class to manage SQLite database operations
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  /// Getter for the database. Initializes if it does not exist.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('employee.db');
    return _database!;
  }

  /// Initializes the database at the given file path
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  /// Creates the Employee table with columns for id, firstName, lastName, department, and salary
  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE Employee (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      firstName TEXT,
      lastName TEXT,
      department TEXT,
      salary INTEGER
    )
    ''');
  }

  /// Adds a new employee record to the database
  Future<int> addEmployee(Map<String, dynamic> employee) async {
    final db = await instance.database;
    return await db.insert('Employee', employee);
  }

  /// Updates an existing employee record in the database
  Future<int> updateEmployee(Map<String, dynamic> employee) async {
    final db = await instance.database;
    return await db.update(
      'Employee',
      employee,
      where: 'id = ?',
      whereArgs: [employee['id']],
    );
  }

  /// Deletes an employee record from the database by id
  Future<int> deleteEmployee(int id) async {
    final db = await instance.database;
    return await db.delete(
      'Employee',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Retrieves all employee records from the database
  Future<List<Map<String, dynamic>>> getAllEmployees() async {
    final db = await instance.database;
    return await db.query('Employee');
  }

  /// Groups employees by department and calculates total salary for each department
  Future<List<Map<String, dynamic>>> getEmployeesGroupedByDepartment() async {
    final db = await instance.database;
    return await db.rawQuery('SELECT department, SUM(salary) as total_salary FROM Employee GROUP BY department');
  }

  /// Closes the database connection
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
