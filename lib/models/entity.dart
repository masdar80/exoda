class Entity {
  final int? id;
  final String name;
  final String type; // 'payment' or 'receipt'
  final String? parentId;
  final bool isSubcategory;

  Entity({
    this.id,
    required this.name,
    required this.type,
    this.parentId,
    this.isSubcategory = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'parentId': parentId,
      'isSubcategory': isSubcategory ? 1 : 0,
    };
  }

  factory Entity.fromMap(Map<String, dynamic> map) {
    return Entity(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      parentId: map['parentId'],
      isSubcategory: map['isSubcategory'] == 1,
    );
  }

  Entity copyWith({
    int? id,
    String? name,
    String? type,
    String? parentId,
    bool? isSubcategory,
  }) {
    return Entity(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      parentId: parentId ?? this.parentId,
      isSubcategory: isSubcategory ?? this.isSubcategory,
    );
  }
} 