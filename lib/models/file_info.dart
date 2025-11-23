class FileInfo {
  final int? id;
  final String name;
  final String fileName; // اسم ملف قاعدة البيانات
  final String? password;
  final DateTime createdAt;
  final DateTime lastAccessed;
  final bool isDefault;

  FileInfo({
    this.id,
    required this.name,
    required this.fileName,
    this.password,
    required this.createdAt,
    required this.lastAccessed,
    this.isDefault = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'fileName': fileName,
      'password': password,
      'createdAt': createdAt.toIso8601String(),
      'lastAccessed': lastAccessed.toIso8601String(),
      'isDefault': isDefault ? 1 : 0,
    };
  }

  factory FileInfo.fromMap(Map<String, dynamic> map) {
    return FileInfo(
      id: map['id'],
      name: map['name'],
      fileName: map['fileName'],
      password: map['password'],
      createdAt: DateTime.parse(map['createdAt']),
      lastAccessed: DateTime.parse(map['lastAccessed']),
      isDefault: map['isDefault'] == 1,
    );
  }

  FileInfo copyWith({
    int? id,
    String? name,
    String? fileName,
    String? password,
    DateTime? createdAt,
    DateTime? lastAccessed,
    bool? isDefault,
  }) {
    return FileInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      fileName: fileName ?? this.fileName,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
      lastAccessed: lastAccessed ?? this.lastAccessed,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  bool get hasPassword => password != null && password!.isNotEmpty;
} 