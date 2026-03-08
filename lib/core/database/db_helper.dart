import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../modules/task/models/task_model.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('task_manager.db');
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
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        dateTime TEXT NOT NULL,
        priority INTEGER NOT NULL,
        category TEXT NOT NULL,
        isCompleted INTEGER NOT NULL
      )
    ''');
  }

  Future<TaskModel> insertTask(TaskModel task) async {
    final db = await instance.database;
    final id = await db.insert('tasks', task.toMap());
    return task.copyWith(id: id);
  }

  Future<List<TaskModel>> fetchAllTasks() async {
    final db = await instance.database;
    final result = await db.query('tasks');
    return result.map((json) => TaskModel.fromMap(json)).toList();
  }

  Future<int> updateTask(TaskModel task) async {
    final db = await instance.database;
    return db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await instance.database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}