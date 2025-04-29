import 'package:flutter/material.dart';
import 'package:platform_commons_task/app.dart';
import 'package:platform_commons_task/config/locator.dart';
import 'package:platform_commons_task/providers/movie_provider.dart';
import 'package:platform_commons_task/providers/user_provider.dart';
import 'package:platform_commons_task/service/database_service.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

   await LocatorInjector.setUpLocator();

  final databaseService = locator<DatabaseService>();
  await databaseService.initDatabase();

  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );

  Workmanager().registerPeriodicTask(
    "syncUsers",
    "syncOfflineUsers",
    frequency: Duration(hours: 1),
    constraints: Constraints(
      networkType: NetworkType.connected,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider(databaseService)),
        ChangeNotifierProvider(create: (_) => MovieProvider(databaseService)),
      ],
      child: MyApp(),
    ),
  );
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == "syncOfflineUsers") {
      final databaseService = DatabaseService();
      await databaseService.initDatabase();
      await databaseService.syncOfflineUsers();
    }
    return Future.value(true);
  });
}
