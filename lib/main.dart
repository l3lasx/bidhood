import 'package:bidhood/pages/finduser.dart';
import 'package:bidhood/pages/login.dart';
import 'package:bidhood/pages/percel.dart';
import 'package:bidhood/pages/profile.dart';
import 'package:bidhood/pages/register.dart';
import 'package:bidhood/pages/send.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  initialLocation: '/login',
  routes: <RouteBase>[
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
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return ScaffoldWithNavBar(child: child);
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/percel',
          builder: (BuildContext context, GoRouterState state) {
            return const PercelPage();
          },
        ),
        GoRoute(
          path: '/send',
          builder: (BuildContext context, GoRouterState state) {
            return const SendPage();
          },
        ),
        GoRoute(
          path: '/user',
          builder: (BuildContext context, GoRouterState state) {
            return Container(
              child: const Text("home"),
            );
          },
        ),
        GoRoute(
          path: '/profile',
          builder: (BuildContext context, GoRouterState state) {
            return const ProfilePage();
          },
        ),
        GoRoute(
          path: '/finduser',
          builder: (BuildContext context, GoRouterState state) {
            return const FindUserPage();
          },
        ),
      ],
    ),
  ],
);

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({Key? key, required this.child}) : super(key: key);
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
          ),
        ),
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/percel')) return 0;
    if (location.startsWith('/send')) return 1;
    if (location.startsWith('/user')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/percel');
        break;
      case 1:
        GoRouter.of(context).go('/send');
        break;
      case 2:
        GoRouter.of(context).go('/user');
        break;
      case 3:
        GoRouter.of(context).go('/profile');
        break;
    }
  }
}

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.local_shipping, 'Percel', 0),
          _buildNavItem(Icons.send, 'Send', 1),
          _buildNavItem(Icons.home, 'Home', 2),
          _buildNavItem(Icons.person, 'Profile', 3),
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
        child: Container(
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.black,
                size: isSelected ? 26 : 22,
              ),
              if (isSelected)
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.black,
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'Flutter Demo',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          iconTheme: IconThemeData(color: Colors.white),
        ),
        textTheme: GoogleFonts.promptTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }
}
