import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/task_provider.dart';
import 'screens/home_screen.dart';
import 'utils/constants.dart';
import 'services/widget_service.dart';

class StreakoApp extends StatelessWidget {
  const StreakoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TaskProvider(),
      child: Consumer<TaskProvider>(
        builder: (context, provider, child) {
          // Initialize native home screen widget channel
          WidgetService.initialize(provider);

          return MaterialApp(
            title: 'StreakO',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getLightTheme(),
            darkTheme: AppTheme.getDarkTheme(),
            themeMode: provider.themeMode,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
