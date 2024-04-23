import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

Future<Database> openMyDatabase() async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'my_database.db');
  final database = await openDatabase(
    path,
    version: 1,
    onCreate: (db, version) async {
      // Create table for experiments, each experiment has a title and a brief description, along
      // with a list of procedures inside it.
      await db.execute(
          'CREATE TABLE experiments(id INTEGER PRIMARY KEY, title TEXT, brief_description TEXT, created_time TEXT, last_updated TEXT)');
      // Create table for procedures, each procedure has a title, a brief description, and a list of
      // steps inside it.
      await db.execute(
          'CREATE TABLE procedures(id INTEGER PRIMARY KEY, title TEXT, brief_description TEXT)');
      // Table for default procedures for the app
      await db.execute(
          'CREATE TABLE default_procedures(id INTEGER PRIMARY KEY, title TEXT, brief_description TEXT)');
    },
  );
  return database;
}
