import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/lists_provider.dart';
import 'providers/items_provider.dart';
import 'screens/welcome/welcome_screen.dart';
import 'screens/signin/signin_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/home/home_screen.dart';
import 'utils/theme/app_theme.dart';
import 'utils/constants/strings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OrganizerApp());
}

class OrganizerApp extends StatelessWidget {
  const OrganizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ListsProvider()),
        ChangeNotifierProvider(create: (_) => ItemsProvider()),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        theme: AppTheme.lightTheme(),
        debugShowCheckedModeBanner: false,
        home: const WelcomeScreen(),
        routes: {
          '/welcome': (context) => const WelcomeScreen(),
          '/signin': (context) => const SignInScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}
