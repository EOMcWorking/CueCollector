import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/main/main_screen.dart';
import 'screens/person/person_detail_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/data_provider.dart';
import 'services/database_service.dart';
import 'services/floating_window_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.instance.initDatabase();
  runApp(const CueCollectorApp());
}

class CueCollectorApp extends StatefulWidget {
  const CueCollectorApp({super.key});

  @override
  State<CueCollectorApp> createState() => _CueCollectorAppState();
}

class _CueCollectorAppState extends State<CueCollectorApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // App is going to background, show floating window
        FloatingWindowService.showFloatingWindow();
        break;
      case AppLifecycleState.resumed:
        // App is coming back to foreground, hide floating window
        FloatingWindowService.hideFloatingWindow();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DataProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp.router(
            title: 'Cue Collector',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              useMaterial3: true,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                elevation: 2,
              ),
            ),
            routerConfig: _createRouter(authProvider.isAuthenticated),
          );
        },
      ),
    );
  }

  GoRouter _createRouter(bool isAuthenticated) {
    return GoRouter(
      initialLocation: isAuthenticated ? '/main' : '/auth',
      routes: [
        GoRoute(
          path: '/auth',
          builder: (context, state) => const AuthScreen(),
        ),
        GoRoute(
          path: '/main',
          builder: (context, state) => const MainScreen(),
        ),
        GoRoute(
          path: '/person/:id',
          builder: (context, state) {
            final personId = state.pathParameters['id']!;
            return PersonDetailScreen(personId: personId);
          },
        ),
      ],
      redirect: (context, state) {
        final isAuth = isAuthenticated;
        final isGoingToAuth = state.matchedLocation == '/auth';
        
        if (!isAuth && !isGoingToAuth) return '/auth';
        if (isAuth && isGoingToAuth) return '/main';
        return null;
      },
    );
  }
}
