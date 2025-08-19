import 'dart:developer';

import 'package:edu_token_system_app/Export/export.dart';
import 'package:edu_token_system_app/core/keys/edu_token_system_app_key.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
//! Function to initialize the app with necessary settings

dynamic initialization() async {
 WidgetsFlutterBinding.ensureInitialized();
  //! Set the preferred screen orientation to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  //! Setup Secret Key Environment
  await dotenv.load(fileName: dotEnvPath);
  if (kDebugMode) log('DotENV:  ${dotenv.env}');
}
