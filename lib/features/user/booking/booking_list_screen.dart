import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../../shared/widgets/status_badge.dart';
import '../../../../state/auth_provider.dart';

final bookingsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final userSession = ref.watch(authProvider);
  if (userSession == null || userSession.userId.isEmpty) {
    throw Exception('User not logged in');
  }

  final userId = userSession.userId;
  final response = await http.get(
    Uri.parse(
      'https://a8lc7dia7h.execute-api.us-east-1.amazonaws.com/production/user-bookings/$userId',
    ),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    print('[DEBUG] Bookings data: $data');
    return List<Map<String, dynamic>>.from(data['bookings']);
  } else {
    throw Exception('Failed to load bookings');
  }
});

class BookingListScreen extends ConsumerStatefulWidget {
  const BookingListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends ConsumerState<BookingListScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh the bookings when screen is shown
    Future.microtask(() => ref.refresh(bookingsProvider));
  }

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(bookingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Your Bookings')),
      body: bookingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (bookings) {
          if (bookings.isEmpty) {
            return const Center(child: Text('No bookings found.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: bookings.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final booking = bookings[index];

              return ListTile(
                tileColor: Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: Text(booking['appliance'] ?? 'Appliance'),
                subtitle: Text(_formatDate(booking['preferredTime'])),
                trailing: StatusBadge(status: booking['status']),
                onTap: () {
                  // TODO: Navigate to booking detail screen
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(String isoDate) {
    final dt = DateTime.tryParse(isoDate);
    if (dt == null) return 'Date N/A';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
