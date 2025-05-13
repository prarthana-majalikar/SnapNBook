import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TechnicianScaffold extends StatelessWidget {
  final Widget child;

  const TechnicianScaffold({super.key, required this.child});

  static const tabs = [
    '/technician-home',
    '/technician-jobs',
    '/technician-profile',
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    int currentIndex = tabs.indexWhere((t) => location.startsWith(t));
    if (currentIndex == -1) currentIndex = 0;

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          context.go(tabs[index]);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: 'Current Jobs',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'All Jobs'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
