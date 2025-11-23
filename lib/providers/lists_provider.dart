import 'package:flutter/foundation.dart';
import '../models/item_list.dart';
import '../services/database/database_service.dart';
import 'package:uuid/uuid.dart';

class ListsProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  List<ItemList> _lists = [];
  bool _isLoading = false;
  String? _error;

  List<ItemList> get lists => _lists;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all lists
  Future<void> loadLists() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _lists = await _db.getAllLists();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get a specific list
  ItemList? getListById(String id) {
    try {
      return _lists.firstWhere((list) => list.id == id);
    } catch (e) {
      return null;
    }
  }

  // Create a new list
  Future<String?> createList({
    required String name,
    String? description,
    String? coverImagePath,
  }) async {
    try {
      final list = ItemList(
        id: const Uuid().v4(),
        name: name,
        description: description,
        coverImagePath: coverImagePath,
        itemCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _db.createList(list);
      await loadLists();
      return list.id;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Update a list
  Future<bool> updateList({
    required String id,
    String? name,
    String? description,
    String? coverImagePath,
  }) async {
    try {
      final list = getListById(id);
      if (list == null) return false;

      final updatedList = list.copyWith(
        name: name,
        description: description,
        coverImagePath: coverImagePath,
      );

      await _db.updateList(updatedList);
      await loadLists();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Delete a list
  Future<bool> deleteList(String id) async {
    try {
      await _db.deleteList(id);
      await loadLists();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Update item count for a list
  Future<void> updateListItemCount(String listId) async {
    try {
      await _db.updateListItemCount(listId);
      await loadLists();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Get statistics
  Future<int> getTotalListsCount() async {
    return _lists.length;
  }
}
