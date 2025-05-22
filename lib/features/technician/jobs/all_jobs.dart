import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:snapnbook/config.dart';

class TechnicianAllJobsScreen extends StatefulWidget {
  final String technicianId;

  const TechnicianAllJobsScreen({super.key, required this.technicianId});

  @override
  State<TechnicianAllJobsScreen> createState() => _TechnicianAllJobsScreenState();
}

class _TechnicianAllJobsScreenState extends State<TechnicianAllJobsScreen> {
  List<dynamic> bookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchJobs();
  }

  Future<void> fetchJobs() async {
    final res = await http.get(Uri.parse('${AppConfig.baseUrl}/technician/${widget.technicianId}/bookings'));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      setState(() {
        bookings = data['bookings'];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status updated to $status')));
      fetchJobs(); // refresh list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update status')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Technician Jobs')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final job = bookings[index];
                return Card(
                  margin: const EdgeInsets.all(12),
                  child: ListTile(
                    title: Text('${job['appliance']} - ${job['status']}'),
                    subtitle: Text('Time: ${job['preferredTime']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (job['status'] == 'ASSIGNED')
                          ElevatedButton(
                            onPressed: () => updateStatus(job['bookingId'], 'ACCEPTED'),
                            child: const Text('Accept'),
                          ),
                        const SizedBox(width: 8),
                        if (job['status'] == 'ASSIGNED')
                          OutlinedButton(
                            onPressed: () => updateStatus(job['bookingId'], 'REJECTED'),
                            child: const Text('Reject'),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
