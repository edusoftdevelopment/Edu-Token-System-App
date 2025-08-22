import 'dart:convert';

import 'package:edu_token_system_app/core/model/db_lists_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DbListsSp {
  // key constant
  static const String kDbListsPrefKey = 'db_lists';

  // Save function
  Future<void> saveDbListsToPrefs(List<DbListsModel> dbLists) async {
    final prefs = await SharedPreferences.getInstance();

    // List of Map => encode to json string
    final listOfMaps = dbLists.map((e) => e.toJson()).toList();

    final jsonString = jsonEncode(listOfMaps);

    await prefs.setString(kDbListsPrefKey, jsonString);
  }

  // Load function
  Future<List<DbListsModel>> loadDbListsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(kDbListsPrefKey);

    if (jsonString == null || jsonString.isEmpty) {
      return <DbListsModel>[];
    }

    final decoded = jsonDecode(jsonString) as List<dynamic>;
    final dbLists = decoded
        .map<DbListsModel>(
          (json) => DbListsModel.fromJson(json as Map<String, dynamic>),
        )
        .toList();

    return dbLists;
  }

  // Remove / clear function (agar chahain)
  Future<void> removeDbListsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(kDbListsPrefKey);
  }
}

// // Save karna
// await saveDbListsToPrefs(dbLists);

// // Load karna
// List<DbListsModel> loaded = await loadDbListsFromPrefs();
// print('Loaded ${loaded.length} items');
// for (var d in loaded) {
//   print('${d.defaultDB} -> ${d.alias}');
// }
