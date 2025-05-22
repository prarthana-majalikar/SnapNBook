import 'package:flutter/material.dart';

class AcceptedJobCard extends StatefulWidget {
  final Map<String, dynamic> job;
  final String technicianId;
  final void Function(String bookingId) onComplete;

  const AcceptedJobCard({
    super.key,
    required this.job,
    required this.technicianId,
    required this.onComplete,
  });

  @override
  State<AcceptedJobCard> createState() => _AcceptedJobCardState();
}

class _AcceptedJobCardState extends State<AcceptedJobCard> {
  late final TextEditingController feeController;
  bool isFeeConfirmed = false;

  @override
  void initState() {
    super.initState();
    final fee = widget.job['fees'];
    feeController = TextEditingController(
      text: fee != null ? fee.toString() : '',
    );
  }

  @override
  void dispose() {
    feeController.dispose();
    super.dispose();
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.deepPurple),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    final appliance = job['appliance'] ?? 'N/A';
    final issue = job['issue'] ?? '';
    final address = job['address'] ?? 'N/A';
    final time = job['preferredTime'] ?? 'N/A';
    final bookingId = job['bookingId'] ?? '';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Job ID: $bookingId',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 10),
            _buildDetailRow(Icons.build, 'Appliance', appliance),
            if (issue.trim().isNotEmpty)
              _buildDetailRow(Icons.report_problem_outlined, 'Issue', issue),
            _buildDetailRow(Icons.location_on_outlined, 'Address', address),
            _buildDetailRow(Icons.access_time, 'Time', time),

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Icon(
                    Icons.attach_money,
                    color: Colors.deepPurple,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: feeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Service Fee',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (feeController.text.trim().isNotEmpty) {
                          setState(() => isFeeConfirmed = true);
                          // ScaffoldMessenger.of(context).showSnackBar(
                          //   const SnackBar(content: Text('Fee confirmed')),
                          // );
                        }
                      },
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      tooltip: 'Confirm',
                    ),
                    const Text(
                      'Confirm',
                      style: TextStyle(fontSize: 12, color: Colors.green),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed:
                      isFeeConfirmed
                          ? () => widget.onComplete(bookingId)
                          : null,
                  icon: const Icon(Icons.check),
                  label: const Text("Mark as Completed"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isFeeConfirmed
                            ? Colors.green.shade600
                            : Colors.grey.shade400,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.w600),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
