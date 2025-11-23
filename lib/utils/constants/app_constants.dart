class AppConstants {
  // App Info
  static const String appName = 'Organizer';
  static const String appVersion = '1.0.0';
  
  // Database
  static const String databaseName = 'organizer.db';
  static const int databaseVersion = 1;
  
  // Tables
  static const String tableItems = 'items';
  static const String tableLists = 'lists';
  
  // Image Settings
  static const int maxImageSize = 1024; // Max width/height in pixels
  static const int imageQuality = 85; // JPEG quality (0-100)
  static const int thumbnailSize = 200; // Thumbnail size
  
  // AI Settings
  static const double similarityThreshold = 0.7; // 70% similarity threshold
  static const int maxSimilarResults = 5; // Maximum similar items to show
  
  // UI Settings
  static const int gridCrossAxisCount = 2; // Number of columns in grid
  static const double gridSpacing = 12.0;
  static const double cardElevation = 2.0;
  static const double cardRadius = 12.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 150);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Pagination
  static const int itemsPerPage = 20;
  
  // Validation
  static const int minNameLength = 1;
  static const int maxNameLength = 100;
  static const int maxDescriptionLength = 500;
  
  // Error Messages
  static const String errorLoadingData = 'Failed to load data';
  static const String errorSavingData = 'Failed to save data';
  static const String errorDeletingData = 'Failed to delete data';
  static const String errorNoCamera = 'No camera available';
  static const String errorImagePicker = 'Failed to pick image';
  
  // Success Messages
  static const String successSaved = 'Saved successfully';
  static const String successDeleted = 'Deleted successfully';
  static const String successUpdated = 'Updated successfully';
}
