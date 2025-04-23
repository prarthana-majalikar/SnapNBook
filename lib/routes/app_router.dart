import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/home/home_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/signup_screen.dart';
import '../state/auth_provider.dart';

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
      GoRoute(path: '/', builder: (context, state) => HomeScreen()),
      GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
      GoRoute(path: '/signup', builder: (context, state) => SignupScreen()),
    ],
  );
}
