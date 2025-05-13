import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../services/image_detection_service.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SnapNBook'),
        actions: [IconButton(icon: const Icon(Icons.menu), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search services...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Scan Button
            PrimaryButton(
              label: '📸 Scan Appliance',
              onPressed: () async {
                final picker = ImagePicker();
                final pickedFile = await picker.pickImage(
                  // source:
                  //     Platform.isAndroid
                  //         ? ImageSource.camera
                  //         : ImageSource.gallery,
                  source: ImageSource.gallery,
                );

                if (pickedFile == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No image selected')),
                  );
                  return;
                }

                try {
                  final objectName = await detectFirstObjectFromImage(
                    File(pickedFile.path),
                  );

                  if (context.mounted) {
                    if (objectName != null) {
                      context.push(
                        '/appliance-selection/${Uri.encodeComponent(objectName)}',
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No object detected')),
                      );
                    }
                  }
                } catch (e) {
                  print('Error: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to detect object')),
                  );
                }
              },
            ),
            const SizedBox(height: 24),

            // Categories
            const Text(
              'Service Categories',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: const [
                _ServiceTile(icon: Icons.tv, label: 'Appliances'),
                _ServiceTile(icon: Icons.computer, label: 'Electronics'),
                _ServiceTile(icon: Icons.plumbing, label: 'Plumbing'),
                _ServiceTile(icon: Icons.chair, label: 'Furniture'),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ServiceTile({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to booking
        },
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: Colors.deepPurple),
              const SizedBox(height: 8),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}
