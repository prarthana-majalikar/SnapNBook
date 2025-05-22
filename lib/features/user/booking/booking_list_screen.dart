import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../../shared/widgets/status_badge.dart';
import '../../../../state/auth_provider.dart';
import '../../../../config.dart';
import 'package:go_router/go_router.dart';

final bookingsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final userSession = ref.watch(authProvider);
  if (userSession == null || userSession.userId.isEmpty) {
    throw Exception('User not logged in');
  }

  final userId = userSession.userId;
  final response = await http.get(Uri.parse(AppConfig.getBookingsUrl(userId)));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    print('[DEBUG] Bookings data: $data');

    final bookings = List<Map<String, dynamic>>.from(data['bookings']);

    // Sort by preferredTime (ascending)
    bookings.sort(
      (a, b) => DateTime.parse(
        a['preferredTime'],
      ).compareTo(DateTime.parse(b['preferredTime'])),
    );

    return bookings;
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
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'No Bookings Yet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'You haven’t made any service bookings yet.\nOnce you do, they’ll appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.go('/'); // change route as needed
                      },
                      icon: const Icon(Icons.home),
                      label: const Text('Explore Services'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: bookings.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final booking = bookings[index];

              // Determine booking status for display
              String statusLabel = 'UNKNOWN';

              final status = booking['status'] ?? '';
              final hasAssignedTech =
                  booking['assignedTechId'] != null &&
                  booking['assignedTechId'] != 'None';

              if (status == 'ASSIGNED' && hasAssignedTech) {
                statusLabel = 'ASSIGNED';
              } else if (status == 'ACCEPTED') {
                statusLabel = 'ACCEPTED';
              } else if (status == 'COMPLETED') {
                statusLabel = 'COMPLETED';
              } else if (status == 'PENDING_ASSIGNMENT') {
                statusLabel = 'PENDING_ASSIGNMENT';
              } else if (status == 'NO_TECH_AVAILABLE') {
                statusLabel = 'NO_TECH_AVAILABLE';
              } else if (status == 'CANCELLED') {
                statusLabel = 'CANCELLED';
              }

              return ListTile(
                tileColor: Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: Text(booking['appliance'] ?? 'Appliance'),
                subtitle: Text(_formatDate(booking['preferredTime'])),
                trailing: StatusBadge(status: statusLabel),
                onTap: () {
                  context.push(
                    '/booking/${booking['bookingId']}',
                    extra: booking,
                  );
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
