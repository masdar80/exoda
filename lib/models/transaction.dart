class Transaction {
  final int? id;
  final String direction; // 'payment' or 'receipt'
  final String paymentMethod; // 'cash' or 'visa'
  final double amount;
  final String entity;
  final String subcategory; // Made non-nullable to match database
  final DateTime date;
  final String type;
  final String? notes;

  Transaction({
    this.id,
    required this.direction,
    required this.paymentMethod,
    required this.amount,
    required this.entity,
    required this.subcategory, // Made required
    required this.date,
    required this.type,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'direction': direction,
      'paymentMethod': paymentMethod,
      'amount': amount,
      'entity': entity,
      'subcategory': subcategory,
      'date': date.toIso8601String(),
      'type': type,
      'notes': notes,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      direction: map['direction'],
      paymentMethod: map['paymentMethod'],
      amount: (map['amount'] as num).toDouble(),
      entity: map['entity'],
      subcategory: map['subcategory'] ?? '',
      date: DateTime.parse(map['date']),
      type: map['type'],
      notes: map['notes'],
    );
  }

  Transaction copyWith({
    int? id,
    String? direction,
    String? paymentMethod,
    double? amount,
    String? entity,
    String? subcategory,
    DateTime? date,
    String? type,
    String? notes,
  }) {
    return Transaction(
      id: id ?? this.id,
      direction: direction ?? this.direction,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      amount: amount ?? this.amount,
      entity: entity ?? this.entity,
      subcategory: subcategory ?? this.subcategory,
      date: date ?? this.date,
      type: type ?? this.type,
      notes: notes ?? this.notes,
    );
  }
} 