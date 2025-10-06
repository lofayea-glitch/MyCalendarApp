import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hijri/hijri_calendar.dart';
import 'dart:async';

import 'models/event.dart';
import 'screens/home.dart';
import 'services/notification_service.dart';
import 'services/theme_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(EventAdapter());
  await Hive.openBox('events');
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('isDark') ?? false;
  await NotificationService().init();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeService(isDark ? ThemeMode.dark : ThemeMode.light),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeSrv = Provider.of<ThemeService>(context);
    return MaterialApp(
      title: 'My Calendar App',
      themeMode: themeSrv.mode,
      theme: ThemeData.light().copyWith(
        useMaterial3: true,
        primaryColor: Colors.teal,
      ),
      darkTheme: ThemeData.dark().copyWith(
        useMaterial3: true,
        primaryColor: Colors.teal,
      ),
      home: HomeScreen(),
    );
  }
}
