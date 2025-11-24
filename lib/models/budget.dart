class Budget {
  final int? id;
  final String category;
  final double amount;
  final int month;
  final int year;
  final DateTime createdAt;

  Budget({
    this.id,
    required this.category,
    required this.amount,
    required this.month,
    required this.year,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'month': month,
      'year': year,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'] as int?,
      category: map['category'] as String,
      amount: (map['amount'] as num).toDouble(),
      month: map['month'] as int,
      year: map['year'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Budget copyWith({
    int? id,
    String? category,
    double? amount,
    int? month,
    int? year,
    DateTime? createdAt,
  }) {
    return Budget(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      month: month ?? this.month,
      year: year ?? this.year,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
