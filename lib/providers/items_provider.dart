import 'package:flutter/foundation.dart';
import '../models/item.dart';
import '../models/enums.dart';
import '../services/database/storage_service.dart';
import 'package:uuid/uuid.dart';

class ItemsProvider with ChangeNotifier {
  final StorageService _db = StorageService.instance;
  List<Item> _items = [];
  List<Item> _filteredItems = [];
  bool _isLoading = false;
  String? _error;
  String? _currentListId;

  List<Item> get items => _filteredItems.isEmpty ? _items : _filteredItems;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all items
  Future<void> loadAllItems() async {
    _isLoading = true;
    _error = null;
    _currentListId = null;
    notifyListeners();

    try {
      _items = await _db.getAllItems();
      _filteredItems = [];
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load items by list ID
  Future<void> loadItemsByListId(String listId) async {
    _isLoading = true;
    _error = null;
    _currentListId = listId;
    notifyListeners();

    try {
      _items = await _db.getItemsByListId(listId);
      _filteredItems = [];
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get a specific item
  Item? getItemById(String id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  // Create a new item
  Future<String?> createItem({
    required String listId,
    required String name,
    String? description,
    required List<String> imagePaths,
    required String type,
    required AcquisitionType acquisitionType,
    required int year,
    double? value,
  }) async {
    try {
      final item = Item(
        id: const Uuid().v4(),
        listId: listId,
        name: name,
        description: description,
        imagePaths: imagePaths,
        type: type,
        acquisitionType: acquisitionType,
        year: year,
        value: value,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _db.createItem(item);
      
      // Reload items for the current list
      if (_currentListId != null) {
        await loadItemsByListId(_currentListId!);
      } else {
        await loadAllItems();
      }
      
      return item.id;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Update an item
  Future<bool> updateItem({
    required String id,
    String? name,
    String? description,
    List<String>? imagePaths,
    String? type,
    AcquisitionType? acquisitionType,
    int? year,
    double? value,
  }) async {
    try {
      final item = getItemById(id);
      if (item == null) return false;

      final updatedItem = item.copyWith(
        name: name,
        description: description,
        imagePaths: imagePaths,
        type: type,
        acquisitionType: acquisitionType,
        year: year,
        value: value,
      );

      await _db.updateItem(updatedItem);
      
      // Reload items
      if (_currentListId != null) {
        await loadItemsByListId(_currentListId!);
      } else {
        await loadAllItems();
      }
      
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Delete an item
  Future<bool> deleteItem(String id) async {
    try {
      await _db.deleteItem(id);
      
      // Reload items
      if (_currentListId != null) {
        await loadItemsByListId(_currentListId!);
      } else {
        await loadAllItems();
      }
      
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Search items
  Future<void> searchItems(String query) async {
    if (query.isEmpty) {
      _filteredItems = [];
      notifyListeners();
      return;
    }

    try {
      _filteredItems = await _db.searchItems(query);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Filter by type
  Future<void> filterByType(String type) async {
    try {
      _filteredItems = await _db.getItemsByType(type);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Filter by year
  Future<void> filterByYear(int year) async {
    try {
      _filteredItems = await _db.getItemsByYear(year);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Clear filters
  void clearFilters() {
    _filteredItems = [];
    notifyListeners();
  }

  // Sort items
  void sortItems(SortOption sortOption) {
    final itemsToSort = _filteredItems.isEmpty ? _items : _filteredItems;
    
    switch (sortOption) {
      case SortOption.nameAsc:
        itemsToSort.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortOption.nameDesc:
        itemsToSort.sort((a, b) => b.name.compareTo(a.name));
        break;
      case SortOption.dateAsc:
        itemsToSort.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case SortOption.dateDesc:
        itemsToSort.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortOption.valueAsc:
        itemsToSort.sort((a, b) {
          if (a.value == null && b.value == null) return 0;
          if (a.value == null) return 1;
          if (b.value == null) return -1;
          return a.value!.compareTo(b.value!);
        });
        break;
      case SortOption.valueDesc:
        itemsToSort.sort((a, b) {
          if (a.value == null && b.value == null) return 0;
          if (a.value == null) return 1;
          if (b.value == null) return -1;
          return b.value!.compareTo(a.value!);
        });
        break;
    }
    
    notifyListeners();
  }

  // Get statistics
  Future<int> getTotalItemsCount() async {
    return await _db.getTotalItemsCount();
  }

  Future<double> getTotalValue() async {
    return await _db.getTotalValue();
  }

  Future<List<String>> getAllTypes() async {
    return await _db.getAllTypes();
  }

  Future<List<int>> getAllYears() async {
    return await _db.getAllYears();
  }
}
