import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../../models/item.dart';
import '../../models/item_list.dart';
import '../../models/enums.dart';

class ExportHelper {
  /// Export data to JSON format
  static Future<File> exportToJson({
    required List<ItemList> lists,
    required List<Item> items,
  }) async {
    final exportData = {
      'exportDate': DateTime.now().toIso8601String(),
      'version': '1.0.0',
      'appName': 'Organizer',
      'lists': lists.map((list) => list.toMap()).toList(),
      'items': items.map((item) => item.toMap()).toList(),
      'metadata': {
        'totalLists': lists.length,
        'totalItems': items.length,
        'exportFormat': 'json',
      },
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
    
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${directory.path}/organizer_backup_$timestamp.json');
    await file.writeAsString(jsonString);
    
    return file;
  }

  /// Export data to CSV format
  static Future<File> exportToCSV({
    required List<Item> items,
  }) async {
    final buffer = StringBuffer();
    
    // CSV Header
    buffer.writeln('ID,List ID,Name,Description,Type,Acquisition Type,Year,Value,Created At,Updated At');
    
    // CSV Data
    for (var item in items) {
      buffer.writeln([
        item.id,
        item.listId,
        _escapeCsv(item.name),
        _escapeCsv(item.description ?? ''),
        _escapeCsv(item.type),
        item.acquisitionType == AcquisitionType.bought ? 'Bought' : 'Gift',
        item.year,
        item.value ?? '',
        item.createdAt.toIso8601String(),
        item.updatedAt.toIso8601String(),
      ].join(','));
    }
    
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${directory.path}/organizer_items_$timestamp.csv');
    await file.writeAsString(buffer.toString());
    
    return file;
  }

  /// Import data from JSON format
  static Future<Map<String, dynamic>> importFromJson(String jsonString) async {
    try {
      final Map<String, dynamic> data = jsonDecode(jsonString);
      
      if (data['version'] == null) {
        throw Exception('Invalid backup file format');
      }
      
      final lists = (data['lists'] as List)
          .map((map) => ItemList.fromMap(map as Map<String, dynamic>))
          .toList();
      
      final items = (data['items'] as List)
          .map((map) => Item.fromMap(map as Map<String, dynamic>))
          .toList();
      
      return {
        'lists': lists,
        'items': items,
        'metadata': data['metadata'] ?? {},
      };
    } catch (e) {
      throw Exception('Failed to parse backup file: $e');
    }
  }

  /// Escape CSV special characters
  static String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  /// Get app documents directory path
  static Future<String> getExportDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
}
