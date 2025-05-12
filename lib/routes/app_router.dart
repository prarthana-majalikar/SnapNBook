import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/home/home_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/signup_screen.dart';
import '../state/auth_provider.dart';
import '../features/booking/appliance_selection_screen.dart';
import '../features/booking/booking_screen.dart';
import '../features/booking/confirmation_page.dart';
import '../shared/layout/main_scaffold.dart';
import '../features/booking/booking_list_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    redirect: (context, state) {
      final container = ProviderScope.containerOf(context);
      final isLoggedIn = container.read(authProvider);
      final isLoggingIn =
          state.fullPath == '/login' || state.fullPath == '/signup';

      if (!isLoggedIn && !isLoggingIn) return '/login';
      if (isLoggedIn && isLoggingIn) return '/';
      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return MainScaffold(child: child); // <-- contains bottom nav bar
        },
        // Routes that need to display the bottom nav bar should be added here
        routes: [
          GoRoute(path: '/', builder: (context, state) => HomeScreen()),
          GoRoute(
            path: '/bookings',
            builder: (context, state) => const BookingListScreen(),
          ),
        ],
      ),

      // Routes that don't need the bottom nav bar should be added here
      GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
      GoRoute(path: '/signup', builder: (context, state) => SignupScreen()),
      GoRoute(
        path: '/appliance-selection/:detected',
        builder: (context, state) {
          final detected = state.pathParameters['detected'] ?? 'unknown';
          return ApplianceSelectionScreen(detectedObject: detected);
        },
      ),
      GoRoute(path: '/booking', builder: (context, state) => BookingScreen()),
      GoRoute(
        path: '/confirmation',
        builder: (context, state) => const ConfirmationPage(),
      ),
    ],
  );
}
