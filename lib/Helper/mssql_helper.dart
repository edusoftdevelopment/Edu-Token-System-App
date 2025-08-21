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

  /// Returns rows as List<Map<String,dynamic>> so callers can use column names.
  Future<List<Map<String, dynamic>>> query(
    String sql, [
    List<dynamic>? params,
  ]) async {
    params ??= [];

    // Replace '?' with parameter names @p0, @p1, ...
    var newSql = sql;
    final paramMap = <String, dynamic>{};
    for (var i = 0; i < params.length; i++) {
      newSql = newSql.replaceFirst('?', '@p$i');
      paramMap['p$i'] = params[i];
    }

    dynamic raw;
    try {
      // Most DB wrappers accept parameters as a second arg/map.
      // Try passing parameters first (recommended).
      raw = await _db.getData(
        newSql,
      );
    } catch (e) {
      // If the wrapper doesn't accept a second argument, fall back to calling without params.
      // This fallback keeps old behavior but will fail for parameterized queries.
      if (kDebugMode)
        print('getData with params failed, trying without params: $e');
      raw = await _db.getData(newSql);
    }

    final rows = <Map<String, dynamic>>[];

    if (raw is List) {
      for (final r in raw) {
        if (r is Map<String, dynamic>) {
          // already a map: columnName -> value
          rows.add(r);
        } else if (r is List) {
          // numeric list returned — create c0,c1... keys (less ideal)
          final map = <String, dynamic>{};
          for (var i = 0; i < r.length; i++) {
            map['c$i'] = r[i];
          }
          rows.add(map);
        } else {
          rows.add({'value': r});
        }
      }
    }

    return rows;
  }

  // Future<List<List<dynamic>>> query(String sql, [List<dynamic>? params]) async {
  //   params ??= [];

  //   var newSql = sql;
  //   final paramMap = <String, dynamic>{};
  //   for (var i = 0; i < params.length; i++) {
  //     newSql = newSql.replaceFirst('?', '@p$i');
  //     paramMap['p$i'] = params[i];
  //   }

  //   final raw = await _db.getData(
  //     newSql,
  //   );

  //   final rows = <List<dynamic>>[];
  //   if (raw is List) {
  //     for (final r in raw as List) {
  //       if (r is Map<String, dynamic>) {
  //         rows.add(r.values.toList());
  //       } else if (r is List) {
  //         rows.add(List<dynamic>.from(r));
  //       } else {
  //         rows.add([r]);
  //       }
  //     }
  //   }
  //   return rows;
  // }
}
