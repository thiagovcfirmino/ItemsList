import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/item.dart';
import '../../models/item_list.dart';

class SimpleWebStorage {
  static const String _listsKey = 'organizer_lists';
  static const String _itemsKey = 'organizer_items';
  
  static SimpleWebStorage? _instance;
  static SimpleWebStorage get instance {
    _instance ??= SimpleWebStorage._();
    return _instance!;
  }
  
  SimpleWebStorage._();

  Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  // Lists operations
  Future<String> createList(ItemList list) async {
    try {
      print('SimpleWebStorage: Creating list ${list.name} with ID: ${list.id}');
      final prefs = await _getPrefs();
      final existingLists = await getAllLists();
      existingLists.add(list);
      
      final listMaps = existingLists.map((l) => l.toMap()).toList();
      final jsonString = jsonEncode(listMaps);
      
      await prefs.setString(_listsKey, jsonString);
      print('SimpleWebStorage: List saved successfully. Total lists: ${existingLists.length}');
      return list.id;
    } catch (e) {
      print('SimpleWebStorage: Error creating list: $e');
      rethrow;
    }
  }

  Future<List<ItemList>> getAllLists() async {
    try {
      final prefs = await _getPrefs();
      final jsonString = prefs.getString(_listsKey);
      
      if (jsonString == null || jsonString.isEmpty) {
        print('SimpleWebStorage: No lists found in storage');
        return [];
      }

      final List<dynamic> listMaps = jsonDecode(jsonString);
      final lists = listMaps.map((map) => ItemList.fromMap(Map<String, dynamic>.from(map))).toList();
      
      // Sort by updatedAt DESC
      lists.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      print('SimpleWebStorage: Retrieved ${lists.length} lists from storage');
      return lists;
    } catch (e) {
      print('SimpleWebStorage: Error getting lists: $e');
      return [];
    }
  }

  Future<ItemList?> getList(String id) async {
    final lists = await getAllLists();
    try {
      return lists.firstWhere((list) => list.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateList(ItemList updatedList) async {
    try {
      final lists = await getAllLists();
      final index = lists.indexWhere((list) => list.id == updatedList.id);
      
      if (index != -1) {
        lists[index] = updatedList;
        final prefs = await _getPrefs();
        final listMaps = lists.map((l) => l.toMap()).toList();
        final jsonString = jsonEncode(listMaps);
        await prefs.setString(_listsKey, jsonString);
      }
    } catch (e) {
      print('SimpleWebStorage: Error updating list: $e');
      rethrow;
    }
  }

  Future<void> deleteList(String id) async {
    try {
      final lists = await getAllLists();
      lists.removeWhere((list) => list.id == id);
      
      final prefs = await _getPrefs();
      final listMaps = lists.map((l) => l.toMap()).toList();
      final jsonString = jsonEncode(listMaps);
      await prefs.setString(_listsKey, jsonString);
      
      // Also delete items in this list
      final items = await getAllItems();
      items.removeWhere((item) => item.listId == id);
      final itemMaps = items.map((i) => i.toMap()).toList();
      final itemsJsonString = jsonEncode(itemMaps);
      await prefs.setString(_itemsKey, itemsJsonString);
    } catch (e) {
      print('SimpleWebStorage: Error deleting list: $e');
      rethrow;
    }
  }

  // Items operations
  Future<String> createItem(Item item) async {
    try {
      final prefs = await _getPrefs();
      final existingItems = await getAllItems();
      existingItems.add(item);
      
      final itemMaps = existingItems.map((i) => i.toMap()).toList();
      final jsonString = jsonEncode(itemMaps);
      
      await prefs.setString(_itemsKey, jsonString);
      
      // Update list item count
      await updateListItemCount(item.listId);
      
      return item.id;
    } catch (e) {
      print('SimpleWebStorage: Error creating item: $e');
      rethrow;
    }
  }

  Future<List<Item>> getAllItems() async {
    try {
      final prefs = await _getPrefs();
      final jsonString = prefs.getString(_itemsKey);
      
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> itemMaps = jsonDecode(jsonString);
      final items = itemMaps.map((map) => Item.fromMap(Map<String, dynamic>.from(map))).toList();
      
      // Sort by updatedAt DESC
      items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return items;
    } catch (e) {
      print('SimpleWebStorage: Error getting items: $e');
      return [];
    }
  }

  Future<List<Item>> getItemsByListId(String listId) async {
    final allItems = await getAllItems();
    return allItems.where((item) => item.listId == listId).toList();
  }

  Future<Item?> getItem(String id) async {
    final items = await getAllItems();
    try {
      return items.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateItem(Item updatedItem) async {
    try {
      final items = await getAllItems();
      final index = items.indexWhere((item) => item.id == updatedItem.id);
      
      if (index != -1) {
        items[index] = updatedItem;
        final prefs = await _getPrefs();
        final itemMaps = items.map((i) => i.toMap()).toList();
        final jsonString = jsonEncode(itemMaps);
        await prefs.setString(_itemsKey, jsonString);
      }
    } catch (e) {
      print('SimpleWebStorage: Error updating item: $e');
      rethrow;
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      final item = await getItem(id);
      final items = await getAllItems();
      items.removeWhere((item) => item.id == id);
      
      final prefs = await _getPrefs();
      final itemMaps = items.map((i) => i.toMap()).toList();
      final jsonString = jsonEncode(itemMaps);
      await prefs.setString(_itemsKey, jsonString);
      
      if (item != null) {
        await updateListItemCount(item.listId);
      }
    } catch (e) {
      print('SimpleWebStorage: Error deleting item: $e');
      rethrow;
    }
  }

  Future<void> updateListItemCount(String listId) async {
    try {
      final items = await getItemsByListId(listId);
      final list = await getList(listId);
      
      if (list != null) {
        final updatedList = list.copyWith(itemCount: items.length);
        await updateList(updatedList);
      }
    } catch (e) {
      print('SimpleWebStorage: Error updating list item count: $e');
    }
  }

  // Search and utility methods
  Future<List<Item>> searchItems(String query) async {
    final allItems = await getAllItems();
    final lowerQuery = query.toLowerCase();
    
    return allItems.where((item) {
      return item.name.toLowerCase().contains(lowerQuery) ||
             (item.description?.toLowerCase().contains(lowerQuery) ?? false) ||
             (item.type?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  Future<List<Item>> getItemsByType(String type) async {
    final allItems = await getAllItems();
    return allItems.where((item) => item.type == type).toList();
  }

  Future<List<Item>> getItemsByYear(int year) async {
    final allItems = await getAllItems();
    return allItems.where((item) => item.year == year).toList();
  }

  Future<List<String>> getAllTypes() async {
    final allItems = await getAllItems();
    final types = allItems
        .where((item) => item.type != null)
        .map((item) => item.type!)
        .toSet()
        .toList();
    types.sort();
    return types;
  }

  Future<List<int>> getAllYears() async {
    final allItems = await getAllItems();
    final years = allItems
        .where((item) => item.year != null)
        .map((item) => item.year!)
        .toSet()
        .toList();
    years.sort((a, b) => b.compareTo(a));
    return years;
  }

  Future<int> getTotalItemsCount() async {
    final items = await getAllItems();
    return items.length;
  }

  Future<int> getTotalListsCount() async {
    final lists = await getAllLists();
    return lists.length;
  }

  Future<double> getTotalValue() async {
    final items = await getAllItems();
    return items.fold(0.0, (sum, item) => sum + (item.value ?? 0.0));
  }

  // Clear all data for testing
  Future<void> clearAll() async {
    final prefs = await _getPrefs();
    await prefs.remove(_listsKey);
    await prefs.remove(_itemsKey);
  }
}