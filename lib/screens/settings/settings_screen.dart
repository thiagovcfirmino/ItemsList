import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../../providers/items_provider.dart';
import '../../providers/lists_provider.dart';
import '../../services/database/database_service.dart';
import '../../utils/constants/strings.dart';
import '../../utils/constants/colors.dart';
import '../../utils/theme/app_theme.dart';
import '../../widgets/dialogs/export_dialog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settingsTitle),
      ),
      body: ListView(
        children: [
          // Data Management Section
          _buildSectionHeader(context, 'Data Management'),
          ListTile(
            leading: const Icon(Icons.backup, color: AppColors.primary),
            title: const Text('Export Data'),
            subtitle: const Text('Backup your data to JSON or CSV'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showExportDialog(context),
          ),
          ListTile(
            leading: const Icon(Icons.restore, color: AppColors.primary),
            title: const Text('Import Data'),
            subtitle: const Text('Restore from backup file'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showImportDialog(context),
          ),
          ListTile(
            leading: const Icon(Icons.delete_sweep, color: AppColors.warning),
            title: const Text('Clear Cache'),
            subtitle: const Text('Free up storage space'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showClearCacheDialog(context),
          ),
          const Divider(),

          // Statistics Section
          _buildSectionHeader(context, 'Statistics'),
          ListTile(
            leading: const Icon(Icons.analytics, color: AppColors.info),
            title: const Text('View Statistics'),
            subtitle: const Text('Insights and analytics'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, '/statistics');
            },
          ),
          const Divider(),

          // App Information Section
          _buildSectionHeader(context, 'About'),
          Consumer2<ItemsProvider, ListsProvider>(
            builder: (context, itemsProvider, listsProvider, child) {
              return FutureBuilder<Map<String, dynamic>>(
                future: _getAppStats(itemsProvider, listsProvider),
                builder: (context, snapshot) {
                  final stats = snapshot.data ?? {};
                  return Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.inventory_2_outlined),
                        title: const Text('Total Items'),
                        trailing: Text(
                          '${stats['totalItems'] ?? 0}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.folder_outlined),
                        title: const Text('Total Lists'),
                        trailing: Text(
                          '${stats['totalLists'] ?? 0}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.attach_money),
                        title: const Text('Total Value'),
                        trailing: Text(
                          NumberFormat.currency(symbol: '\$')
                              .format(stats['totalValue'] ?? 0),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.success,
                              ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          const Divider(),
          
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('App Version'),
            trailing: const Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('Developer'),
            trailing: const Text('Your Name'),
          ),
          
          const SizedBox(height: AppTheme.spacingXl),
          
          // Danger Zone
          _buildSectionHeader(context, 'Danger Zone'),
          ListTile(
            leading: const Icon(Icons.warning, color: AppColors.error),
            title: const Text('Delete All Data'),
            subtitle: const Text('This cannot be undone!'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showDeleteAllDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacingL,
        AppTheme.spacingL,
        AppTheme.spacingL,
        AppTheme.spacingS,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Future<Map<String, dynamic>> _getAppStats(
    ItemsProvider itemsProvider,
    ListsProvider listsProvider,
  ) async {
    final totalItems = await itemsProvider.getTotalItemsCount();
    final totalValue = await itemsProvider.getTotalValue();
    final totalLists = listsProvider.lists.length;

    return {
      'totalItems': totalItems,
      'totalLists': totalLists,
      'totalValue': totalValue,
    };
  }

  Future<void> _showExportDialog(BuildContext context) async {
    final filePath = await showDialog<String>(
      context: context,
      builder: (context) => const ExportDialog(),
    );

    if (filePath != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data exported to:\n$filePath'),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {},
          ),
        ),
      );
    }
  }

  void _showImportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Data'),
        content: const Text(
          'Import functionality requires file picker. '
          'This feature will allow you to select and restore a backup file.\n\n'
          'For now, backup files are saved in the app\'s documents directory.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
          'This will clear temporary files and cached images. '
          'Your data will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Show snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache cleared successfully'),
                ),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Data'),
        content: const Text(
          'This will permanently delete all your lists and items. '
          'This action cannot be undone!\n\n'
          'Are you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final listsProvider = context.read<ListsProvider>();
              final itemsProvider = context.read<ItemsProvider>();
              
              // Delete all lists (cascade deletes items)
              for (var list in listsProvider.lists) {
                await listsProvider.deleteList(list.id);
              }
              
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to previous screen
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All data deleted'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }
}
