import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../state/booking_provider.dart';
import 'package:go_router/go_router.dart';

class ApplianceSelectionScreen extends ConsumerWidget {
  final String detectedObject;

  const ApplianceSelectionScreen({super.key, required this.detectedObject});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detected Appliance')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.devices_other, size: 80, color: Colors.deepPurple),
            const SizedBox(height: 20),
            Text(
              detectedObject.toUpperCase(),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ref.read(bookingProvider).setApplianceType(detectedObject);
                context.push('/booking');
              },
              child: const Text('Continue with this appliance'),
            ),
          ],
        ),
      ),
    );
  }
}
