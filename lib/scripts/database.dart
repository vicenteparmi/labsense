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
          'CREATE TABLE experiments(id INTEGER PRIMARY KEY, title TEXT, brief_description TEXT, created_time TEXT, last_updated TEXT, icon TEXT)');
      // Table for procedures, each procedure has a title, a brief description, a list of steps, and a list of models.
      await db.execute('''
        CREATE TABLE procedures (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          brief_description TEXT,
          model_type TEXT,
          initial_potential TEXT,
          final_potential TEXT,
          scan_rate TEXT,
          cycle_count TEXT,
          sweep_direction INTEGER
        )
      ''');
      // Table for default procedures for the app
      await db.execute(
          'CREATE TABLE custom_procedures(id INTEGER PRIMARY KEY, title TEXT, brief_description TEXT)');
    },
  );
  return database;
}
