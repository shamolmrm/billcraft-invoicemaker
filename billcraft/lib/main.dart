import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:easy_localization/easy_localization.dart';
import 'app.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService().initialize();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'), Locale('bn'), Locale('hi'), Locale('ar'),
        Locale('es'), Locale('fr'), Locale('pt'), Locale('id'),
        Locale('tr'), Locale('de'), Locale('zh'), Locale('ja'),
        Locale('ko'), Locale('ru'), Locale('it'), Locale('ms'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const BillCraftApp(),
    ),
  );
}
