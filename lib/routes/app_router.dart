import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snapnbook/features/technician/jobs/job_details.dart';
import '../features/user/home/home_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/signup_screen.dart';
import '../state/auth_provider.dart';
import '../features/user/booking/appliance_selection_screen.dart';
import '../features/user/booking/booking_screen.dart';
import '../features/user/booking/confirmation_page.dart';
import '../shared/layout/user_scaffold.dart';
import '../features/user/booking/booking_list_screen.dart';
import '../features/user/profile/profile_screen.dart';
import '../features/technician/home/home_screen.dart';
import '../features/auth/confirm_signup_screen.dart';
import '../features/user/booking/booking_detail_screen.dart';
import '../shared/layout/technician_scaffold.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    redirect: (context, state) {
      final container = ProviderScope.containerOf(context);
      final session = container.read(authProvider);
      final path = state.uri.path;
      final isPublicPage =
          path == '/login' || path == '/signup' || path.startsWith('/confirm');

      // 🔒 Not logged in, trying to access protected page
      if (session == null && !isPublicPage) return '/login';

      // 🔁 Already logged in, prevent access to login/signup
      if (session != null && (path == '/login' || path == '/signup')) {
        return session.isTechnician ? '/technician-home' : '/';
      }
      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return UserScaffold(child: child); // <-- contains bottom nav bar
        },
        // Routes that need to display the bottom nav bar should be added here
        routes: [
          GoRoute(path: '/', builder: (context, state) => HomeScreen()),
          GoRoute(
            path: '/bookings',
            builder: (context, state) => const BookingListScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // Routes that don't need the bottom nav bar should be added here
      GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
      GoRoute(path: '/signup', builder: (context, state) => SignupScreen()),
      GoRoute(
        path: '/confirm',
        builder: (context, state) => ConfirmSignupScreen(),
      ),
      GoRoute(
        path: '/appliance-selection/:detected',
        builder: (context, state) {
          final detected = state.pathParameters['detected'] ?? 'unknown';
          return ApplianceSelectionScreen(detectedObject: detected);
        },
      ),
      GoRoute(path: '/booking', builder: (context, state) => BookingScreen()),
      GoRoute(
        path: '/confirmation/:bookingId',
        builder: (context, state) {
          return ConfirmationPage(
            bookingId: state.pathParameters['bookingId'] ?? 'unknown',
          );
        },
      ),
      GoRoute(
        path: '/booking/:id',
        name: 'bookingDetail',
        builder: (context, state) {
          final booking = state.extra as Map<String, dynamic>;
          return BookingDetailScreen(booking: booking);
        },
      ),

      // ------------------------------Technician Routes-------------------------------------------------
      ShellRoute(
        builder: (context, state, child) {
          return TechnicianScaffold(
            child: child,
          ); // <-- contains bottom nav bar
        },
        // Routes that need to display the bottom nav bar should be added here
        routes: [
          GoRoute(
            path: '/technician-home',
            builder: (context, state) => TechnicianHomeScreen(),
          ),
          GoRoute(
            path: '/technician-jobs',
            builder: (context, state) => TechnicianHomeScreen(),
          ),
          GoRoute(
            path: '/technician-profile',
            builder: (context, state) => ProfileScreen(),
          ),
        ],
      ),

      GoRoute(
        path: '/job-details',
        builder: (context, state) {
          final job = state.extra as Map<String, dynamic>;
          return JobDetailsScreen(job: job);
        },
      ),
    ],
  );
}
