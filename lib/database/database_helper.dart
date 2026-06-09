import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/bill_record.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('electricity_bills.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE bills (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        month TEXT NOT NULL,
        units REAL NOT NULL,
        totalCharges REAL NOT NULL,
        rebatePercent REAL NOT NULL,
        finalCost REAL NOT NULL
      )
    ''');
  }

  Future<int> insertBill(BillRecord record) async {
    final db = await database;
    return await db.insert('bills', record.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<BillRecord>> getAllBills() async {
    final db = await database;
    final maps = await db.query('bills', orderBy: 'id DESC');
    return maps.map((m) => BillRecord.fromMap(m)).toList();
  }

  Future<BillRecord?> getBillById(int id) async {
    final db = await database;
    final maps = await db.query('bills', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return BillRecord.fromMap(maps.first);
  }

  Future<int> updateBill(BillRecord record) async {
    final db = await database;
    return await db.update(
      'bills',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<int> deleteBill(int id) async {
    final db = await database;
    return await db.delete('bills', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}