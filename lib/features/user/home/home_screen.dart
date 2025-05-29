import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snapnbook/state/booking_provider.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../services/image_detection_service.dart';
import 'package:go_router/go_router.dart';
import "../../../shared/constants/categories.dart";

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<List<ApplianceItem>> _filteredItems = ValueNotifier([]);

  final GlobalKey _searchFieldKey = GlobalKey();

  List<ApplianceItem> get allItems {
    return categoryItems.values.expand((list) => list).toList();
  }

  void _filterItems(String query) {
    final lowerQuery = query.toLowerCase();
    if (lowerQuery.isEmpty) {
      _filteredItems.value = [];
    } else {
      _filteredItems.value =
          allItems
              .where(
                (item) => item.displayName.toLowerCase().contains(lowerQuery),
              )
              .toList();
    }
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => _filterItems(_searchController.text));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _filteredItems.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('SnapNBook'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔍 Search Bar
                Container(
                  key: _searchFieldKey,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search services...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const SizedBox(height: 24),

                // 📸 Scan Button
                Center(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 24,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 6,
                      shadowColor: Colors.deepPurpleAccent,
                    ),
                    icon: const Icon(Icons.camera_alt, size: 24),
                    label: const Text(
                      'Scan Appliance',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () async {
                      final picker = ImagePicker();
                      final pickedFile = await picker.pickImage(
                        source: ImageSource.camera,
                      );

                      if (pickedFile == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No image selected')),
                        );
                        return;
                      }

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder:
                            (context) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                      );

                      try {
                        final result = await detectFirstObjectFromImage(
                          File(pickedFile.path),
                        );

                        if (!context.mounted) return;
                        context.pop();

                        final appliance = result?['appliance'];
                        final issue = result?['issue'];

                        if (appliance == 'No serviceable objects found' ||
                            (appliance == null || appliance.trim().isEmpty)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'No recognizable appliance found in the image. Please try again with a clearer picture.',
                              ),
                              duration: Duration(seconds: 3),
                            ),
                          );
                          return;
                        }

                        if (appliance != null && issue != null) {
                          context.push(
                            '/appliance-selection?appliance=${Uri.encodeComponent(appliance)}&issue=${Uri.encodeComponent(issue)}',
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Could not detect appliance or issue',
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        print('Error: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to detect appliance'),
                          ),
                        );
                      }
                    },
                  ),
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

          // 🔽 Suggestions overlay
          Positioned(
            left: 16,
            right: 16,
            top: 72,
            child: ValueListenableBuilder<List<ApplianceItem>>(
              valueListenable: _filteredItems,
              builder: (context, items, _) {
                if (items.isEmpty) return const SizedBox();
                return Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 204, 184, 241),
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  constraints: BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ListTile(
                        title: Text(item.displayName),
                        onTap: () {
                          ref.read(bookingProvider).setApplianceType(item.key);
                          context.push('/booking');
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
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
