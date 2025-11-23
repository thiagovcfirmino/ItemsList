import 'dart:convert';
import 'package:localstore/localstore.dart';
import '../../models/item.dart';
import '../../models/item_list.dart';

class WebStorageService {
  static final WebStorageService instance = WebStorageService._init();
  final _db = Localstore.instance;
  
  WebStorageService._init();

  // Collections
  static const String _listsCollection = 'lists';
  static const String _itemsCollection = 'items';

  // Lists CRUD Operations
  
  Future<String> createList(ItemList list) async {
    try {
      print('WebStorageService: Creating list with ID: ${list.id}');
      final listMap = list.toMap();
      print('WebStorageService: List data: $listMap');
      
      await _db.collection(_listsCollection).doc(list.id).set(listMap);
      print('WebStorageService: List created successfully');
      
      return list.id;
    } catch (e) {
      print('WebStorageService: Error creating list: $e');
      rethrow;
    }
  }

  Future<ItemList?> getList(String id) async {
    final data = await _db.collection(_listsCollection).doc(id).get();
    if (data != null) {
      return ItemList.fromMap(data);
    }
    return null;
  }

  Future<List<ItemList>> getAllLists() async {
    try {
      print('WebStorageService: Getting all lists');
      final data = await _db.collection(_listsCollection).get();
      print('WebStorageService: Raw data: $data');
      
      if (data == null || data.isEmpty) {
        print('WebStorageService: No lists found');
        return [];
      }
      
      final lists = data.entries
          .map((entry) {
            print('WebStorageService: Processing entry: ${entry.key} -> ${entry.value}');
            return ItemList.fromMap(entry.value as Map<String, dynamic>);
          })
          .toList();
      
      // Sort by updatedAt DESC
      lists.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      print('WebStorageService: Returning ${lists.length} lists');
      return lists;
    } catch (e) {
      print('WebStorageService: Error getting lists: $e');
      return [];
    }
  }

  Future<void> updateList(ItemList list) async {
    await _db.collection(_listsCollection).doc(list.id).set(list.toMap());
  }

  Future<void> deleteList(String id) async {
    // Delete the list
    await _db.collection(_listsCollection).doc(id).delete();
    
    // Delete all items in the list
    final items = await getItemsByListId(id);
    for (var item in items) {
      await _db.collection(_itemsCollection).doc(item.id).delete();
    }
  }

  Future<void> updateListItemCount(String listId) async {
    final items = await getItemsByListId(listId);
    final list = await getList(listId);
    
    if (list != null) {
      final updatedList = ItemList(
        id: list.id,
        name: list.name,
        description: list.description,
        coverImagePath: list.coverImagePath,
        itemCount: items.length,
        createdAt: list.createdAt,
        updatedAt: DateTime.now(),
      );
      await updateList(updatedList);
    }
  }

  // Items CRUD Operations
  
  Future<String> createItem(Item item) async {
    await _db.collection(_itemsCollection).doc(item.id).set(item.toMap());
    await updateListItemCount(item.listId);
    return item.id;
  }

  Future<Item?> getItem(String id) async {
    final data = await _db.collection(_itemsCollection).doc(id).get();
    if (data != null) {
      return Item.fromMap(data);
    }
    return null;
  }

  Future<List<Item>> getItemsByListId(String listId) async {
    final data = await _db.collection(_itemsCollection).get();
    if (data == null || data.isEmpty) return [];
    
    final items = data.entries
        .map((entry) => Item.fromMap(entry.value as Map<String, dynamic>))
        .where((item) => item.listId == listId)
        .toList();
    
    // Sort by updatedAt DESC
    items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return items;
  }

  Future<List<Item>> getAllItems() async {
    final data = await _db.collection(_itemsCollection).get();
    if (data == null || data.isEmpty) return [];
    
    final items = data.entries
        .map((entry) => Item.fromMap(entry.value as Map<String, dynamic>))
        .toList();
    
    // Sort by updatedAt DESC
    items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return items;
  }

  Future<void> updateItem(Item item) async {
    await _db.collection(_itemsCollection).doc(item.id).set(item.toMap());
  }

  Future<void> deleteItem(String id) async {
    final item = await getItem(id);
    await _db.collection(_itemsCollection).doc(id).delete();
    
    if (item != null) {
      await updateListItemCount(item.listId);
    }
  }

  // Search and Filter Operations
  
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

  // Statistics
  
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

  // Clear all data (for testing)
  Future<void> clearAll() async {
    final lists = await _db.collection(_listsCollection).get();
    if (lists != null) {
      for (var entry in lists.entries) {
        await _db.collection(_listsCollection).doc(entry.key).delete();
      }
    }
    
    final items = await _db.collection(_itemsCollection).get();
    if (items != null) {
      for (var entry in items.entries) {
        await _db.collection(_itemsCollection).doc(entry.key).delete();
      }
    }
  }
}
