import 'package:jarambahtv/app_config.dart';
import 'package:jarambahtv/main/main_common.dart';
import 'package:jarambahtv/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:jarambahtv/ads_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AdManager.initialize();
  await mainCommon();
  final configuredApp =
      AppConfig(buildType: BuildType.DEV, child: Theming(child: MyApp()));
  runApp(configuredApp);
}
