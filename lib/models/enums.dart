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

extension AcquisitionTypeExtension on AcquisitionType {
  String get displayName {
    switch (this) {
      case AcquisitionType.bought:
        return 'Bought';
      case AcquisitionType.gift:
        return 'Gift';
    }
  }
}

extension SortOptionExtension on SortOption {
  String get displayName {
    switch (this) {
      case SortOption.nameAsc:
        return 'Name (A-Z)';
      case SortOption.nameDesc:
        return 'Name (Z-A)';
      case SortOption.dateAsc:
        return 'Oldest First';
      case SortOption.dateDesc:
        return 'Newest First';
      case SortOption.valueAsc:
        return 'Value (Low to High)';
      case SortOption.valueDesc:
        return 'Value (High to Low)';
    }
  }
}
