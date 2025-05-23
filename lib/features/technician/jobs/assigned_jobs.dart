import 'package:flutter/material.dart';
import 'package:snapnbook/services/job_service.dart';
import 'package:snapnbook/services/location_service.dart';
import 'package:snapnbook/shared/widgets/assigned_job_card.dart';

class AssignedJobsScreen extends StatefulWidget {
  final String technicianId;
  const AssignedJobsScreen({Key? key, required this.technicianId})
    : super(key: key);

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
        _assignedJobs =
            jobs
                .where(
                  (job) =>
                      job['status'] == 'ASSIGNED' &&
                      job['assignedTechIds']?.contains(widget.technicianId) ==
                          true &&
                      (job['assignedTechId'] == null ||
                          job['assignedTechId'] == 'None'),
                )
                .toList();
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
    final success = await JobService.acceptBooking(
      bookingId,
      widget.technicianId,
    );
    if (success) {
      TechnicianLocationService(
        widget.technicianId,
        bookingId,
      ).startLocationUpdates(); // ✅ Start tracking
      _fetchAssignedJobs();
    }
  }

  Future<void> _declineJob(String bookingId, String technicianId) async {
    final success = await JobService.declineBooking(bookingId, technicianId);
    if (success) _fetchAssignedJobs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title with better spacing and style
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
              child: Text(
                'Assigned Jobs',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _assignedJobs.isEmpty
                      ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.assignment_turned_in_outlined,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No assigned jobs yet',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(color: Colors.grey.shade700),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'You’ll see jobs here when one is assigned to you.',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: Colors.grey.shade500),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: _assignedJobs.length,
                        itemBuilder: (context, index) {
                          final job = _assignedJobs[index];

                          final appliance = job['appliance'] ?? 'N/A';
                          final issue = job['issue'] ?? 'N/A';
                          final address = job['address'] ?? 'N/A';
                          final time = job['preferredTime'] ?? 'N/A';

                          return AssignedJobCard(
                            title: 'Customer ${index + 1}',
                            appliance: appliance,
                            issue: issue,
                            address: address,
                            time: time,
                            onAccept: () => _acceptJob(job['bookingId']),
                            onCancel:
                                () => _declineJob(
                                  job['bookingId'],
                                  widget.technicianId,
                                ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
