import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'models/StudentModel.dart';

class DatabaseProvider {
  // private constructor
  DatabaseProvider.internal();

  // static instance
  static final DatabaseProvider db = DatabaseProvider.internal();

  // SQLite database
  Database _database;

  Future<Database> get database async {
    if (_database != null) return databaseInstance();
    _database = await databaseInstance();
    return _database;
  }

  Future<Database> databaseInstance() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = join(dir.path, "app_database.db");
    return await openDatabase(
        path,
        version: 1,
        onCreate: (db, v) async {
          await db.execute(
              "CREATE TABLE IF NOT EXISTS `students` ( `id` INTEGER PRIMARY KEY AUTOINCREMENT, `first_name` TEXT, `last_name` TEXT, `grade` INT)");
        }
    );
  }

  Future<List<Student>> getAllStudents() async {
    final db = await database;
    var response = await db.query('students');
    List<Student> list = response.map(
            (s) => Student.fromMap(s)
    ).toList();
    return list;
  }

  Future<Student> getStudentById(int id) async {
    final db = await database;
    var response = await db.query(
        'students',
        where: "id = ?",
        whereArgs: [id]
    );
    return response.isEmpty ? Student.fromMap(response.first) : null;
  }

  Future<int> addStudent(Student student) async {
    final db = await database;
    int id = await db.insert(
        'students',
        student.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace
    );
    return id;
  }

  deleteAllStudents() async {
    final db = await database;
    db.delete("students");
  }

  deleteStudent(int id) async {
    final db = await database;
    db.delete("students", where: "id = ?", whereArgs: [id]);
  }

  Future<int> updateStudent(Student student) async {
    final db = await database;
    var id = await db.update(
        "students",
        student.toMap(),
        where: "id = ?",
        whereArgs: [student.id]
    );
    return id;
  }
}