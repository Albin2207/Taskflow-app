import 'package:sqflite/sqflite.dart';
import '../../models/user_model.dart';
import 'database_helper.dart';

abstract class LocalUserDataSource {
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser(String uid);
  Future<void> deleteUser(String uid);
  Future<bool> userExists(String uid);
}

class LocalUserDataSourceImpl implements LocalUserDataSource {
  final DatabaseHelper _databaseHelper;

  LocalUserDataSourceImpl(this._databaseHelper);

  @override
  Future<void> saveUser(UserModel user) async {
    final db = await _databaseHelper.database;
    await db.insert(
      DatabaseHelper.tableUsers,
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<UserModel?> getUser(String uid) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableUsers,
      where: 'uid = ?',
      whereArgs: [uid],
    );

    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<void> deleteUser(String uid) async {
    final db = await _databaseHelper.database;
    await db.delete(
      DatabaseHelper.tableUsers,
      where: 'uid = ?',
      whereArgs: [uid],
    );
  }

  @override
  Future<bool> userExists(String uid) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableUsers,
      where: 'uid = ?',
      whereArgs: [uid],
    );
    return maps.isNotEmpty;
  }
}