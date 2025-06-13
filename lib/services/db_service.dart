import 'package:path/path.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

class DBService {
  static Database? _db;

  static Future<Database> openDb(String path, String key) async {
    if (_db != null) return _db!;
    _db = await openDatabase(path,
      password: key,
      onCreate: (db, v) async {
        await db.execute('''
          CREATE TABLE contrasenas(
            id INTEGER PRIMARY KEY,
            sitio TEXT,
            usuario TEXT,
            contrasena BLOB
          )
        ''');
      },
      version: 1,
    );
    return _db!;
  }
}
