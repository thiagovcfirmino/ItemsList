# Organizer App

An AI-powered inventory tracking Flutter app for iOS and Android that helps users keep track of items they own.

## Overview

Organizer helps users manage their personal inventory by allowing them to catalog items with photos and details. The app uses AI to automatically detect if a user already owns an item when they take a picture of it in a store, preventing duplicate purchases.

## Key Features

### Core Functionality
- **AI-Powered Duplicate Detection**: Take a photo of an item and instantly check if you already own it or something similar
- **Multiple Lists/Categories**: Organize items into custom lists (e.g., Christmas ornaments, vases, decor, pencils)
- **Rich Item Details**:
  - Photo(s) of the item
  - Type/Category
  - Acquisition method (Bought/Gift)
  - Year acquired
  - Value (optional, not required for gifts)
  
### User Experience
- Clean, modern UI inspired by contemporary e-commerce design patterns
- Easy photo capture and upload
- Quick search and filtering
- Visual browsing of inventory

## Use Cases

**Primary Use Case**: Shopping Assistant
- User is at a store and sees an item they like (e.g., Christmas ornament)
- Take a photo with the app
- AI checks inventory for duplicates or similar items
- User can make an informed purchase decision

**Secondary Use Cases**:
- Home inventory management
- Gift tracking
- Collection cataloging
- Insurance documentation

## Technical Stack

- **Framework**: Flutter (iOS & Android)
- **AI/ML**: Image recognition and similarity detection
- **Database**: Local storage with cloud sync capability
- **Camera**: Device camera integration

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── item.dart
│   ├── list.dart
│   └── user.dart
├── screens/                  # UI screens
│   ├── home/
│   ├── lists/
│   ├── item_detail/
│   ├── camera/
│   └── search/
├── widgets/                  # Reusable widgets
│   ├── item_card.dart
│   ├── list_card.dart
│   └── custom_app_bar.dart
├── services/                 # Business logic
│   ├── ai_service.dart
│   ├── database_service.dart
│   ├── camera_service.dart
│   └── storage_service.dart
├── utils/                    # Utilities
│   ├── constants.dart
│   ├── theme.dart
│   └── helpers.dart
└── providers/               # State management
    ├── items_provider.dart
    └── lists_provider.dart
```

## Design Inspiration

The app follows modern design principles with:
- Clean, minimalist interface
- Card-based layouts for items
- Prominent imagery
- Intuitive navigation
- Smooth transitions and animations

Inspired by: [Furniture E-Commerce App](https://dribbble.com/shots/26804818-Furniture-E-Commerce-App)

## Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- iOS/Android development environment
- Device or emulator for testing

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

## Development Roadmap

### Phase 1: Core Setup
- [x] Initialize Flutter project
- [ ] Set up project structure
- [ ] Implement data models
- [ ] Design app theme and UI components

### Phase 2: Basic Features
- [ ] Create list management (CRUD)
- [ ] Add item management (CRUD)
- [ ] Implement camera integration
- [ ] Build item detail screen

### Phase 3: AI Integration
- [ ] Integrate image recognition API/service
- [ ] Implement similarity detection
- [ ] Build duplicate checking feature
- [ ] Add confidence scoring

### Phase 4: Polish & Launch
- [ ] User testing and feedback
- [ ] Performance optimization
- [ ] App store preparation
- [ ] Launch on iOS and Android

## Documentation

- [Project Structure](PROJECT_STRUCTURE.md) - Detailed architecture and file organization
- [AI Integration](AI_INTEGRATION.md) - AI/ML implementation details
- [Design System](DESIGN_SYSTEM.md) - UI/UX guidelines and components
- [Development Guide](DEVELOPMENT_GUIDE.md) - Setup and development workflow

## License

TBD

## Contact

TBD
