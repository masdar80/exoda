class ExpenseType {
  final int? id;
  final String name;

  ExpenseType({
    this.id,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory ExpenseType.fromMap(Map<String, dynamic> map) {
    return ExpenseType(
      id: map['id'],
      name: map['name'],
    );
  }

  ExpenseType copyWith({
    int? id,
    String? name,
  }) {
    return ExpenseType(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
} 