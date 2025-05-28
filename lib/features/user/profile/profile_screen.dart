import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../state/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/avatar_placeholder.png'),
            ),
            const SizedBox(height: 16),
            Text(
              session != null
                  ? '${session.firstName} ${session.lastName}'
                  : 'User',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              session?.email ?? '',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              session?.mobile ?? '',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),

            // Role-based bookings tile
            session?.isTechnician == true
                ? Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.assignment_turned_in),
                      title: const Text("Assigned Jobs"),
                      onTap: () => context.push('/assigned-jobs'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.history),
                      title: const Text("Service History"),
                      onTap: () => context.push('/technician-all-jobs'),
                    ),
                  ],
                )
                : ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text("My Bookings"),
                  onTap: () => context.push('/bookings'),
                ),

            // const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () => context.push('/edit-profile'),
            ),
            // const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () {
                ref.read(authProvider.notifier).state = null;
                context.go('/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}
