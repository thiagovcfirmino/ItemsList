import 'package:flutter/foundation.dart' show kIsWeb;
import '../../models/item.dart';
import '../../models/item_list.dart';
import 'database_service.dart';
import 'simple_web_storage.dart';

/// Unified storage interface that automatically uses the right storage
/// based on the platform (SQLite for mobile, IndexedDB for web)
class StorageService {
  static final StorageService instance = StorageService._init();
  
  late final dynamic _service;
  
  StorageService._init() {
    if (kIsWeb) {
      _service = SimpleWebStorage.instance;
    } else {
      _service = DatabaseService.instance;
    }
  }

  // Lists CRUD Operations
  
  Future<String> createList(ItemList list) async {
    return await _service.createList(list);
  }

  Future<ItemList?> getList(String id) async {
    return await _service.getList(id);
  }

  Future<List<ItemList>> getAllLists() async {
    return await _service.getAllLists();
  }

  Future<dynamic> updateList(ItemList list) async {
    return await _service.updateList(list);
  }

  Future<dynamic> deleteList(String id) async {
    return await _service.deleteList(id);
  }

  Future<void> updateListItemCount(String listId) async {
    return await _service.updateListItemCount(listId);
  }

  // Items CRUD Operations
  
  Future<String> createItem(Item item) async {
    return await _service.createItem(item);
  }

  Future<Item?> getItem(String id) async {
    return await _service.getItem(id);
  }

  Future<List<Item>> getItemsByListId(String listId) async {
    return await _service.getItemsByListId(listId);
  }

  Future<List<Item>> getAllItems() async {
    return await _service.getAllItems();
  }

  Future<dynamic> updateItem(Item item) async {
    return await _service.updateItem(item);
  }

  Future<dynamic> deleteItem(String id) async {
    return await _service.deleteItem(id);
  }

  // Search and Filter Operations
  
  Future<List<Item>> searchItems(String query) async {
    return await _service.searchItems(query);
  }

  Future<List<Item>> getItemsByType(String type) async {
    return await _service.getItemsByType(type);
  }

  Future<List<Item>> getItemsByYear(int year) async {
    return await _service.getItemsByYear(year);
  }

  Future<List<String>> getAllTypes() async {
    return await _service.getAllTypes();
  }

  Future<List<int>> getAllYears() async {
    return await _service.getAllYears();
  }

  // Statistics
  
  Future<int> getTotalItemsCount() async {
    return await _service.getTotalItemsCount();
  }

  Future<int> getTotalListsCount() async {
    return await _service.getTotalListsCount();
  }

  Future<double> getTotalValue() async {
    return await _service.getTotalValue();
  }

  // Platform info
  bool get isWeb => kIsWeb;
}
