import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' hide Transition;
import 'package:get/get.dart';

import 'constants/app_theme.dart';
import 'core/di/injection_container.dart' as di;
import 'routes/app_router.dart';
import 'routes/route_names.dart';
import 'features/home/cubit/home_cubit.dart';
import 'app/repositories/auth_repository.dart';
import 'app/repositories/tasks_repository.dart';
import 'app/repositories/projects_repository.dart';
import 'core/storage/local_storage.dart';
import 'app/services/seed_data_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Wire up DI
  await di.init();

  // 2. Seed local JSON on first launch
  await di.sl<SeedDataService>().seed();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        // Make repositories available via context.read<>()
        RepositoryProvider<AuthRepository>(
          create: (_) => di.sl<AuthRepository>(),
        ),
        RepositoryProvider<TasksRepository>(
          create: (_) => di.sl<TasksRepository>(),
        ),
        RepositoryProvider<ProjectsRepository>(
          create: (_) => di.sl<ProjectsRepository>(),
        ),
        RepositoryProvider<LocalStorage>(
          create: (_) => di.sl<LocalStorage>(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [BlocProvider<HomeCubit>(create: (_) => HomeCubit())],
        child: GetMaterialApp(
          title: 'Spacemakerz',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          initialRoute: RouteNames.splash,
          getPages: AppRouter.routes,
          defaultTransition: Transition.cupertino,
        ),
      ),
    );
  }
}
