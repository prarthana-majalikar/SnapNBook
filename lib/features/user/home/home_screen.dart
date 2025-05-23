import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../services/image_detection_service.dart';
import 'package:go_router/go_router.dart';
import "../../../shared/constants/categories.dart";

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
            const SizedBox(height: 24),

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
                        '/appliance-selection/${Uri.encodeComponent(capitalize(objectName))}',
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
                _ServiceTile(
                  icon: Icons.directions_car,
                  label: 'Vehicles',
                  category: ServiceCategory.vehicle,
                ),
                _ServiceTile(
                  icon: Icons.chair,
                  label: 'Furniture',
                  category: ServiceCategory.furniture,
                ),
                _ServiceTile(
                  icon: Icons.devices,
                  label: 'Electronics',
                  category: ServiceCategory.electronics,
                ),
                _ServiceTile(
                  icon: Icons.kitchen,
                  label: 'Kitchen Appliances',
                  category: ServiceCategory.kitchenAppliances,
                ),
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
  final ServiceCategory category;

  const _ServiceTile({
    required this.icon,
    required this.label,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          final encodedCategory = Uri.encodeComponent(category.name);
          context.push('/category/$encodedCategory');
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

String capitalize(String s) {
  if (s.isEmpty) return s;
  return s[0].toUpperCase() + s.substring(1).toLowerCase();
}
