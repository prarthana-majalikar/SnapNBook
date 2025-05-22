import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/constants/categories.dart';

class CategoryItemListScreen extends StatelessWidget {
  final String categoryName;

  const CategoryItemListScreen({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    final category = ServiceCategory.values.firstWhere(
      (c) => c.name == categoryName,
      orElse: () => ServiceCategory.kitchen,
    );

    final items = categoryItems[category]!;

    return Scaffold(
      appBar: AppBar(title: Text(categoryLabels[category]!)),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
          children:
              items.keys.map((itemName) {
                final displayName = capitalizeEachWord(itemName);

                return GestureDetector(
                  onTap: () {
                    final encodedItem = Uri.encodeComponent(itemName);
                    context.push('/appliance-selection/$encodedItem');
                  },
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          displayName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }
}

String capitalizeEachWord(String input) {
  return input
      .split(' ')
      .map(
        (word) =>
            word.isNotEmpty
                ? '${word[0].toUpperCase()}${word.substring(1)}'
                : '',
      )
      .join(' ');
}
