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
  List<Map<String, dynamic>> _incompleteJobs = [];
  List<Map<String, dynamic>> _completedJobs = [];

  @override
  void initState() {
    super.initState();
    _fetchAcceptedJobs();
  }

  bool _isToday(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      final now = DateTime.now();
      return dt.year == now.year && dt.month == now.month && dt.day == now.day;
    } catch (_) {
      return false;
    }
  }

  Future<void> _fetchAcceptedJobs() async {
    setState(() => _isLoading = true);
    try {
      final jobs = await JobService.fetchJobsForTechnician(widget.technicianId);

      setState(() {
        _incompleteJobs =
            jobs
                .where(
                  (job) =>
                      job['status'] == 'ACCEPTED' &&
                      job['assignedTechId'] == widget.technicianId &&
                      job['isCompleted'] != true,
                )
                .toList();

        _completedJobs =
            jobs
                .where(
                  (job) =>
                      job['status'] == 'ACCEPTED' &&
                      job['assignedTechId'] == widget.technicianId &&
                      job['isCompleted'] == true &&
                      _isToday(job['preferredTime'] ?? ''),
                )
                .toList();

        _isLoading = false;
      });
    } catch (e) {
      print('[AcceptedJobsScreen] fetch error: $e');
      setState(() {
        _incompleteJobs = [];
        _completedJobs = [];
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('SnapNBook'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title with better spacing and style
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
              child: Text(
                'Accepted Jobs',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : (_incompleteJobs.isEmpty && _completedJobs.isEmpty)
                      ?
                      // Center(
                      //   child: Padding(
                      //     padding: const EdgeInsets.all(32),
                      //     child: Column(
                      //       mainAxisAlignment: MainAxisAlignment.center,
                      //       children: [
                      //         Icon(
                      //           Icons.assignment_turned_in_outlined,
                      //           size: 64,
                      //           color: Colors.grey.shade400,
                      //         ),
                      //         const SizedBox(height: 16),
                      //         Text(
                      //           'No accepted jobs yet',
                      //           style: Theme.of(context).textTheme.titleMedium
                      //               ?.copyWith(color: Colors.grey.shade700),
                      //         ),
                      //         const SizedBox(height: 8),
                      //         Text(
                      //           'You’ll see jobs here when you accept them.',
                      //           style: Theme.of(context).textTheme.bodyMedium
                      //               ?.copyWith(color: Colors.grey.shade500),
                      //           textAlign: TextAlign.center,
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // )
                      // _buildEmptyState()
                      Center(
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
                                'No jobs scheduled today',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(color: Colors.grey.shade700),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'You’ll see your jobs here once accepted.',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: Colors.grey.shade500),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                      :
                      // ListView.builder(
                      //   padding: const EdgeInsets.symmetric(
                      //     horizontal: 14,
                      //     vertical: 8,
                      //   ),
                      //   itemCount: _acceptedJobs.length,
                      //   itemBuilder: (context, index) {
                      //     final job = _acceptedJobs[index];
                      //     return AcceptedJobCard(
                      //       job: job,
                      //       technicianId: widget.technicianId,
                      //       onComplete: _markAsCompleted,
                      //     );
                      //   },
                      // ),
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_incompleteJobs.isNotEmpty) ...[
                              Text(
                                'Pending Jobs',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              ..._incompleteJobs.map(
                                (job) => AcceptedJobCard(
                                  job: job,
                                  technicianId: widget.technicianId,
                                  onComplete: _markAsCompleted,
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                            if (_completedJobs.isNotEmpty) ...[
                              Text(
                                'Completed Jobs',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              ..._completedJobs.map(
                                (job) => AcceptedJobCard(
                                  job: job,
                                  technicianId: widget.technicianId,
                                  onComplete: _markAsCompleted,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
