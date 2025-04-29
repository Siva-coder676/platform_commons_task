import 'package:get_it/get_it.dart';
import 'package:platform_commons_task/service/api_service.dart';
import 'package:platform_commons_task/service/connectivity_service.dart';
import 'package:platform_commons_task/service/database_service.dart';

final GetIt locator = GetIt.instance;

class LocatorInjector {
  static Future<void> setUpLocator() async {
    print("locator injector is initialized");

    locator.registerLazySingleton(() => DatabaseService());
    locator.registerLazySingleton(() => ApiService());
    locator.registerLazySingleton(() => ConnectivityService());
  }
}
