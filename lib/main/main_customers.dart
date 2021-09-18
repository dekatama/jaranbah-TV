import 'package:jarambahtv/app_config.dart';
import 'package:jarambahtv/main/main_common.dart';
import 'package:jarambahtv/theme/theme.dart';
import 'package:flutter/material.dart';

void main() async {
  await mainCommon();
  final configuredApp =
      AppConfig(buildType: BuildType.PROD, child: Theming(child: MyApp()));
  runApp(configuredApp);
}
