import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/theme.dart';
import 'core/controllers/theme_controller.dart';
import 'modules/splash/views/splash_screen.dart';
import 'modules/notification/services/notification_service.dart';
import 'modules/dashboard/controllers/dashboard_controller.dart';
import 'modules/task/controllers/add_task_controller.dart';
import 'modules/task/controllers/edit_task_controller.dart';
import 'modules/task/controllers/task_detail_controller.dart';
import 'modules/notification/controllers/notification_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => DashboardController()),
        ChangeNotifierProvider(create: (_) => AddTaskController()),
        ChangeNotifierProvider(create: (_) => EditTaskController()),
        ChangeNotifierProvider(create: (_) => TaskDetailController()),
        ChangeNotifierProvider(create: (_) => NotificationController()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeController>();

    return MaterialApp(
      title: 'TaskFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const SplashScreen(),
    );
  }
}