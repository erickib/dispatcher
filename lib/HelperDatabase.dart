import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('PickupCourier.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE PickupCourier (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT,
        name TEXT,
        address TEXT,
        number TEXT,
        complement TEXT,
        phone TEXT,
        notes TEXT
      )
    ''');
  }

  //pickup
  Future<int> savePickup(Map<String, dynamic> pickup) async {
    final db = await instance.database;
    return await db.insert(
      'PickupCourier',
      pickup,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getPickup() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'PickupCourier',
      limit: 1,
      where: "type='pickup'",
    );
    if (maps.isNotEmpty) {
      return maps.first;
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getPickups() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'PickupCourier',
      where: "type='pickup'",
    );
    if (maps.isNotEmpty) {
      return maps.first;
    } else {
      return null;
    }
  }

  //courier
  Future<int> saveCourier(Map<String, dynamic> courier) async {
    final db = await instance.database;
    return await db.insert(
      'PickupCourier',
      courier,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getCourier() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'PickupCourier',
      limit: 1,
      where: "type='courier'",
    );
    if (maps.isNotEmpty) {
      return maps.first;
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getCouriers() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'PickupCourier',
      where: "type='courier'",
    );
    if (maps.isNotEmpty) {
      return maps.first;
    } else {
      return null;
    }
  }
}
