import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/item.dart';
import '../../models/item_list.dart';
import '../../utils/constants/app_constants.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(AppConstants.databaseName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, filePath);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _createDB,
      onConfigure: _onConfigure,
    );
  }

  Future _onConfigure(Database db) async {
    // Enable foreign key constraints
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const realType = 'REAL';

    // Create lists table
    await db.execute('''
      CREATE TABLE ${AppConstants.tableLists} (
        id $idType,
        name $textType,
        description TEXT,
        coverImagePath TEXT,
        itemCount $intType DEFAULT 0,
        createdAt $textType,
        updatedAt $textType
      )
    ''');

    // Create items table
    await db.execute('''
      CREATE TABLE ${AppConstants.tableItems} (
        id $idType,
        listId $textType,
        name $textType,
        description TEXT,
        imagePaths $textType,
        type $textType,
        acquisitionType $intType,
        year $intType,
        value $realType,
        createdAt $textType,
        updatedAt $textType,
        FOREIGN KEY (listId) REFERENCES ${AppConstants.tableLists} (id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for better query performance
    await db.execute('''
      CREATE INDEX idx_items_listId ON ${AppConstants.tableItems}(listId)
    ''');
    
    await db.execute('''
      CREATE INDEX idx_items_type ON ${AppConstants.tableItems}(type)
    ''');
    
    await db.execute('''
      CREATE INDEX idx_items_year ON ${AppConstants.tableItems}(year)
    ''');
  }

  // Lists CRUD Operations
  
  Future<String> createList(ItemList list) async {
    final db = await database;
    await db.insert(AppConstants.tableLists, list.toMap());
    return list.id;
  }

  Future<ItemList?> getList(String id) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.tableLists,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return ItemList.fromMap(maps.first);
    }
    return null;
  }

  Future<List<ItemList>> getAllLists() async {
    final db = await database;
    final maps = await db.query(
      AppConstants.tableLists,
      orderBy: 'updatedAt DESC',
    );

    return maps.map((map) => ItemList.fromMap(map)).toList();
  }

  Future<int> updateList(ItemList list) async {
    final db = await database;
    return await db.update(
      AppConstants.tableLists,
      list.toMap(),
      where: 'id = ?',
      whereArgs: [list.id],
    );
  }

  Future<int> deleteList(String id) async {
    final db = await database;
    // This will cascade delete all items in the list
    return await db.delete(
      AppConstants.tableLists,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateListItemCount(String listId) async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM ${AppConstants.tableItems} WHERE listId = ?',
        [listId],
      ),
    ) ?? 0;

    await db.update(
      AppConstants.tableLists,
      {'itemCount': count, 'updatedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [listId],
    );
  }

  // Items CRUD Operations
  
  Future<String> createItem(Item item) async {
    final db = await database;
    await db.insert(AppConstants.tableItems, item.toMap());
    await updateListItemCount(item.listId);
    return item.id;
  }

  Future<Item?> getItem(String id) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.tableItems,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Item.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Item>> getItemsByListId(String listId) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.tableItems,
      where: 'listId = ?',
      whereArgs: [listId],
      orderBy: 'updatedAt DESC',
    );

    return maps.map((map) => Item.fromMap(map)).toList();
  }

  Future<List<Item>> getAllItems() async {
    final db = await database;
    final maps = await db.query(
      AppConstants.tableItems,
      orderBy: 'updatedAt DESC',
    );

    return maps.map((map) => Item.fromMap(map)).toList();
  }

  Future<int> updateItem(Item item) async {
    final db = await database;
    return await db.update(
      AppConstants.tableItems,
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteItem(String id) async {
    final db = await database;
    final item = await getItem(id);
    final result = await db.delete(
      AppConstants.tableItems,
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (item != null) {
      await updateListItemCount(item.listId);
    }
    
    return result;
  }

  // Search and Filter Operations
  
  Future<List<Item>> searchItems(String query) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.tableItems,
      where: 'name LIKE ? OR description LIKE ? OR type LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'updatedAt DESC',
    );

    return maps.map((map) => Item.fromMap(map)).toList();
  }

  Future<List<Item>> getItemsByType(String type) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.tableItems,
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'updatedAt DESC',
    );

    return maps.map((map) => Item.fromMap(map)).toList();
  }

  Future<List<Item>> getItemsByYear(int year) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.tableItems,
      where: 'year = ?',
      whereArgs: [year],
      orderBy: 'updatedAt DESC',
    );

    return maps.map((map) => Item.fromMap(map)).toList();
  }

  Future<List<String>> getAllTypes() async {
    final db = await database;
    final maps = await db.rawQuery(
      'SELECT DISTINCT type FROM ${AppConstants.tableItems} ORDER BY type ASC',
    );

    return maps.map((map) => map['type'] as String).toList();
  }

  Future<List<int>> getAllYears() async {
    final db = await database;
    final maps = await db.rawQuery(
      'SELECT DISTINCT year FROM ${AppConstants.tableItems} ORDER BY year DESC',
    );

    return maps.map((map) => map['year'] as int).toList();
  }

  // Statistics
  
  Future<int> getTotalItemsCount() async {
    final db = await database;
    return Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM ${AppConstants.tableItems}'),
    ) ?? 0;
  }

  Future<int> getTotalListsCount() async {
    final db = await database;
    return Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM ${AppConstants.tableLists}'),
    ) ?? 0;
  }

  Future<double> getTotalValue() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(value) as total FROM ${AppConstants.tableItems} WHERE value IS NOT NULL',
    );
    
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // Close database
  Future close() async {
    final db = await database;
    db.close();
  }
}
