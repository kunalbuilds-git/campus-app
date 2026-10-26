import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import 'client.dart';
import 'screens/assignments_screen.dart';
import 'screens/attendance_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/clubs_screen.dart';
import 'screens/events_screen.dart';
import 'screens/landing_screen.dart';
import 'screens/notice_board_screen.dart';
import 'screens/profile_screen.dart';
import 'theme/brand.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Browser smoke testing: `?sem=1` exposes the widget tree as real DOM
  // (Flutter semantics), so automated reads see labels instead of pixels.
  if (Uri.base.queryParameters['sem'] == '1') {
    SemanticsBinding.instance.ensureSemantics();
  }
  await initializeClient();
  runApp(const CampHereApp());
}

/// The CampHere app: a campus events feed, a finder you can talk to, and a
/// profile that keeps track of what you said yes to.
class CampHereApp extends StatelessWidget {
  const CampHereApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CampHere — campus events',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Brand.paper,
        fontFamily: Brand.text,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Brand.ember,
          brightness: Brightness.light,
        ),
      ),
      onGenerateRoute: (settings) {
        // A quick fade-through with a soft rise, eased like a GSAP
        // power3.out, so moving between surfaces feels like one app.
        return PageRouteBuilder(
          settings: settings,
          transitionDuration: const Duration(milliseconds: 460),
          reverseTransitionDuration: const Duration(milliseconds: 360),
          pageBuilder: (context, animation, secondaryAnimation) {
            switch (settings.name) {
              case '/chat':
                return const ChatScreen();
              case '/profile':
                return const ProfileScreen();
              case '/notices':
                return const NoticeBoardScreen();
              case '/events':
                return const EventsScreen();
              case '/assignments':
                return const AssignmentsScreen();
              case '/clubs':
                return const ClubsScreen();
              case '/attendance':
                return const AttendanceScreen();
              default:
                return const LandingScreen();
            }
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween(
                  begin: const Offset(0, 0.02),
                  end: Offset.zero,
                ).animate(curved),
                child: ScaleTransition(
                  scale: Tween(begin: 0.988, end: 1.0).animate(curved),
                  child: child,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
