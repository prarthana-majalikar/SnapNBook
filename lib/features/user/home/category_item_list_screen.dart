import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/constants/categories.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../state/booking_provider.dart';

class CategoryItemListScreen extends ConsumerWidget {
  final String categoryName;

  const CategoryItemListScreen({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = ServiceCategory.values.firstWhere(
      (c) => c.name == categoryName,
      orElse: () => ServiceCategory.kitchenAppliances,
    );

    final items = categoryItems[category]!;

    return Scaffold(
      appBar: AppBar(title: Text(categoryLabels[category]!)),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          return GestureDetector(
            onTap: () {
              ref.read(bookingProvider).setApplianceType(item.key);
              context.push('/booking');
            },
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                title: Text(
                  item.displayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                trailing: Text(
                  '\$${item.price}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
