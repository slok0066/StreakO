import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/constants.dart';
import 'core/theme.dart';
import 'providers/habit_provider.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'services/widget_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init database (Hive — works on web + mobile)
  final databaseService = DatabaseService();
  await databaseService.init();

  // Init other services (platform-gated internally)
  await NotificationService.init();
  await WidgetService.init();

  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding =
      prefs.getBool(AppConstants.onboardingKey) ?? false;

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(databaseService),
      ],
      child: MyApp(hasSeenOnboarding: hasSeenOnboarding),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  final bool hasSeenOnboarding;
  const MyApp({super.key, required this.hasSeenOnboarding});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // Keep home widget in sync with habit state
    Future.microtask(() {
      ref.listenManual(habitStreamProvider, (_, next) {
        next.whenData((habits) => WidgetService.updateWidgetData(habits));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: widget.hasSeenOnboarding
          ? const HomeScreen()
          : const OnboardingScreen(),
    );
  }
}
