class Currency {
  final int? id;
  final String code;
  final String nameAr;
  final String nameEn;
  final double exchangeRateToUsd;
  final bool isDefault;

  Currency({
    this.id,
    required this.code,
    required this.nameAr,
    required this.nameEn,
    required this.exchangeRateToUsd,
    this.isDefault = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'name_ar': nameAr,
      'name_en': nameEn,
      'exchange_rate_to_usd': exchangeRateToUsd,
      'is_default': isDefault ? 1 : 0,
    };
  }

  factory Currency.fromMap(Map<String, dynamic> map) {
    return Currency(
      id: map['id'],
      code: map['code'],
      nameAr: map['name_ar'],
      nameEn: map['name_en'],
      exchangeRateToUsd: map['exchange_rate_to_usd']?.toDouble() ?? 1.0,
      isDefault: map['is_default'] == 1,
    );
  }
} 