# Development Guide

## Getting Started

### Prerequisites

1. **Flutter SDK**
   - Install Flutter (stable channel recommended)
   - Version: 3.16.0 or higher
   - Run `flutter doctor` to verify installation

2. **IDE Setup**
   - VS Code with Flutter extension, OR
   - Android Studio with Flutter plugin
   - Dart plugin

3. **Platform Requirements**
   - **iOS**: macOS with Xcode 15+, CocoaPods
   - **Android**: Android Studio, Android SDK 21+

### Initial Setup

```bash
# Navigate to project
cd Documents/Organizer

# Get dependencies
flutter pub get

# Verify everything works
flutter doctor -v

# Run on connected device/simulator
flutter run
```

## Project Setup Steps

### Phase 1: Foundation (Week 1)

#### 1. Set Up Project Structure
```bash
# Create directory structure
mkdir -p lib/models
mkdir -p lib/screens/home lib/screens/list_detail lib/screens/item_detail
mkdir -p lib/screens/camera lib/screens/item_form lib/screens/search
mkdir -p lib/widgets/common lib/widgets/cards lib/widgets/dialogs
mkdir -p lib/services/ai lib/services/database lib/services/camera lib/services/storage
mkdir -p lib/providers
mkdir -p lib/utils/constants lib/utils/theme lib/utils/helpers
```

#### 2. Add Dependencies
Update `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  provider: ^6.1.1
  
  # Database
  sqflite: ^2.3.0
  path_provider: ^2.1.1
  path: ^1.8.3
  
  # Camera & Images
  camera: ^0.10.5
  image_picker: ^1.0.4
  image: ^4.1.3
  
  # UI Components
  cached_network_image: ^3.3.0
  flutter_staggered_grid_view: ^0.7.0
  
  # Utilities
  uuid: ^4.2.2
  intl: ^0.18.1
  
  # Optional for Phase 1
  # google_ml_kit: ^0.15.0
  # tflite_flutter: ^0.10.4

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
```

#### 3. Create Data Models

**lib/models/enums.dart**:
```dart
enum AcquisitionType {
  bought,
  gift,
}

enum SortOption {
  nameAsc,
  nameDesc,
  dateAsc,
  dateDesc,
  valueAsc,
  valueDesc,
}
```

**lib/models/item.dart**:
```dart
class Item {
  final String id;
  final String listId;
  final String name;
  final String? description;
  final List<String> imagePaths;
  final String type;
  final AcquisitionType acquisitionType;
  final int year;
  final double? value;
  final DateTime createdAt;
  final DateTime updatedAt;

  Item({
    required this.id,
    required this.listId,
    required this.name,
    this.description,
    required this.imagePaths,
    required this.type,
    required this.acquisitionType,
    required this.year,
    this.value,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'listId': listId,
      'name': name,
      'description': description,
      'imagePaths': imagePaths.join(','),
      'type': type,
      'acquisitionType': acquisitionType.index,
      'year': year,
      'value': value,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      listId: map['listId'],
      name: map['name'],
      description: map['description'],
      imagePaths: (map['imagePaths'] as String).split(','),
      type: map['type'],
      acquisitionType: AcquisitionType.values[map['acquisitionType']],
      year: map['year'],
      value: map['value'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  Item copyWith({
    String? name,
    String? description,
    List<String>? imagePaths,
    String? type,
    AcquisitionType? acquisitionType,
    int? year,
    double? value,
  }) {
    return Item(
      id: id,
      listId: listId,
      name: name ?? this.name,
      description: description ?? this.description,
      imagePaths: imagePaths ?? this.imagePaths,
      type: type ?? this.type,
      acquisitionType: acquisitionType ?? this.acquisitionType,
      year: year ?? this.year,
      value: value ?? this.value,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
```

**lib/models/item_list.dart**:
```dart
class ItemList {
  final String id;
  final String name;
  final String? description;
  final String? coverImagePath;
  final int itemCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  ItemList({
    required this.id,
    required this.name,
    this.description,
    this.coverImagePath,
    this.itemCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'coverImagePath': coverImagePath,
      'itemCount': itemCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ItemList.fromMap(Map<String, dynamic> map) {
    return ItemList(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      coverImagePath: map['coverImagePath'],
      itemCount: map['itemCount'] ?? 0,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  ItemList copyWith({
    String? name,
    String? description,
    String? coverImagePath,
    int? itemCount,
  }) {
    return ItemList(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverImagePath: coverImagePath ?? this.coverImagePath,
      itemCount: itemCount ?? this.itemCount,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
```

#### 4. Set Up Theme

**lib/utils/theme/app_theme.dart**: *(See DESIGN_SYSTEM.md for full implementation)*

### Phase 2: Database (Week 2)

#### 1. Create Database Service

**lib/services/database/database_service.dart**:
```dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('organizer.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const realType = 'REAL';

    await db.execute('''
      CREATE TABLE lists (
        id $idType,
        name $textType,
        description TEXT,
        coverImagePath TEXT,
        itemCount $intType,
        createdAt $textType,
        updatedAt $textType
      )
    ''');

    await db.execute('''
      CREATE TABLE items (
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
        FOREIGN KEY (listId) REFERENCES lists (id) ON DELETE CASCADE
      )
    ''');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
```

### Phase 3: UI Implementation (Week 3-4)

Build screens in this order:
1. Home Screen (list of lists)
2. List Detail Screen (items in a list)
3. Item Detail Screen (full item view)
4. Add/Edit Item Form
5. Camera Screen (Phase 4)

### Phase 4: Camera Integration (Week 5)

Implement camera functionality and basic image storage.

### Phase 5: AI Integration (Week 6+)

Start with simple similarity detection, then enhance.

## Development Workflow

### Daily Workflow

```bash
# Start development
flutter run

# Hot reload: Press 'r' in terminal or save file
# Hot restart: Press 'R' in terminal

# Run tests
flutter test

# Check for issues
flutter analyze

# Format code
flutter format .
```

### Git Workflow

```bash
# Create feature branch
git checkout -b feature/list-management

# Commit changes
git add .
git commit -m "feat: implement list CRUD operations"

# Push to remote
git push origin feature/list-management
```

### Commit Message Convention

```
feat: Add new feature
fix: Fix bug
docs: Update documentation
style: Format code
refactor: Refactor code
test: Add tests
chore: Update dependencies
```

## Testing Strategy

### Unit Tests
```dart
// test/models/item_test.dart
void main() {
  group('Item', () {
    test('should create item from map', () {
      final map = {
        'id': '1',
        'listId': '1',
        'name': 'Test Item',
        // ... more fields
      };
      
      final item = Item.fromMap(map);
      
      expect(item.name, 'Test Item');
    });
  });
}
```

### Widget Tests
```dart
// test/widgets/item_card_test.dart
void main() {
  testWidgets('ItemCard displays item name', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ItemCard(item: testItem),
      ),
    );
    
    expect(find.text('Test Item'), findsOneWidget);
  });
}
```

## Debugging

### Common Issues

**Issue**: Camera not working
- **Solution**: Check permissions in AndroidManifest.xml and Info.plist

**Issue**: Images not loading
- **Solution**: Verify file paths and storage permissions

**Issue**: Database errors
- **Solution**: Delete app and reinstall to reset database

### Debug Tools

```bash
# View logs
flutter logs

# Run with debugging
flutter run --debug

# Profile performance
flutter run --profile

# Inspect layout
# Use Flutter Inspector in IDE
```

## Performance Optimization

1. **Images**:
   - Compress before saving
   - Use thumbnails for lists
   - Lazy load images

2. **Database**:
   - Use indexed queries
   - Batch operations
   - Limit query results

3. **UI**:
   - Use const constructors
   - Implement list view builders
   - Avoid unnecessary rebuilds

## Deployment

### Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release
```

### iOS

```bash
# Build for iOS
flutter build ios --release

# Archive in Xcode
open ios/Runner.xcworkspace
```

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Documentation](https://dart.dev/guides)
- [Provider Package](https://pub.dev/packages/provider)
- [SQLite Guide](https://docs.flutter.dev/cookbook/persistence/sqlite)
- [Camera Plugin](https://pub.dev/packages/camera)

## Support

For questions or issues:
1. Check documentation
2. Search existing issues
3. Create new issue with details
4. Join Flutter community forums
