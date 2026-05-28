// ============================================================================
//  features/products/presentation/widgets/category_filter_bar.dart
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/product_entity.dart';
import '../controllers/product_controller.dart';

class CategoryFilterBar extends ConsumerWidget {
  const CategoryFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedCategoryProvider);

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        children: [
          _buildChip(
            ref: ref,
            category: null,
            label: 'Todos',
            selected: selected,
          ),
          ...ProductCategory.values.map(
            (category) => _buildChip(
              ref: ref,
              category: category,
              label: category.label,
              selected: selected,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required WidgetRef ref,
    required ProductCategory? category,
    required String label,
    required ProductCategory? selected,
  }) {
    final isSelected = selected == category;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          ref.read(selectedCategoryProvider.notifier).state = category;
        },
        selectedColor: const Color(0xFF8B4513).withValues(alpha: 0.2),
        checkmarkColor: const Color(0xFF8B4513),
      ),
    );
  }
}
