import 'package:backloggr/core/constants.dart';
import 'package:backloggr/data/providers/backlog_notifier.dart';
import 'package:backloggr/ui/screens/backlog_screen.dart';
import 'package:backloggr/ui/screens/backlog_detail_screen.dart';
import 'package:backloggr/ui/screens/home_screen.dart';
import 'package:backloggr/ui/screens/login_screen.dart';
import 'package:backloggr/ui/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:backloggr/core/theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

class AdaptiveNavigationShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AdaptiveNavigationShell({super.key, required this.navigationShell});

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Gunakan LayoutBuilder pada shell aplikasi
    return LayoutBuilder(
      builder: (context, constraints) {
        // Breakpoint Material 3 (840px)
        final isExpanded = constraints.maxWidth >= 840;

        // 3. Tampilkan NavigationRail pada layar expanded (≥ 840px)
        if (isExpanded) {
          return Scaffold(
            body: Row(
              children: [
                SafeArea(
                  child: NavigationRail(
                    selectedIndex: navigationShell.currentIndex,
                    onDestinationSelected: _onDestinationSelected,
                    labelType: NavigationRailLabelType.all,
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.home_outlined),
                        selectedIcon: Icon(Icons.home),
                        label: Text('Home'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.gamepad_outlined),
                        selectedIcon: Icon(Icons.gamepad_sharp),
                        label: Text('Courses'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.person_4_outlined),
                        selectedIcon: Icon(Icons.person_4_sharp),
                        label: Text('Profile'),
                      ),
                    ],
                  ),
                ),
                const VerticalDivider(thickness: 1, width: 1),
                // Halaman tetap terjaga saat layout berubah
                Expanded(child: navigationShell),
              ],
            ),
          );
        }

        // 2. Tampilkan NavigationBar pada layar compact/medium (< 840px)
        return Scaffold(
          body: navigationShell,
          bottomNavigationBar: NavigationBar(
            backgroundColor: AppColors.scaffoldBackground,
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _onDestinationSelected,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined, color: AppColors.steamBlue),
                selectedIcon: Icon(Icons.home, color: AppColors.gray950),
                label: '',
              ),
              NavigationDestination(
                icon: Icon(Icons.gamepad_outlined, color: AppColors.steamBlue),
                selectedIcon: Icon(Icons.gamepad_sharp),
                label: '',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_4_outlined, color: AppColors.steamBlue),
                selectedIcon: Icon(Icons.person_4_sharp),
                label: '',
              ),
            ],
          ),
        );
      },
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    publishableKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BacklogProvider()..loadBacklog()),
      ],
      child: const MyApp(),
    ),
  );
}

// GoRouter
final GoRouter _router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final session = Supabase.instance.client.auth.currentSession;
    final isLoggedIn = session != null;

    final isGoingToLogin = state.matchedLocation == '/login';

    if (!isLoggedIn && !isGoingToLogin) {
      return '/login';
    }

    if (isLoggedIn && isGoingToLogin) {
      return '/';
    }

    return null;
  },
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AdaptiveNavigationShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/backlog',
              builder: (context, state) => const BacklogScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/detail',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;

        return BacklogDetailScreen(id: extra['id'].toString());
      },
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilPlusInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Backloggr',
        theme: AppTheme.darkTheme,
        routerConfig: _router,
      ),
    );
  }
}
