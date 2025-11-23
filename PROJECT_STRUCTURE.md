# Project Structure

## Data Models

### Item Model
```dart
class Item {
  String id;
  String listId;
  String name;
  String? description;
  List<String> imageUrls;
  String type;
  AcquisitionType acquisitionType; // Bought or Gift
  int year;
  double? value; // null if gift
  DateTime createdAt;
  DateTime updatedAt;
}

enum AcquisitionType {
  bought,
  gift
}
```

### List Model
```dart
class ItemList {
  String id;
  String name;
  String? description;
  String? coverImageUrl;
  int itemCount;
  DateTime createdAt;
  DateTime updatedAt;
}
```

## Screens

### 1. Home Screen
- Display all lists as cards
- Quick stats (total items, recent additions)
- FAB for quick camera access
- Search bar

### 2. List Detail Screen
- Grid/List view of items in the list
- Filter and sort options
- Add item button

### 3. Item Detail Screen
- Full-size image carousel
- All item information
- Edit/Delete options
- Share functionality

### 4. Camera Screen
- Live camera preview
- Capture button
- AI scanning indicator
- Results overlay showing similar items

### 5. Add/Edit Item Screen
- Photo selection/capture
- Form fields for item details
- Save/Cancel actions

### 6. Search Screen
- Global search across all lists
- Filter by type, year, value range
- AI-powered visual search

## Services

### AI Service
- Image preprocessing
- Feature extraction
- Similarity comparison
- Duplicate detection

### Database Service
- Local SQLite/Hive storage
- CRUD operations
- Query and filter methods
- Data migration

### Camera Service
- Camera initialization
- Photo capture
- Image compression
- Gallery integration

### Storage Service
- Image storage (local/cloud)
- Cache management
- Data backup

## State Management

Using Provider pattern for:
- Lists management
- Items management
- User preferences
- AI processing state

## UI Components

### Widgets
- `ItemCard`: Display item preview
- `ListCard`: Display list preview
- `ImageCarousel`: Swipeable image viewer
- `SearchBar`: Custom search input
- `FilterChip`: Category/filter chips
- `StatCard`: Statistics display
- `EmptyState`: Placeholder for empty lists

### Theme
- Primary color: Modern, trustworthy blue
- Secondary color: Accent for CTAs
- Typography: Clean, readable fonts
- Spacing: Consistent 8px grid system
- Shadows: Subtle elevation
- Animations: Smooth, purposeful

## Dependencies (Planned)

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  provider: ^6.0.0
  
  # Database
  sqflite: ^2.0.0
  hive: ^2.0.0
  hive_flutter: ^1.1.0
  
  # Camera & Images
  camera: ^0.10.0
  image_picker: ^1.0.0
  image: ^4.0.0
  
  # AI/ML
  tflite_flutter: ^0.10.0
  google_ml_kit: ^0.15.0
  
  # UI Components
  cached_network_image: ^3.0.0
  flutter_staggered_grid_view: ^0.7.0
  
  # Utilities
  uuid: ^4.0.0
  intl: ^0.18.0
  path_provider: ^2.0.0
```

## File Organization

```
lib/
├── main.dart
├── app.dart                          # MaterialApp configuration
│
├── models/
│   ├── item.dart
│   ├── item_list.dart
│   └── enums.dart
│
├── screens/
│   ├── home/
│   │   ├── home_screen.dart
│   │   └── widgets/
│   │       ├── list_grid.dart
│   │       └── stats_section.dart
│   │
│   ├── list_detail/
│   │   ├── list_detail_screen.dart
│   │   └── widgets/
│   │       ├── item_grid.dart
│   │       └── filter_bar.dart
│   │
│   ├── item_detail/
│   │   ├── item_detail_screen.dart
│   │   └── widgets/
│   │       ├── image_carousel.dart
│   │       └── info_section.dart
│   │
│   ├── camera/
│   │   ├── camera_screen.dart
│   │   ├── scan_result_screen.dart
│   │   └── widgets/
│   │       ├── camera_preview.dart
│   │       └── similarity_card.dart
│   │
│   ├── item_form/
│   │   ├── add_item_screen.dart
│   │   ├── edit_item_screen.dart
│   │   └── widgets/
│   │       └── item_form.dart
│   │
│   └── search/
│       ├── search_screen.dart
│       └── widgets/
│           └── search_result_card.dart
│
├── widgets/
│   ├── common/
│   │   ├── custom_app_bar.dart
│   │   ├── custom_button.dart
│   │   ├── custom_text_field.dart
│   │   └── empty_state.dart
│   │
│   ├── cards/
│   │   ├── item_card.dart
│   │   ├── list_card.dart
│   │   └── stat_card.dart
│   │
│   └── dialogs/
│       ├── delete_confirmation.dart
│       └── loading_dialog.dart
│
├── services/
│   ├── ai/
│   │   ├── ai_service.dart
│   │   ├── image_processor.dart
│   │   └── similarity_detector.dart
│   │
│   ├── database/
│   │   ├── database_service.dart
│   │   ├── item_dao.dart
│   │   └── list_dao.dart
│   │
│   ├── camera/
│   │   ├── camera_service.dart
│   │   └── image_picker_service.dart
│   │
│   └── storage/
│       ├── storage_service.dart
│       └── cache_manager.dart
│
├── providers/
│   ├── items_provider.dart
│   ├── lists_provider.dart
│   ├── camera_provider.dart
│   └── theme_provider.dart
│
└── utils/
    ├── constants/
    │   ├── app_constants.dart
    │   ├── colors.dart
    │   └── strings.dart
    │
    ├── theme/
    │   ├── app_theme.dart
    │   ├── text_styles.dart
    │   └── dimensions.dart
    │
    └── helpers/
        ├── date_helper.dart
        ├── image_helper.dart
        └── validation_helper.dart
```

## Development Guidelines

1. **Code Style**: Follow Flutter's style guide
2. **Naming**: Use descriptive, meaningful names
3. **Comments**: Document complex logic and APIs
4. **Testing**: Write unit tests for business logic
5. **Git**: Use conventional commit messages
6. **Performance**: Optimize images, lazy load lists
7. **Accessibility**: Support screen readers, proper contrast
