import 'package:edu_token_system_app/app/app.dart';
import 'package:edu_token_system_app/core/helper/function.dart';
import 'package:flutter/material.dart';

void main() async {
  /// [initialization] contains initialization for app
  await initialization();
  // [runApp] contains app
  runApp(const EduTokenSystem());
}

