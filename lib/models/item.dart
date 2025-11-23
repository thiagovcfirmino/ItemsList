import 'enums.dart';

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
      id: map['id'] as String,
      listId: map['listId'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      imagePaths: (map['imagePaths'] as String).isNotEmpty 
          ? (map['imagePaths'] as String).split(',') 
          : [],
      type: map['type'] as String,
      acquisitionType: AcquisitionType.values[map['acquisitionType'] as int],
      year: map['year'] as int,
      value: map['value'] as double?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
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

  @override
  String toString() {
    return 'Item(id: $id, name: $name, type: $type, year: $year)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Item && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
