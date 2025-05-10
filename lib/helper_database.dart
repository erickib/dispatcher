import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pickup_courier.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE pickupCourier (
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
      'pickupCourier',
      pickup,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getPickup({
    String column = '',
    String value = '',
  }) async {
    final db = await instance.database;
    if (column.isNotEmpty) {
      final List<Map<String, dynamic>> maps = await db.query(
        'pickupCourier',
        limit: 1,
        where: "type='pickup' and $column='$value'",
      );
      if (maps.isNotEmpty) {
        return maps.first;
      } else {
        return {};
      }
    } else {
      return {};
    }
  }

  Future<List<String>> getPickups() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pickupCourier',
      where: "type='pickup'",
    );
    if (maps.isNotEmpty) {
      return maps.map((map) => map['name'].toString()).toList();
    } else {
      return [];
    }
  }

  // Future<Map<String, dynamic>?> getPickups() async {
  //   final db = await instance.database;
  //   final List<Map<String, dynamic>> maps = await db.query(
  //     'pickupCourier',
  //     where: "type='pickup'",
  //   );
  //   if (maps.isNotEmpty) {
  //     return maps.first;
  //   } else {
  //     return null;
  //   }
  // }

  //courier
  Future<int> saveCourier(Map<String, dynamic> courier) async {
    final db = await instance.database;
    return await db.insert(
      'pickupCourier',
      courier,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getCourier() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pickupCourier',
      limit: 1,
      where: "type='courier'",
    );
    if (maps.isNotEmpty) {
      return maps.first;
    } else {
      return null;
    }
  }

  Future<List<String>> getCouriers() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pickupCourier',
      where: "type='courier'",
    );
    if (maps.isNotEmpty) {
      return maps.map((map) => map['name'].toString()).toList();
    } else {
      return [];
    }
  }
}
