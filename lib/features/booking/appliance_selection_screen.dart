import 'package:flutter/material.dart';

class ApplianceSelectionScreen extends StatelessWidget {
  final String detectedObject;

  const ApplianceSelectionScreen({super.key, required this.detectedObject});

  @override
  Widget build(BuildContext context) {
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
                // TODO: Move to booking screen with detectedObject
              },
              child: const Text('Continue with this appliance'),
            ),
          ],
        ),
      ),
    );
  }
}
