import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:snapnbook/config.dart';
import 'package:intl/intl.dart';
import 'package:snapnbook/services/job_service.dart';
import 'package:snapnbook/services/location_service.dart';

class TechnicianAllJobsScreen extends StatefulWidget {
  final String technicianId;

  const TechnicianAllJobsScreen({super.key, required this.technicianId});

  @override
  State<TechnicianAllJobsScreen> createState() =>
      _TechnicianAllJobsScreenState();
}

class _TechnicianAllJobsScreenState extends State<TechnicianAllJobsScreen> {
  List<dynamic> bookings = [];
  List<dynamic> filteredBookings = [];

  bool isLoading = true;

  String selectedStatus = 'All';
  String selectedSort = 'Newest First';

  final List<String> statusOptions = [
    'All',
    'ASSIGNED',
    'ACCEPTED',
    'REJECTED',
    'COMPLETED',
    'CANCELLED',
    'PAID',
  ];
  final List<String> sortOptions = ['Newest First', 'Oldest First'];

  Future<void> _acceptJob(String bookingId) async {
    final success = await JobService.acceptBooking(
      bookingId,
      widget.technicianId,
    );
    if (success) {
      TechnicianLocationService(
        widget.technicianId,
        bookingId,
      ).startLocationUpdates();
      fetchJobs();
    }
  }

  Future<void> _declineJob(String bookingId) async {
    final success = await JobService.declineBooking(
      bookingId,
      widget.technicianId,
    );
    if (success) {
      fetchJobs();
    }
  }

  @override
  void initState() {
    super.initState();
    fetchJobs();
  }

  Future<void> fetchJobs() async {
    setState(() => isLoading = true);

    final res = await http.get(
      Uri.parse(AppConfig.getJobsUrl(widget.technicianId)),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      bookings = data['bookings'];
      applyFilters();
    }

    setState(() => isLoading = false);
  }

  void applyFilters() {
    List<dynamic> updated = List.from(bookings);

    // Filter by status
    if (selectedStatus != 'All') {
      updated =
          updated.where((job) => job['status'] == selectedStatus).toList();
    }

    // Sort by date
    updated.sort((a, b) {
      final aDate = DateTime.tryParse(a['preferredTime']) ?? DateTime.now();
      final bDate = DateTime.tryParse(b['preferredTime']) ?? DateTime.now();

      return selectedSort == 'Newest First'
          ? bDate.compareTo(aDate)
          : aDate.compareTo(bDate);
    });

    setState(() => filteredBookings = updated);
  }

  Future<void> updateStatus(String bookingId, String status) async {
    final res = await http.post(
      Uri.parse('${AppConfig.baseUrl}/bookings/updateStatus'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'bookingId': bookingId,
        'technicianId': widget.technicianId,
        'status': status,
      }),
    );

    if (res.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Status updated to $status')));
      fetchJobs();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to update status')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Jobs')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedStatus,
                            decoration: const InputDecoration(
                              labelText: 'Filter by Status',
                            ),
                            items:
                                statusOptions.map((status) {
                                  return DropdownMenuItem(
                                    value: status,
                                    child: Text(status),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                selectedStatus = value;
                                applyFilters();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedSort,
                            decoration: const InputDecoration(
                              labelText: 'Sort by Date',
                            ),
                            items:
                                sortOptions.map((sort) {
                                  return DropdownMenuItem(
                                    value: sort,
                                    child: Text(sort),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                selectedSort = value;
                                applyFilters();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child:
                        filteredBookings.isEmpty
                            ? const Center(child: Text("No jobs found."))
                            : ListView.builder(
                              itemCount: filteredBookings.length,
                              itemBuilder: (context, index) {
                                final job = filteredBookings[index];
                                return Card(
                                  margin: const EdgeInsets.all(12),
                                  child: ListTile(
                                    title: Text(
                                      '${job['appliance']} - ${job['status']}',
                                    ),
                                    subtitle: Text(
                                      'Time: ${_formatDateTime(job['preferredTime'])}',
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (job['status'] == 'ASSIGNED')
                                          ElevatedButton(
                                            onPressed:
                                                () => _acceptJob(
                                                  job['bookingId'],
                                                ),
                                            child: const Text('Accept'),
                                          ),
                                        const SizedBox(width: 8),
                                        if (job['status'] == 'ASSIGNED')
                                          OutlinedButton(
                                            onPressed:
                                                () => _declineJob(
                                                  job['bookingId'],
                                                ),
                                            child: const Text('Reject'),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
    );
  }
}

String _formatDateTime(String isoDate) {
  final dt = DateTime.tryParse(isoDate);
  if (dt == null) return 'N/A';
  return DateFormat.yMMMMd().add_jm().format(dt);
}
