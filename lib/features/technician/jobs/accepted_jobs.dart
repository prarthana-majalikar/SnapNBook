import 'package:flutter/material.dart';
import 'package:snapnbook/services/job_service.dart';
import 'package:snapnbook/shared/widgets/accepted_job_card.dart';

class AcceptedJobsScreen extends StatefulWidget {
  final String technicianId;
  const AcceptedJobsScreen({Key? key, required this.technicianId})
    : super(key: key);

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
        _acceptedJobs =
            jobs
                .where(
                  (job) =>
                      job['status'] == 'ACCEPTED' &&
                      job['assignedTechId'] == widget.technicianId,
                )
                .toList();
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
    final success = await JobService.markBookingCompleted(
      bookingId,
      widget.technicianId,
    );
    if (success) _fetchAcceptedJobs();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Text(
            'Accepted Jobs',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          child:
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _acceptedJobs.isEmpty
                  ? const Center(
                    child: Text(
                      'No accepted jobs.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    itemCount: _acceptedJobs.length,
                    itemBuilder: (context, index) {
                      final job = _acceptedJobs[index];
                      return AcceptedJobCard(
                        job: job,
                        technicianId: widget.technicianId,
                        onComplete: _markAsCompleted,
                      );
                    },
                  ),
        ),
      ],
    );
  }
}
