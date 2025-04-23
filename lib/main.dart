import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'routes/app_router.dart';
import 'core/theme.dart';

void main() {
  runApp(ProviderScope(child: SnapNBookApp()));
}

class SnapNBookApp extends StatelessWidget {
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
