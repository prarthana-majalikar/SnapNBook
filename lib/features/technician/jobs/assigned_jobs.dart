import 'package:flutter/material.dart';
import 'package:snapnbook/services/job_service.dart';
import 'package:snapnbook/services/location_service.dart';

class AssignedJobsScreen extends StatefulWidget {
  final String technicianId;
  const AssignedJobsScreen({Key? key, required this.technicianId}) : super(key: key);

  @override
  State<AssignedJobsScreen> createState() => _AssignedJobsScreenState();
}

class _AssignedJobsScreenState extends State<AssignedJobsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _assignedJobs = [];

  @override
  void initState() {
    super.initState();
    _fetchAssignedJobs();
  }

  Future<void> _fetchAssignedJobs() async {
    if (widget.technicianId.isEmpty) {
      setState(() {
        _isLoading = false;
        _assignedJobs = [];
      });
      return;
    }

    try {
      final jobs = await JobService.fetchJobsForTechnician(widget.technicianId);
      setState(() {
        _assignedJobs = jobs.where((job) =>
          job['status'] == 'ASSIGNED' &&
          job['assignedTechIds']?.contains(widget.technicianId) == true &&
          (job['assignedTechId'] == null || job['assignedTechId'] == 'None')
        ).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('[AssignedJobsScreen] fetch error: $e');
      setState(() {
        _assignedJobs = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _acceptJob(String bookingId) async {
    final success = await JobService.acceptBooking(bookingId, widget.technicianId);
    if (success) {
      TechnicianLocationService(widget.technicianId, bookingId).startLocationUpdates(); // ✅ Start tracking
      _fetchAssignedJobs();
    }
  }

  Future<void> _cancelJob(String bookingId) async {
    final success = await JobService.cancelBooking(bookingId);
    if (success) _fetchAssignedJobs();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Assigned Jobs',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _assignedJobs.isEmpty
                  ? const Center(
                      child: Text('No jobs yet.', style: TextStyle(color: Colors.grey)),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: _assignedJobs.length,
                      itemBuilder: (context, index) {
                        final job = _assignedJobs[index];

                        final userName = job['userName'] ?? 'Customer';
                        final appliance = job['appliance'] ?? 'N/A';
                        final issue = job['issue'] ?? 'N/A';
                        final address = job['address'] ?? 'N/A';
                        final time = job['preferredTime'] ?? 'N/A';

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userName,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text("Appliance: $appliance"),
                                Text("Issue: $issue"),
                                Text("Address: $address"),
                                Text("Preferred Time: $time"),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.check, color: Colors.green),
                                      onPressed: () => _acceptJob(job['bookingId']),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.cancel, color: Colors.red),
                                      onPressed: () => _cancelJob(job['bookingId']),
                                    ),
                                  ],
                                ),
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
