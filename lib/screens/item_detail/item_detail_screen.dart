import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/items_provider.dart';
import '../../models/enums.dart';
import '../../utils/constants/strings.dart';
import '../../utils/constants/colors.dart';
import '../../utils/theme/app_theme.dart';
import '../item_form/item_form_screen.dart';

class ItemDetailScreen extends StatelessWidget {
  final String itemId;

  const ItemDetailScreen({
    super.key,
    required this.itemId,
  });

  @override
  Widget build(BuildContext context) {
    final itemsProvider = context.watch<ItemsProvider>();
    final item = itemsProvider.getItemById(itemId);

    if (item == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text('Item not found'),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildImageCarousel(item.imagePaths),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ItemFormScreen(
                        listId: item.listId,
                        itemId: item.id,
                      ),
                    ),
                  );
                },
              ),
              PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: AppColors.error),
                        SizedBox(width: 8),
                        Text(
                          AppStrings.itemDelete,
                          style: TextStyle(color: AppColors.error),
                        ),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'delete') {
                    _showDeleteDialog(context, itemsProvider);
                  }
                },
              ),
            ],
          ),

          // Item Details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    item.name,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: AppTheme.spacingS),

                  // Acquisition Badge
                  _buildAcquisitionChip(item.acquisitionType),
                  const SizedBox(height: AppTheme.spacingL),

                  // Description
                  if (item.description != null && item.description!.isNotEmpty) ...[
                    Text(
                      AppStrings.itemDescription,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: AppTheme.spacingS),
                    Text(
                      item.description!,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: AppTheme.spacingL),
                  ],

                  // Details Section
                  _buildDetailRow(
                    context,
                    icon: Icons.category_outlined,
                    label: AppStrings.itemType,
                    value: item.type,
                  ),
                  const Divider(),
                  _buildDetailRow(
                    context,
                    icon: Icons.calendar_today_outlined,
                    label: AppStrings.itemYear,
                    value: item.year.toString(),
                  ),
                  if (item.value != null) ...[
                    const Divider(),
                    _buildDetailRow(
                      context,
                      icon: Icons.attach_money,
                      label: AppStrings.itemValue,
                      value: NumberFormat.currency(symbol: '\$').format(item.value),
                      valueColor: AppColors.success,
                    ),
                  ],
                  const Divider(),
                  _buildDetailRow(
                    context,
                    icon: Icons.info_outline,
                    label: AppStrings.itemCreated,
                    value: DateFormat('MMM d, y').format(item.createdAt),
                  ),
                  if (item.createdAt != item.updatedAt) ...[
                    const Divider(),
                    _buildDetailRow(
                      context,
                      icon: Icons.update,
                      label: AppStrings.itemUpdated,
                      value: DateFormat('MMM d, y').format(item.updatedAt),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel(List<String> imagePaths) {
    if (imagePaths.isEmpty || imagePaths.first.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.surface,
              AppColors.surface.withOpacity(0.5),
            ],
          ),
        ),
        child: const Center(
          child: Icon(
            Icons.image_outlined,
            size: 80,
            color: AppColors.textHint,
          ),
        ),
      );
    }

    if (imagePaths.length == 1) {
      return Image.file(
        File(imagePaths.first),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: AppColors.surface,
            child: const Center(
              child: Icon(
                Icons.broken_image_outlined,
                size: 80,
                color: AppColors.textHint,
              ),
            ),
          );
        },
      );
    }

    return PageView.builder(
      itemCount: imagePaths.length,
      itemBuilder: (context, index) {
        return Image.file(
          File(imagePaths[index]),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppColors.surface,
              child: const Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  size: 80,
                  color: AppColors.textHint,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAcquisitionChip(AcquisitionType acquisitionType) {
    final isBought = acquisitionType == AcquisitionType.bought;
    return Chip(
      avatar: Icon(
        isBought ? Icons.shopping_cart : Icons.card_giftcard,
        size: 20,
        color: Colors.white,
      ),
      label: Text(
        acquisitionType.displayName,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: isBought ? AppColors.bought : AppColors.gift,
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
      child: Row(
        children: [
          Icon(
            icon,
            size: AppTheme.iconM,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: valueColor,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ItemsProvider itemsProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.dialogDeleteTitle),
        content: const Text(AppStrings.dialogDeleteItemMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.dialogCancel),
          ),
          ElevatedButton(
            onPressed: () async {
              await itemsProvider.deleteItem(itemId);

              if (context.mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Return to list
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(AppStrings.messageItemDeleted),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text(AppStrings.dialogConfirm),
          ),
        ],
      ),
    );
  }
}
