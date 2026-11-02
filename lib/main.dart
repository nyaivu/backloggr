import 'package:backloggr/ui/screens/home_screen.dart';
import 'package:backloggr/ui/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:backloggr/core/theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

Future<void> main() async {
  // 1. Ensure Flutter bindings are initialized before calling native code
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Load the .env file
  await dotenv.load(fileName: ".env");

  // 3. Initialize Supabase using your environment variables
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    publishableKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const MyApp());
}

// 4. Configure GoRouter
final GoRouter _router = GoRouter(
  initialLocation: '/',
  // This redirect acts as our Authentication Guard
  redirect: (context, state) {
    // Check Supabase to see if a user is currently logged in
    final session = Supabase.instance.client.auth.currentSession;
    final isLoggedIn = session != null;

    // Check if the user is currently trying to navigate to the login page
    final isGoingToLogin = state.matchedLocation == '/login';

    // If they are NOT logged in, and NOT going to the login page, force them to login
    if (!isLoggedIn && !isGoingToLogin) {
      return '/login';
    }

    // If they ARE logged in, but trying to go to the login page, force them home
    if (isLoggedIn && isGoingToLogin) {
      return '/';
    }

    // Otherwise, let them go to their intended destination
    return null;
  },
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Backloggr',
      theme: AppTheme.lightTheme,
      routerConfig: _router,
    );
  }
}
