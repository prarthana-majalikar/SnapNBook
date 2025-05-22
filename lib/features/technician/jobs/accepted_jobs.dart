// Flutter file: lib/features/technician/home/accepted_jobs_screen.dart
import 'package:flutter/material.dart';
import 'package:snapnbook/services/job_service.dart';

class AcceptedJobsScreen extends StatefulWidget {
  final String technicianId;
  const AcceptedJobsScreen({Key? key, required this.technicianId}) : super(key: key);

  @override
  State<AcceptedJobsScreen> createState() => _AcceptedJobsScreenState();
}

class _AcceptedJobsScreenState extends State<AcceptedJobsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _acceptedJobs = [];

  @override
  void initState() {
    super.initState();
    _fetchAcceptedJobs();
  }

  Future<void> _fetchAcceptedJobs() async {
    setState(() => _isLoading = true);
    try {
      final jobs = await JobService.fetchJobsForTechnician(widget.technicianId);
      setState(() {
        _acceptedJobs = jobs.where((job) => job['status'] == 'ACCEPTED' && job['assignedTechId'] == widget.technicianId).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('[AcceptedJobsScreen] fetch error: $e');
      setState(() {
        _acceptedJobs = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsCompleted(String bookingId) async {
    final success = await JobService.markBookingCompleted(bookingId, widget.technicianId);
    if (success) _fetchAcceptedJobs();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Accepted Jobs',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _acceptedJobs.isEmpty
                  ? const Center(
                      child: Text('No accepted jobs.', style: TextStyle(color: Colors.grey)),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: _acceptedJobs.length,
                      itemBuilder: (context, index) {
                        final job = _acceptedJobs[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Appliance: ${job['appliance']}"),
                                Text("Issue: ${job['issue']}"),
                                Text("Address: ${job['address']}"),
                                Text("Preferred Time: ${job['preferredTime']}"),
                                const SizedBox(height: 10),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.check_circle, color: Colors.white),
                                  label: const Text("Mark as Completed"),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                  onPressed: () => _markAsCompleted(job['bookingId']),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
