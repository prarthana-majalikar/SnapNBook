import 'package:flutter/material.dart';

class JobDetailScreen extends StatelessWidget {
  final String bookingId;
  const JobDetailScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Job #$bookingId')),
      body: Center(child: Text('Details for job $bookingId')),
    );
  }
}
