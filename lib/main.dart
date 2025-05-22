// Updated main.dart without FCM push handling logic
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'routes/app_router.dart';
import 'core/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // // Stripe configuration
  // Stripe.publishableKey = 'pk_test_51OXXXXX...'; // 🔑 Replace with your Stripe **Publishable Key**
  // await Stripe.instance.applySettings();

  runApp(const ProviderScope(child: SnapNBookApp()));
}

class SnapNBookApp extends StatelessWidget {
  const SnapNBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SnapNBook',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      routerConfig: AppRouter.router,
    );
  }
}
