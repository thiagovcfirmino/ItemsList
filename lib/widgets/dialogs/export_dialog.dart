import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/items_provider.dart';
import '../../providers/lists_provider.dart';
import '../../utils/helpers/export_helper.dart';
import '../../utils/constants/colors.dart';
import '../../utils/theme/app_theme.dart';

class ExportDialog extends StatefulWidget {
  const ExportDialog({super.key});

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  String _selectedFormat = 'json';
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Export Data'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Choose export format:'),
          const SizedBox(height: AppTheme.spacingM),
          
          RadioListTile<String>(
            title: const Text('JSON'),
            subtitle: const Text('Complete backup with all data'),
            value: 'json',
            groupValue: _selectedFormat,
            onChanged: _isExporting ? null : (value) {
              setState(() {
                _selectedFormat = value!;
              });
            },
          ),
          
          RadioListTile<String>(
            title: const Text('CSV'),
            subtitle: const Text('Items only, spreadsheet format'),
            value: 'csv',
            groupValue: _selectedFormat,
            onChanged: _isExporting ? null : (value) {
              setState(() {
                _selectedFormat = value!;
              });
            },
          ),
          
          if (_isExporting)
            const Padding(
              padding: EdgeInsets.only(top: AppTheme.spacingM),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: AppTheme.spacingM),
                  Text('Exporting...'),
                ],
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isExporting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isExporting ? null : _export,
          child: const Text('Export'),
        ),
      ],
    );
  }

  Future<void> _export() async {
    setState(() {
      _isExporting = true;
    });

    try {
      final listsProvider = context.read<ListsProvider>();
      final itemsProvider = context.read<ItemsProvider>();
      
      // Load all data
      await listsProvider.loadLists();
      await itemsProvider.loadAllItems();
      
      late final String filePath;
      
      if (_selectedFormat == 'json') {
        final file = await ExportHelper.exportToJson(
          lists: listsProvider.lists,
          items: itemsProvider.items,
        );
        filePath = file.path;
      } else {
        final file = await ExportHelper.exportToCSV(
          items: itemsProvider.items,
        );
        filePath = file.path;
      }
      
      if (mounted) {
        Navigator.pop(context, filePath);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
