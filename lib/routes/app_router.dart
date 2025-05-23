import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/confirm_signup_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/signup_screen.dart';
import '../features/technician/jobs/accepted_jobs.dart';
import '../features/technician/jobs/all_jobs.dart';
import '../features/technician/jobs/assigned_jobs.dart';
import '../features/technician/jobs/job_details.dart';
import '../features/user/booking/appliance_selection_screen.dart';
import '../features/user/booking/booking_detail_screen.dart';
import '../features/user/booking/booking_list_screen.dart';
import '../features/user/booking/booking_screen.dart';
import '../features/user/booking/confirmation_page.dart';
import '../features/user/booking/payment_screen.dart';
import '../features/user/home/home_screen.dart';
import '../features/user/home/category_item_list_screen.dart';
import '../features/user/profile/profile_screen.dart';
import '../features/user/profile/edit_profile_screen.dart';
import '../features/user/tracking/booking_tracking_screen.dart';
import '../shared/layout/technician_scaffold.dart';
import '../shared/layout/user_scaffold.dart';
import '../state/auth_provider.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    redirect: (context, state) {
      final container = ProviderScope.containerOf(context);
      final session = container.read(authProvider);
      final path = state.uri.path;
      final isPublicPage =
          path == '/login' || path == '/signup' || path.startsWith('/confirm');

      if (session == null && !isPublicPage) return '/login';

      if (session != null && (path == '/login' || path == '/signup')) {
        return session.isTechnician ? '/technician-all-jobs' : '/';
      }
      return null;
    },
    routes: [
      // ✅ USER SHELL ROUTES
      ShellRoute(
        builder: (context, state, child) => UserScaffold(child: child),
        routes: [
          GoRoute(path: '/', builder: (context, state) => HomeScreen()),
          GoRoute(
            path: '/bookings',
            builder: (context, state) => const BookingListScreen(),
          ),
          GoRoute(
            path: '/booking/:id',
            name: 'bookingDetail',
            builder: (context, state) {
              final booking = state.extra as Map<String, dynamic>;
              return BookingDetailScreen(booking: booking);
            },
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // ✅ PUBLIC ROUTES
      GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
      GoRoute(path: '/signup', builder: (context, state) => SignupScreen()),
      GoRoute(
        path: '/confirm',
        builder: (context, state) {
          final role = state.uri.queryParameters['role'] ?? 'user';
          return ConfirmSignupScreen(role: role);
        },
      ),

      // ✅ BOOKING FLOW
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
        builder:
            (context, state) => ConfirmationPage(
              bookingId: state.pathParameters['bookingId'] ?? 'unknown',
            ),
      ),
      GoRoute(
        path: '/payment/:bookingId/:amount',
        builder: (context, state) {
          final bookingId = state.pathParameters['bookingId']!;
          final amount = state.pathParameters['amount']!;
          return PaymentScreen(bookingId: bookingId, amount: amount);
        },
      ),
      GoRoute(
        path: '/category/:categoryName',
        builder: (context, state) {
          final categoryName = state.pathParameters['categoryName']!;
          return CategoryItemListScreen(categoryName: categoryName);
        },
      ),

      // ✅ TECHNICIAN SHELL ROUTES
      ShellRoute(
        builder: (context, state, child) => TechnicianScaffold(child: child),
        routes: [
          GoRoute(
            path: '/technician-home',
            builder: (context, state) {
              final session = ProviderScope.containerOf(
                context,
              ).read(authProvider);
              return AcceptedJobsScreen(technicianId: session?.userId ?? '');
            },
          ),
          GoRoute(
            path: '/technician-all-jobs',
            builder: (context, state) {
              final session = ProviderScope.containerOf(
                context,
              ).read(authProvider);
              return TechnicianAllJobsScreen(
                technicianId: session?.userId ?? '',
              );
            },
          ),
          GoRoute(
            path: '/assigned-jobs',
            builder: (context, state) {
              final session = ProviderScope.containerOf(
                context,
              ).read(authProvider);
              return AssignedJobsScreen(technicianId: session?.userId ?? '');
            },
          ),
          GoRoute(
            path: '/accepted-jobs',
            builder: (context, state) {
              final session = ProviderScope.containerOf(
                context,
              ).read(authProvider);
              return AcceptedJobsScreen(technicianId: session?.userId ?? '');
            },
          ),
          GoRoute(
            path: '/technician-profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/job-details',
            builder: (context, state) {
              final job = state.extra as Map<String, dynamic>;
              return JobDetailsScreen(job: job);
            },
          ),
        ],
      ),

      // ✅ SHARED ROUTES
      GoRoute(
        path: '/track/:techId',
        builder: (context, state) {
          final techId = state.pathParameters['techId']!;
          return BookingTrackingScreen(technicianId: techId);
        },
      ),

      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
    ],
  );
}
