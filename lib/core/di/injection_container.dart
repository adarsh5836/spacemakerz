import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_client.dart';
import '../storage/local_storage.dart';
import '../../app/services/json_storage_service.dart';
import '../../app/services/seed_data_service.dart';
import '../../app/repositories/auth_repository.dart';
import '../../app/repositories/tasks_repository.dart';
import '../../app/repositories/projects_repository.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ── Shared Preferences ──────────────────────────────────────────────────
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => prefs);

  // ── Core Storage ────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => LocalStorage(sl()));

  // ── Core Network ────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => ApiClient(baseUrl: 'http://72.61.229.236/api'));

  // ── App Services ────────────────────────────────────────────────────────
  sl.registerLazySingleton<JsonStorageService>(() => JsonStorageService());
  sl.registerLazySingleton<SeedDataService>(
      () => SeedDataService(sl<JsonStorageService>()));

  // ── App Repositories ────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRepository>(
      () => AuthRepository(sl<ApiClient>(), sl<LocalStorage>()));
  sl.registerLazySingleton<TasksRepository>(
      () => TasksRepository(sl<JsonStorageService>(), sl<LocalStorage>(), sl<ApiClient>()));
  sl.registerLazySingleton<ProjectsRepository>(
      () => ProjectsRepository(sl<ApiClient>(), sl<LocalStorage>()));
}
