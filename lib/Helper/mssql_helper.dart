import 'package:flutter/foundation.dart';
import 'package:mssql_connection/mssql_connection.dart';

class MssqlHelper {
  final _db = MssqlConnection.getInstance();

  Future<void> connect({
    required String ip,
    required String port,
    required String username,
    required String password,
    required String databaseName,
  }) async {
    await _db.connect(
      ip: ip,
      port: port,
      username: username,
      password: password,
      databaseName: databaseName,
    );
  }

  Future<void> close() async {
    await _db.disconnect();
  }

  /// Returns result as String so callers can use column names.
  Future<String> query({required String queryStrig}) async {
    return _db.getData(
      queryStrig, // Replace with your actual query
    );
  }

  Future<bool> isConnected() async {
    return _db.isConnected;
  }
}
