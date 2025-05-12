import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // In a real app, you'd get user data from authProvider
    final dummyUser = {
      "name": "John Doe",
      "email": "john.doe@example.com",
      "phone": "+1 234 567 890",
    };

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
              dummyUser['name']!,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              dummyUser['email']!,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              dummyUser['phone']!,
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 32),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text("My Bookings"),
              onTap: () => context.push('/bookings'),
            ),
            const Divider(),

            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () {}, // Later
            ),
            const Divider(),

            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () {
                // TODO: Implement logout
              },
            ),
          ],
        ),
      ),
    );
  }
}
