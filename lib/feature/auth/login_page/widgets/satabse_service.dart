// import 'package:mysql1/mysql1.dart';

// class DatabaseService {
//   static Future<MySqlConnection> createConnection({
//     required String dbName,
//   }) async {
//     final settings = ConnectionSettings(
//       host: "localhost",   // ya server IP
//       port: 3306,
//       user: "root",
//       password: "password",
//       db: dbName,
//     );
//     return await MySqlConnection.connect(settings);
//   }

//   static Future<void> login(String appCodeName, String imeiNo) async {
//     // Step 1: Connect to Main DB
//     var conn = await createConnection(dbName: "LoginMainDB");

//     // Step 2: Get DefaultDB, Alias
//     var results = await conn.query(
//       "SELECT DefaultDB, Alias FROM gen_SingleConnections WHERE ApplicationCodeName = ?",
//       [appCodeName],
//     );

//     if (results.isNotEmpty) {
//       var row = results.first;
//       String defaultDb = row[0];
//       String alias = row[1];
//       print("Default DB: $defaultDb, Alias: $alias");

//       // Step 3: Connect to DefaultDB
//       var defaultConn = await createConnection(dbName: defaultDb);

//       // Step 4: Check Mobile Serial
//       var imeiResults = await defaultConn.query(
//         "SELECT IMEINO, IFNULL(CashCounterID,0) as CashCounterID "
//         "FROM gen_MobileInformation WHERE Inactive=0 AND IMEINO=?",
//         [imeiNo],
//       );

//       if (imeiResults.isNotEmpty) {
//         var imeiRow = imeiResults.first;
//         print("✅ Login success: IMEINO=${imeiRow[0]}, CashCounterID=${imeiRow[1]}");
//       } else {
//         print("❌ Invalid IMEINO");
//       }

//       await defaultConn.close();
//     }

//     await conn.close();
//   }
// }
