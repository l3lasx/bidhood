// ignore_for_file: unused_local_variable
import 'package:bidhood/pages/realtime.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dropdown_alert/dropdown_alert.dart';
import 'firebase_options.dart';
import 'package:bidhood/pages/finduser.dart';
import 'package:bidhood/pages/login.dart';
import 'package:bidhood/pages/onboarding.dart';
import 'package:bidhood/pages/parcel.dart';
import 'package:bidhood/pages/profile.dart';
import 'package:bidhood/pages/register.dart';
import 'package:bidhood/pages/send.dart';
import 'package:bidhood/pages/senditem.dart';
import 'package:bidhood/pages/tasklist.dart';
import 'package:bidhood/providers/auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bidhood/pages/homerider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(
    child: MyApp(),
  ));
}

final GoRouter router = GoRouter(
  initialLocation: '/onboarding',
  errorBuilder: (BuildContext context, GoRouterState state) {
    return const LoginPage();
  },
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const LoginPage();
      },
    ),
    GoRoute(
      path: '/realtime',
      builder: (BuildContext context, GoRouterState state) {
        final extraData =
            state.extra as Map<String, dynamic>?; // Added null check
        return RealTimePage(
          transactionID: extraData?['transactionID'], // Use null-aware operator
        );
      },
    ),
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) {
        return const LoginPage();
      },
    ),
    GoRoute(
      path: '/register',
      builder: (BuildContext context, GoRouterState state) {
        return const RegisterPage();
      },
    ),
    GoRoute(
        path: '/onboarding',
        builder: (BuildContext context, GoRouterState state) {
          return const OnboardingPage();
        }),
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return ScaffoldWithNavBar(child: child);
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/parcel',
          builder: (BuildContext context, GoRouterState state) {
            return const ParcelPage();
          },
        ),
        GoRoute(
          path: '/send',
          builder: (BuildContext context, GoRouterState state) {
            return const SendPage();
          },
          routes: [
            GoRoute(
              path: 'finduser',
              builder: (BuildContext context, GoRouterState state) {
                return const FindUserPage();
              },
              routes: [
                GoRoute(
                  path: 'senditem',
                  builder: (BuildContext context, GoRouterState state) {
                    return SendItemPage(
                        user: state.extra as Map<String, dynamic>);
                  },
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/profile',
          builder: (BuildContext context, GoRouterState state) {
            return const ProfilePage();
          },
        ),
      ],
    ),
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return ScaffoldWithNavBarRider(child: child);
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/tasklist',
          builder: (BuildContext context, GoRouterState state) {
            return const TaskListPage();
          },
        ),
        GoRoute(
          path: '/homerider',
          builder: (BuildContext context, GoRouterState state) {
            return const HomeRiderPage();
          },
        ),
        GoRoute(
          path: '/profilerider',
          builder: (BuildContext context, GoRouterState state) {
            return const ProfilePage();
          },
        ),
      ],
    )
  ],
);

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({super.key, required this.child});
  final Widget child;
  final Color mainColor = const Color(0xFF0A9830);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: SafeArea(
          child: CustomBottomNavigationBar(
            currentIndex: _calculateSelectedIndex(context),
            onTap: (int idx) => _onItemTapped(idx, context),
            isRider: false,
          ),
        ),
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/parcel')) return 0;
    if (location.startsWith('/send') || location.startsWith('/send/finduser'))
      return 1;
    if (location.startsWith('/profile')) return 2;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/parcel');
        break;
      case 1:
        GoRouter.of(context).go('/send');
        break;
      case 2:
        GoRouter.of(context).go('/profile');
        break;
    }
  }
}

class ScaffoldWithNavBarRider extends StatelessWidget {
  const ScaffoldWithNavBarRider({Key? key, required this.child})
      : super(key: key);
  final Widget child;
  final Color mainColor = const Color(0xFF0A9830);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: SafeArea(
          child: CustomBottomNavigationBar(
            currentIndex: _calculateSelectedIndex(context),
            onTap: (int idx) => _onItemTapped(idx, context),
            isRider: true,
          ),
        ),
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/tasklist')) return 0;
    if (location.startsWith('/homerider')) return 1;
    if (location.startsWith('/profilerider')) return 2;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/tasklist');
        break;
      case 1:
        GoRouter.of(context).go('/homerider');
        break;
      case 2:
        GoRouter.of(context).go('/profilerider');
        break;
    }
  }
}

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isRider;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.isRider,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          if (isRider) ...[
            _buildNavItem(Icons.list_alt, 'Task List', 0),
            _buildNavItem(Icons.home, 'Home', 1),
            _buildNavItem(Icons.person, 'Profile', 2),
          ] else ...[
            _buildNavItem(Icons.local_shipping, 'Parcel', 0),
            _buildNavItem(Icons.send, 'Send', 1),
            _buildNavItem(Icons.person, 'Profile', 2),
          ],
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFF0A9830) : Colors.black,
                size: isSelected ? 26 : 22,
              ),
              if (isSelected)
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF0A9830),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyApp extends ConsumerStatefulWidget {
  // Change to StatefulWidget
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState(); // Create state
}

class _MyAppState extends ConsumerState<MyApp> {
  // New state class

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).loadAuthState(ref);
    });
  }

  @override
  void dispose() {
    super.dispose();
    router.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false, // เพิ่มบรรทัดนี้
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          iconTheme: IconThemeData(color: Colors.white),
        ),
        textTheme: GoogleFonts.promptTextTheme(),
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 87, 183, 58)),
        useMaterial3: true,
      ),
      builder: (context, child) => Stack(
        children: [child!, const DropdownAlert()],
      ),
    );
  }
}
