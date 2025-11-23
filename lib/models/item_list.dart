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
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      coverImagePath: map['coverImagePath'] as String?,
      itemCount: map['itemCount'] as int? ?? 0,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
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

  @override
  String toString() {
    return 'ItemList(id: $id, name: $name, itemCount: $itemCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ItemList && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
