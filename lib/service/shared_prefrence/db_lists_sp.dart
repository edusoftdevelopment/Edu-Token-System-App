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
    final List<Map<String, dynamic>> listOfMaps = dbLists
        .map((e) => e.toJson())
        .toList();

    final String jsonString = jsonEncode(listOfMaps);

    await prefs.setString(kDbListsPrefKey, jsonString);
  }

  // Load function
  Future<List<DbListsModel>> loadDbListsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(kDbListsPrefKey);

    if (jsonString == null || jsonString.isEmpty) {
      return <DbListsModel>[];
    }

    final List<dynamic> decoded =
        jsonDecode(jsonString as String) as List<dynamic>;
    final List<DbListsModel> dbLists = decoded
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
