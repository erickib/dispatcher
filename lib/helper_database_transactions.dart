import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelperTransactions {
  static final DatabaseHelperTransactions _instance =
      DatabaseHelperTransactions._internal();
  factory DatabaseHelperTransactions() => _instance;

  DatabaseHelperTransactions._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'transactions.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            pickupPrice REAL,
            courierPrice REAL,
            sentToCourier INTEGER,
            paydToCourier INTEGER,
            datetime TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertTransaction(Map<String, dynamic> transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction);
  }

  Future<List<Map<String, dynamic>>> getTransactions({String? filter}) async {
    final db = await database;
    if (filter == null) {
      return await db.query('transactions');
    } else {
      return await db.query(
        'transactions',
        where: "datetime LIKE ?",
        whereArgs: ['%$filter%'],
      );
    }
  }

  Future<Map<String, double>> getSummary({String? filter}) async {
    final db = await database;
    final results = await db.rawQuery('''
      SELECT SUM(pickupPrice) as totalPickup, SUM(courierPrice) as totalCourier 
      FROM transactions 
      ${filter != null ? "WHERE datetime LIKE ?" : ""}
    ''', filter != null ? ['%$filter%'] : []);

    if (results.isNotEmpty) {
      return {
        'totalPickup': (results.first['totalPickup'] as double?) ?? 0.0,
        'totalCourier': (results.first['totalCourier'] as double?) ?? 0.0,
      };
    }
    return {'totalPickup': 0.0, 'totalCourier': 0.0};
  }
}
