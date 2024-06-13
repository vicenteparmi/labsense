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
          'CREATE TABLE experiments(id INTEGER PRIMARY KEY, title TEXT, brief_description TEXT, created_time TEXT, last_updated TEXT, icon INTEGER)');
      // Table for procedures, each procedure has a title, a brief description, a list of steps, and a list of models.
      await db.execute('''
        CREATE TABLE procedures (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          brief_description TEXT,
          model_type TEXT,
          initial_potential TEXT,
          final_potential TEXT,
          start_potential TEXT,
          scan_rate TEXT,
          cycle_count TEXT,
          sweep_direction INTEGER
        )
      ''');
      // Table for default procedures for the app
      await db.execute('''
        CREATE TABLE custom_procedures (
          id INTEGER PRIMARY KEY,
          title TEXT,
          brief_description TEXT,
          model_type TEXT,
          initial_potential TEXT,
          final_potential TEXT,
          start_potential TEXT,
          scan_rate TEXT,
          cycle_count TEXT,
          sweep_direction INTEGER,
          experiment_id INTEGER,
          experiment_order INTEGER)
      ''');

      // Add some default preocedures to the database on the "procedures" table
      // Cyclic voltammetry
      await db.insert('procedures', {
        'title': 'Voltametria cíclica',
        'brief_description':
            'Voltametria cíclica com 3 ciclos, varrendo de -1.0V a 1.0V a 0.1V/s, com potencial inicial de 0.0V, no sentido da oxidação.',
        'model_type': 'cyclic_voltammetry',
        'initial_potential': '-1.0',
        'final_potential': '1.0',
        'start_potential': '0.0',
        'scan_rate': '0.1',
        'cycle_count': '3',
        'sweep_direction': 1,
      });
      // Chronoamperometry
      await db.insert('procedures', {
        'title': 'Cronoamperometria',
        'brief_description':
            'Cronoamperometria com duração de 10 segundos, com potencial aplicado de 1.0 V.',
        'model_type': 'chronoamperometry',
        'initial_potential': '0.0',
        'final_potential': '0.0',
        'start_potential': '1.0',
        'scan_rate': '0.05',
        'cycle_count': '10',
        'sweep_direction': 1,
      });

      // Create the results table
      await db.execute('''
        CREATE TABLE results (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          run_id INTEGER,
          procedure_id INTEGER,
          experiment_id INTEGER,
          data TEXT,
          created_time TEXT
        )
      ''');
    },
  );
  return database;
}
