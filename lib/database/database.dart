import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';


class DatabaseProvider {
  // private constructor
  DatabaseProvider.internal();

  // static instance
  static final DatabaseProvider db = DatabaseProvider.internal();

  // SQLite database
  Database _database;

  Future<Database> get database async {
    if(_database != null) return databaseInstance();
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
          await db.execute("CREATE TABLE IF NOT EXISTS `students` ( `id` INTEGER PRIMARY KEY AUTOINCREMENT, `first_name` TEXT, `last_name` TEXT, `grade` INT)");
        }
    );
  }
}