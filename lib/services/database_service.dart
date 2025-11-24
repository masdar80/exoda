import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction.dart' as model;
import '../models/entity.dart';
import '../models/expense_type.dart';
import '../models/currency.dart';
import '../models/budget.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import '../services/file_manager_service.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();

    // استخدام اسم الملف الحالي أو الافتراضي
    final fileManagerService = FileManagerService();
    String dbFileName = 'exoda.db'; // الافتراضي للتوافق مع النسخة القديمة

    final currentFileName = fileManagerService.getCurrentFileName();
    if (currentFileName != null) {
      dbFileName = currentFileName;
    }

    final path = join(databasesPath, dbFileName);
    print("📂 مسار قاعدة البيانات: $path");
    print("📁 اسم الملف المستخدم: $dbFileName");

    return await openDatabase(
      path,
      version: 5, // Increased version to add currencies table
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create transactions table
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        direction TEXT NOT NULL,
        paymentMethod TEXT NOT NULL,
        amount REAL NOT NULL,
        entity TEXT NOT NULL,
        subcategory TEXT NOT NULL,
        date TEXT NOT NULL,
        type TEXT NOT NULL,
        notes TEXT
      )
    ''');

    // Create entities table
    await db.execute('''
      CREATE TABLE entities (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        parentId TEXT,
        isSubcategory INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Create expense_types table
    await db.execute('''
      CREATE TABLE expense_types (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');

    // Create payment_methods table
    await db.execute('''
      CREATE TABLE payment_methods (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');

    // Create settings table
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // Create currencies table
    await db.execute('''
      CREATE TABLE currencies (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT NOT NULL UNIQUE,
        name_ar TEXT NOT NULL,
        name_en TEXT NOT NULL,
        exchange_rate_to_usd REAL NOT NULL DEFAULT 1.0,
        is_default INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Insert default data
    await _insertDefaultData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('ترقية قاعدة البيانات من الإصدار $oldVersion إلى $newVersion');

    if (oldVersion < 3) {
      // Add currencies table if it doesn't exist
      await db.execute('''
        CREATE TABLE IF NOT EXISTS currencies (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          code TEXT NOT NULL UNIQUE,
          name_ar TEXT NOT NULL,
          name_en TEXT NOT NULL,
          exchange_rate_to_usd REAL NOT NULL DEFAULT 1.0,
          is_default INTEGER NOT NULL DEFAULT 0
        )
      ''');
      if (oldVersion < 4) {
        // Add budgets table
        await db.execute('''
        CREATE TABLE IF NOT EXISTS budgets (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          category TEXT NOT NULL,
          amount REAL NOT NULL,
          month INTEGER NOT NULL,
          year INTEGER NOT NULL,
          created_at TEXT NOT NULL,
          UNIQUE(category, month, year)
        )
      ''');
        print('تم إضافة جدول الميزانيات');
      }
      // Insert default currencies
      await _insertDefaultCurrencies(db);
    }
  }

  Future<void> _insertDefaultData(Database db) async {
    // Insert default payment methods
    await db.insert('payment_methods', {'name': 'كاش'});
    await db.insert('payment_methods', {'name': 'فيزا'});

    // Insert default expense types
    final defaultTypes = [
      'الأسرة',
      'الأب',
      'الأم',
      'الولد الأول',
      'الولد الثاني',
      'السيارة',
      'البناء',
      'الجد',
      'الجدة',
      'متنوع'
    ];
    for (String type in defaultTypes) {
      await db.insert('expense_types', {'name': type});
    }

    // Insert default payment entities
    final defaultPaymentEntities = [
      'سوبر ماركت',
      'مطعم',
      'ملابس',
      'مواصلات',
      'فواتير',
      'صيدلية',
      'مستشفى',
      'تعليم',
      'ترفيه',
      'آخر'
    ];
    for (String entity in defaultPaymentEntities) {
      await db.insert(
          'entities', {'name': entity, 'type': 'payment', 'isSubcategory': 0});
    }

    // Insert default receipt entities
    final defaultReceiptEntities = [
      'راتب شهري',
      'سلفة على الراتب',
      'أجر عمل',
      'هدية',
      'عيدية',
      'آخر'
    ];
    for (String entity in defaultReceiptEntities) {
      await db.insert(
          'entities', {'name': entity, 'type': 'receipt', 'isSubcategory': 0});
    }

    // Insert subcategories for supermarket
    final supermarketSubcategories = ['كارفور', 'لولو', 'نيستو'];
    for (String subcategory in supermarketSubcategories) {
      await db.insert('entities', {
        'name': subcategory,
        'type': 'payment',
        'parentId': 'سوبر ماركت',
        'isSubcategory': 1
      });
    }

    // Insert default settings
    await db.insert('settings', {'key': 'language', 'value': 'ar'});
    await db.insert('settings', {'key': 'currency', 'value': 'SAR'});
    await db.insert('settings', {'key': 'app_version', 'value': '1.0.0'});

    // Insert default currencies
    await _insertDefaultCurrencies(db);
  }

  Future<void> _insertDefaultCurrencies(Database db) async {
    // Check if currencies already exist
    final existing = await db.query('currencies');
    if (existing.isNotEmpty) {
      print('العملات موجودة بالفعل، عدد: ${existing.length}');
      return;
    }

    final defaultCurrencies = [
      {
        'code': 'SAR',
        'name_ar': 'ريال سعودي',
        'name_en': 'Saudi Riyal',
        'exchange_rate_to_usd': 0.27,
        'is_default': 1
      },
      {
        'code': 'USD',
        'name_ar': 'دولار أمريكي',
        'name_en': 'US Dollar',
        'exchange_rate_to_usd': 1.0,
        'is_default': 0
      },
      {
        'code': 'EUR',
        'name_ar': 'يورو',
        'name_en': 'Euro',
        'exchange_rate_to_usd': 1.1,
        'is_default': 0
      },
      {
        'code': 'AED',
        'name_ar': 'درهم إماراتي',
        'name_en': 'UAE Dirham',
        'exchange_rate_to_usd': 0.27,
        'is_default': 0
      },
      {
        'code': 'OMR',
        'name_ar': 'ريال عماني',
        'name_en': 'Omani Rial',
        'exchange_rate_to_usd': 2.6,
        'is_default': 0
      },
      {
        'code': 'KWD',
        'name_ar': 'دينار كويتي',
        'name_en': 'Kuwaiti Dinar',
        'exchange_rate_to_usd': 3.3,
        'is_default': 0
      },
      {
        'code': 'SYP',
        'name_ar': 'ليرة سورية',
        'name_en': 'Syrian Pound',
        'exchange_rate_to_usd': 0.0004,
        'is_default': 0
      },
    ];

    for (var currency in defaultCurrencies) {
      try {
        await db.insert('currencies', currency);
        print('تم إدراج العملة: ${currency['code']}');
      } catch (e) {
        print('خطأ في إدراج العملة ${currency['code']}: $e');
      }
    }
  }

  // Transaction operations
  Future<int> insertTransaction(model.Transaction transaction) async {
    final db = await database;
    print(
        'إدراج معاملة: ${transaction.direction} - ${transaction.entity} - ${transaction.amount}');
    final result = await db.insert('transactions', transaction.toMap());
    print('تم إدراج المعاملة برقم ID: $result');
    return result;
  }

  Future<List<model.Transaction>> getTransactions({
    String? direction,
    String? paymentMethod,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await database;

    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (direction != null) {
      whereClause += 'direction = ?';
      whereArgs.add(direction);
    }

    if (paymentMethod != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'paymentMethod = ?';
      whereArgs.add(paymentMethod);
    }

    if (startDate != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'date >= ?';
      whereArgs.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      // إضافة 23:59:59 للتاريخ النهائي لتشمل اليوم كاملاً
      final endDateWithTime =
          DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
      whereClause += 'date <= ?';
      whereArgs.add(endDateWithTime.toIso8601String());
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereClause.isNotEmpty ? whereArgs : null,
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return model.Transaction.fromMap(maps[i]);
    });
  }

  Future<List<model.Transaction>> getRecentTransactions({int limit = 5}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      orderBy: 'date DESC',
      limit: limit,
    );

    return List.generate(maps.length, (i) {
      return model.Transaction.fromMap(maps[i]);
    });
  }

  Future<int> updateTransaction(model.Transaction transaction) async {
    final db = await database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<double> getTotalExpensesForMonth(DateTime date) async {
    final db = await database;
    final startDate = DateTime(date.year, date.month, 1).toIso8601String();
    final endDate = DateTime(date.year, date.month + 1, 0).toIso8601String();

    final result = await db.rawQuery('''
      SELECT SUM(amount) as total 
      FROM transactions 
      WHERE direction = 'payment' 
      AND date >= ? AND date <= ?
    ''', [startDate, endDate]);

    if (result.isNotEmpty && result.first['total'] != null) {
      return result.first['total'] as double;
    }
    return 0.0;
  }

  Future<List<Map<String, dynamic>>> getYearlySummary(int year) async {
    final db = await database;
    final startDate = DateTime(year, 1, 1).toIso8601String();
    final endDate = DateTime(year, 12, 31).toIso8601String();

    // Get payments (expenses)
    final paymentsResult = await db.rawQuery('''
      SELECT strftime('%m', date) as month, SUM(amount) as total 
      FROM transactions 
      WHERE direction = 'payment' 
      AND date >= ? AND date <= ?
      GROUP BY strftime('%m', date)
    ''', [startDate, endDate]);

    // Get receipts (income)
    final receiptsResult = await db.rawQuery('''
      SELECT strftime('%m', date) as month, SUM(amount) as total 
      FROM transactions 
      WHERE direction = 'receipt' 
      AND date >= ? AND date <= ?
      GROUP BY strftime('%m', date)
    ''', [startDate, endDate]);

    // Combine data
    List<Map<String, dynamic>> summary = [];
    for (int i = 1; i <= 12; i++) {
      double expense = 0;
      double income = 0;

      // Find expense for this month
      final expenseRow = paymentsResult.firstWhere(
        (row) => int.parse(row['month'] as String) == i,
        orElse: () => {'total': 0.0},
      );
      expense = (expenseRow['total'] as num?)?.toDouble() ?? 0.0;

      // Find income for this month
      final incomeRow = receiptsResult.firstWhere(
        (row) => int.parse(row['month'] as String) == i,
        orElse: () => {'total': 0.0},
      );
      income = (incomeRow['total'] as num?)?.toDouble() ?? 0.0;

      summary.add({
        'month': i,
        'expense': expense,
        'income': income,
      });
    }
    return summary;
  }

  Future<int> insertEntity(Entity entity) async {
    final db = await database;
    return await db.insert('entities', entity.toMap());
  }

  Future<List<Entity>> getEntities(String type) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'entities',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Entity.fromMap(maps[i]));
  }

  Future<List<Entity>> getSubcategories(String parentName) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'entities',
      where: 'parentId = ? AND isSubcategory = 1',
      whereArgs: [parentName],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Entity.fromMap(maps[i]));
  }

  // Check if entity has related transactions before deletion
  Future<bool> hasRelatedTransactions(String entityName, String? type) async {
    final db = await database;
    final result = await db.query(
      'transactions',
      where: 'entity = ? OR subcategory = ?',
      whereArgs: [entityName, entityName],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  // Safe delete entity with transaction check
  Future<Map<String, dynamic>> safeDeleteEntity(int id) async {
    final db = await database;

    // Get entity details first
    final entityResult = await db.query(
      'entities',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (entityResult.isEmpty) {
      return {
        'success': false,
        'error': 'الجهة غير موجودة',
      };
    }

    final entityName = entityResult.first['name'] as String;

    // Check for related transactions
    final hasRelated = await hasRelatedTransactions(entityName, null);
    if (hasRelated) {
      return {
        'success': false,
        'error': 'لا يمكن حذف هذه الجهة لأنها مرتبطة بمعاملات موجودة',
      };
    }

    // Delete the entity
    final deletedRows =
        await db.delete('entities', where: 'id = ?', whereArgs: [id]);

    return {
      'success': true,
      'deletedRows': deletedRows,
    };
  }

  Future<int> deleteEntity(int id) async {
    final db = await database;
    return await db.delete('entities', where: 'id = ?', whereArgs: [id]);
  }

  // ExpenseType operations
  Future<int> insertExpenseType(ExpenseType expenseType) async {
    final db = await database;
    return await db.insert('expense_types', expenseType.toMap());
  }

  Future<List<ExpenseType>> getExpenseTypes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expense_types',
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => ExpenseType.fromMap(maps[i]));
  }

  // Check if expense type has related transactions
  Future<bool> hasRelatedTransactionsForType(String typeName) async {
    final db = await database;
    final result = await db.query(
      'transactions',
      where: 'type = ?',
      whereArgs: [typeName],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  // Safe delete expense type with transaction check
  Future<Map<String, dynamic>> safeDeleteExpenseType(int id) async {
    final db = await database;

    // Get type details first
    final typeResult = await db.query(
      'expense_types',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (typeResult.isEmpty) {
      return {
        'success': false,
        'error': 'النوع غير موجود',
      };
    }

    final typeName = typeResult.first['name'] as String;

    // Check for related transactions
    final hasRelated = await hasRelatedTransactionsForType(typeName);
    if (hasRelated) {
      return {
        'success': false,
        'error': 'لا يمكن حذف هذا النوع لأنه مرتبط بمعاملات موجودة',
      };
    }

    // Delete the type
    final deletedRows =
        await db.delete('expense_types', where: 'id = ?', whereArgs: [id]);

    return {
      'success': true,
      'deletedRows': deletedRows,
    };
  }

  Future<int> deleteExpenseType(int id) async {
    final db = await database;
    return await db.delete('expense_types', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateExpenseType(ExpenseType expenseType) async {
    final db = await database;
    return await db.update(
      'expense_types',
      expenseType.toMap(),
      where: 'id = ?',
      whereArgs: [expenseType.id],
    );
  }

  // Payment method operations
  Future<List<String>> getPaymentMethods() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'payment_methods',
      orderBy: 'name ASC',
    );
    return maps.map((map) => map['name'] as String).toList();
  }

  // Check if payment method has related transactions
  Future<bool> hasRelatedTransactionsForPaymentMethod(String methodName) async {
    final db = await database;
    final result = await db.query(
      'transactions',
      where: 'paymentMethod = ?',
      whereArgs: [methodName],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  // Safe delete payment method with transaction check
  Future<Map<String, dynamic>> safeDeletePaymentMethod(String name) async {
    final db = await database;

    // Check for related transactions
    final hasRelated = await hasRelatedTransactionsForPaymentMethod(name);
    if (hasRelated) {
      return {
        'success': false,
        'error': 'لا يمكن حذف طريقة الدفع هذه لأنها مرتبطة بمعاملات موجودة',
      };
    }

    // Delete the payment method
    final deletedRows = await db
        .delete('payment_methods', where: 'name = ?', whereArgs: [name]);

    return {
      'success': true,
      'deletedRows': deletedRows,
    };
  }

  Future<int> insertPaymentMethod(String name) async {
    final db = await database;
    return await db.insert('payment_methods', {'name': name});
  }

  Future<int> deletePaymentMethod(String name) async {
    final db = await database;
    return await db
        .delete('payment_methods', where: 'name = ?', whereArgs: [name]);
  }

  // Backup and restore
  Future<String> getDatabasePath() async {
    final dbPath = await getDatabasesPath();
    return join(dbPath, 'exoda.db');
  }

  // Close database connection
  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  // Initialize database (for use after importing)
  Future<void> initDatabase() async {
    _database = null; // Reset database instance
    await database; // This will trigger initialization
  }

  Future<void> restoreDatabase(String backupPath) async {
    await _database?.close();
    _database = null;

    final databasesPath = await getDatabasesPath();
    final currentPath = join(databasesPath, 'exoda.db');

    // Copy backup file to database location
    // This would be implemented with file operations
  }

  // Export to Excel (transactions only)
  Future<String> exportToExcel() async {
    final transactions = await getTransactions();

    final excel = Excel.createExcel();

    // Main data sheet
    final dataSheet = excel['المعاملات'];

    // Add headers
    dataSheet.appendRow([
      TextCellValue('التاريخ'),
      TextCellValue('الاتجاه'),
      TextCellValue('الجهة'),
      TextCellValue('المبلغ'),
      TextCellValue('طريقة الدفع'),
      TextCellValue('النوع'),
      TextCellValue('ملاحظات'),
    ]);

    // Add transaction data
    for (var transaction in transactions) {
      dataSheet.appendRow([
        TextCellValue(DateFormat('dd/MM/yyyy').format(transaction.date)),
        TextCellValue(transaction.direction == 'payment' ? 'دفع' : 'قبض'),
        TextCellValue(transaction.entity),
        DoubleCellValue(transaction.amount),
        TextCellValue(transaction.paymentMethod),
        TextCellValue(transaction.type),
        TextCellValue(transaction.notes ?? ''),
      ]);
    }

    // Save to temporary directory
    final tempDir = await getTemporaryDirectory();
    final fileName =
        'exoda_transactions_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
    final filePath = '${tempDir.path}/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(excel.encode()!);

    return filePath;
  }

  // Export database file
  Future<String> exportDatabaseFile() async {
    final tempDir = await getTemporaryDirectory();
    final fileName =
        'exoda_backup_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.db';
    final filePath = '${tempDir.path}/$fileName';

    // Get current database path
    final currentDbPath = await getDatabasePath();
    final currentDbFile = File(currentDbPath);

    // Copy database to temp directory
    await currentDbFile.copy(filePath);

    return filePath;
  }

  // Switch to different database file
  Future<void> switchToFile(String fileName) async {
    print('🔄 تبديل قاعدة البيانات إلى: $fileName');
    await closeDatabase();
    final fileManager = FileManagerService();
    fileManager.setCurrentFile(fileName);
    _database = null;
    print('🔄 إعادة تهيئة قاعدة البيانات...');
    await database; // This will reinitialize with new file
    print('✅ تم تبديل قاعدة البيانات بنجاح إلى: $fileName');
  }

  // Settings methods
  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('تم حفظ الإعداد: $key = $value');
  }

  Future<String?> getSetting(String key) async {
    final db = await database;
    final result = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );

    if (result.isNotEmpty) {
      final value = result.first['value'] as String;
      print('تم قراءة الإعداد: $key = $value');
      return value;
    }

    print('الإعداد غير موجود: $key');
    return null;
  }

  Future<Map<String, String>> getAllSettings() async {
    final db = await database;
    final result = await db.query('settings');

    Map<String, String> settings = {};
    for (var row in result) {
      settings[row['key'] as String] = row['value'] as String;
    }

    print('تم قراءة جميع الإعدادات: ${settings.length} إعداد');
    return settings;
  }

  Future<Map<String, dynamic>> getDatabaseDiagnostics() async {
    final db = await database;

    Map<String, dynamic> diagnostics = {};

    try {
      // Get database version
      final versionResult = await db.rawQuery('PRAGMA user_version');
      diagnostics['database_version'] = versionResult.first['user_version'];

      // Get table schema information
      final tablesResult = await db
          .rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
      diagnostics['tables'] = tablesResult.map((row) => row['name']).toList();

      // Get transactions table schema
      try {
        final transactionsSchema =
            await db.rawQuery("PRAGMA table_info(transactions)");
        diagnostics['transactions_schema'] = transactionsSchema;
      } catch (e) {
        diagnostics['transactions_schema_error'] = e.toString();
      }

      // Count records in each table
      for (String table in [
        'transactions',
        'entities',
        'expense_types',
        'payment_methods',
        'settings'
      ]) {
        try {
          final count =
              await db.rawQuery('SELECT COUNT(*) as count FROM $table');
          diagnostics['${table}_count'] = count.first['count'];
        } catch (e) {
          diagnostics['${table}_error'] = e.toString();
        }
      }

      // Recent transactions
      try {
        final recentTransactions =
            await db.query('transactions', orderBy: 'id DESC', limit: 3);
        diagnostics['recent_transactions'] = recentTransactions;
      } catch (e) {
        diagnostics['recent_transactions_error'] = e.toString();
      }

      // All payment methods
      try {
        final paymentMethods = await db.query('payment_methods');
        diagnostics['payment_methods'] = paymentMethods;
      } catch (e) {
        diagnostics['payment_methods_error'] = e.toString();
      }

      // All settings
      try {
        final settings = await db.query('settings');
        diagnostics['settings'] = settings;
      } catch (e) {
        diagnostics['settings_error'] = e.toString();
      }

      print('تشخيص قاعدة البيانات:');
      print('- إصدار قاعدة البيانات: ${diagnostics['database_version']}');
      print('- الجداول الموجودة: ${diagnostics['tables']}');
      print('- المعاملات: ${diagnostics['transactions_count'] ?? 'خطأ'}');
      print('- الجهات: ${diagnostics['entities_count'] ?? 'خطأ'}');
      print('- أنواع المصاريف: ${diagnostics['expense_types_count'] ?? 'خطأ'}');
      print('- طرق الدفع: ${diagnostics['payment_methods_count'] ?? 'خطأ'}');
      print('- الإعدادات: ${diagnostics['settings_count'] ?? 'خطأ'}');
    } catch (e) {
      diagnostics['error'] = 'خطأ في التشخيص: $e';
      print('خطأ في تشخيص قاعدة البيانات: $e');
    }

    return diagnostics;
  }

  // Currency operations
  Future<int> insertCurrency(Currency currency) async {
    final db = await database;
    return await db.insert('currencies', currency.toMap());
  }

  Future<List<Currency>> getCurrencies() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'currencies',
      orderBy: 'is_default DESC, name_ar ASC',
    );
    return List.generate(maps.length, (i) => Currency.fromMap(maps[i]));
  }

  Future<Currency?> getDefaultCurrency() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'currencies',
      where: 'is_default = 1',
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Currency.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateCurrency(Currency currency) async {
    final db = await database;
    return await db.update(
      'currencies',
      currency.toMap(),
      where: 'id = ?',
      whereArgs: [currency.id],
    );
  }

  Future<int> deleteCurrency(int id) async {
    final db = await database;
    return await db.delete('currencies', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> setDefaultCurrency(int currencyId) async {
    final db = await database;
    // Remove default from all currencies
    await db.update(
      'currencies',
      {'is_default': 0},
    );
    // Set new default
    await db.update(
      'currencies',
      {'is_default': 1},
      where: 'id = ?',
      whereArgs: [currencyId],
    );
  }

  Future<Currency?> getCurrencyByCode(String code) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'currencies',
      where: 'code = ?',
      whereArgs: [code],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Currency.fromMap(maps.first);
    }
    return null;
  }

  Future<double> convertCurrency(
      double amount, String fromCurrency, String toCurrency) async {
    if (fromCurrency == toCurrency) return amount;

    final fromCur = await getCurrencyByCode(fromCurrency);
    final toCur = await getCurrencyByCode(toCurrency);

    if (fromCur == null || toCur == null) return amount;

    // Convert to USD first, then to target currency
    final usdAmount = amount * fromCur.exchangeRateToUsd;
    return usdAmount / toCur.exchangeRateToUsd;
  }

  // Get parent categories only
  Future<List<Entity>> getParentCategories(String type) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'entities',
      where: 'type = ? AND isSubcategory = 0',
      whereArgs: [type],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Entity.fromMap(maps[i]));
  }

  // Export transactions only to Excel (simplified version)
  Future<String> exportTransactionsToExcel() async {
    final db = await database;

    // Get all transactions
    final transactions = await db.query('transactions', orderBy: 'date DESC');

    // Create Excel workbook
    final excel = Excel.createExcel();
    final sheet = excel['المعاملات'];

    // Add headers
    sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('الرقم');
    sheet.cell(CellIndex.indexByString('B1')).value = TextCellValue('التاريخ');
    sheet.cell(CellIndex.indexByString('C1')).value = TextCellValue('النوع');
    sheet.cell(CellIndex.indexByString('D1')).value = TextCellValue('الجهة');
    sheet.cell(CellIndex.indexByString('E1')).value = TextCellValue('المبلغ');
    sheet.cell(CellIndex.indexByString('F1')).value =
        TextCellValue('طريقة الدفع');
    sheet.cell(CellIndex.indexByString('G1')).value =
        TextCellValue('الملاحظات');

    // Add transaction data
    for (int i = 0; i < transactions.length; i++) {
      final tx = transactions[i];
      final row = i + 2; // Start from row 2 (after headers)

      sheet.cell(CellIndex.indexByString('A$row')).value =
          IntCellValue(tx['id'] as int);
      sheet.cell(CellIndex.indexByString('B$row')).value =
          TextCellValue(tx['date'].toString());
      sheet.cell(CellIndex.indexByString('C$row')).value =
          TextCellValue(tx['direction'].toString());
      sheet.cell(CellIndex.indexByString('D$row')).value =
          TextCellValue(tx['entity'].toString());
      sheet.cell(CellIndex.indexByString('E$row')).value =
          DoubleCellValue(tx['amount'] as double);
      sheet.cell(CellIndex.indexByString('F$row')).value =
          TextCellValue(tx['paymentMethod'].toString());
      sheet.cell(CellIndex.indexByString('G$row')).value =
          TextCellValue((tx['notes'] ?? '').toString());
    }

    // Save to file
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
    final fileName = 'exoda_transactions_$timestamp.xlsx';
    final filePath = '${directory.path}/$fileName';

    final fileBytes = excel.save();
    final file = File(filePath);
    await file.writeAsBytes(fileBytes!);

    print('تم تصدير ${transactions.length} معاملة إلى: $filePath');
    return filePath;
  }

  // Import transactions from Excel
  Future<Map<String, dynamic>> importFromExcelPreview(String filePath) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final excel = Excel.decodeBytes(bytes);
      final sheet = excel.tables.values.first;
      if (sheet.maxRows < 2) return {'transactions': [], 'unknownEntities': []};
      final headerRow = sheet
          .row(0)
          .map((cell) => cell?.value?.toString()?.trim() ?? '')
          .toList();
      int idxPaymentMethod = headerRow.indexWhere(
          (h) => h == 'طريقة الدفع' || h.toLowerCase().contains('payment'));
      int idxAmount = headerRow.indexWhere(
          (h) => h == 'المبلغ' || h.toLowerCase().contains('amount'));
      int idxPayEntity = headerRow.indexWhere(
          (h) => h == 'جهة مدفوعات' || h.toLowerCase().contains('pay'));
      int idxReceiveEntity = headerRow.indexWhere(
          (h) => h == 'جهة مقبوضات' || h.toLowerCase().contains('receive'));
      int idxDate = headerRow.indexWhere((h) => h == 'date' || h == 'التاريخ');
      if (idxAmount == -1 ||
          idxDate == -1 ||
          (idxPayEntity == -1 && idxReceiveEntity == -1))
        return {'transactions': [], 'unknownEntities': []};
      final List<Map<String, dynamic>> transactions = [];
      final Set<String> unknownEntities = {};
      // اجلب جميع الجهات الحالية
      final allEntities = [
        ...(await getEntities('payment')).map((e) => e.name),
        ...(await getEntities('receipt')).map((e) => e.name),
      ];
      for (int i = 1; i < sheet.maxRows; i++) {
        final row = sheet.row(i);
        final amountStr = idxAmount >= 0 && idxAmount < row.length
            ? row[idxAmount]?.value
            : null;
        final paymentMethod =
            idxPaymentMethod >= 0 && idxPaymentMethod < row.length
                ? row[idxPaymentMethod]?.value?.toString() ?? ''
                : '';
        final payEntity = idxPayEntity >= 0 && idxPayEntity < row.length
            ? row[idxPayEntity]?.value?.toString() ?? ''
            : '';
        final receiveEntity =
            idxReceiveEntity >= 0 && idxReceiveEntity < row.length
                ? row[idxReceiveEntity]?.value?.toString() ?? ''
                : '';
        final dateStr = idxDate >= 0 && idxDate < row.length
            ? row[idxDate]?.value?.toString() ?? ''
            : '';
        final amount = double.tryParse(amountStr?.toString() ?? '') ?? 0;
        if (amount == 0) continue;
        String direction = '';
        String entityName = '';
        if (payEntity.isNotEmpty) {
          direction = 'payment';
          entityName = payEntity;
        } else if (receiveEntity.isNotEmpty) {
          direction = 'receipt';
          entityName = receiveEntity;
        } else {
          continue;
        }
        if (!allEntities.contains(entityName)) {
          unknownEntities.add(entityName);
        }
        transactions.add({
          'direction': direction,
          'paymentMethod': paymentMethod,
          'amount': amount,
          'entity': entityName,
          'subcategory': entityName,
          'date': dateStr,
          'type': '',
          'notes': '',
        });
      }
      return {
        'transactions': transactions,
        'unknownEntities': unknownEntities.toList(),
      };
    } catch (e) {
      throw Exception('خطأ في قراءة الملف: $e');
    }
  }

  // البحث عن جهة باسمها ونوعها
  Future<Entity?> findEntityByName(String name, String type) async {
    final db = await database;
    final result = await db.query(
      'entities',
      where: 'name = ? AND type = ?',
      whereArgs: [name, type],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return Entity.fromMap(result.first);
    }
    return null;
  }

  // إعادة تصفير قاعدة البيانات (حذف جميع البيانات من جميع الجداول)
  Future<void> resetDatabase() async {
    final db = await database;
    await db.delete('transactions');
    await db.delete('entities');
    await db.delete('expense_types');
    await db.delete('payment_methods');
    await db.delete('settings');
    await db.delete('currencies');

    // Re-insert default data
    await _insertDefaultData(db);
  }

  Future<Map<String, double>> getExpensesByType({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await database;

    String whereClause = "direction = 'payment'";
    List<dynamic> whereArgs = [];

    if (startDate != null) {
      whereClause += ' AND date >= ?';
      whereArgs.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      // Add time to end date to include the whole day
      final endDateWithTime =
          DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
      whereClause += ' AND date <= ?';
      whereArgs.add(endDateWithTime.toIso8601String());
    }

    final result = await db.query(
      'transactions',
      columns: ['type', 'amount'],
      where: whereClause,
      whereArgs: whereArgs,
    );

    final Map<String, double> expensesByType = {};

    for (var row in result) {
      final type = row['type'] as String;
      final amount = (row['amount'] as num).toDouble();

      if (type.isNotEmpty) {
        expensesByType[type] = (expensesByType[type] ?? 0) + amount;
      } else {
        expensesByType['غير محدد'] = (expensesByType['غير محدد'] ?? 0) + amount;
      }
    }

    return expensesByType;
  }

  // Budget operations
  Future<int> insertBudget(Budget budget) async {
    final db = await database;
    return await db.insert(
      'budgets',
      budget.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Budget>> getBudgets({int? month, int? year}) async {
    final db = await database;

    String? whereClause;
    List<dynamic>? whereArgs;

    if (month != null && year != null) {
      whereClause = 'month = ? AND year = ?';
      whereArgs = [month, year];
    } else if (year != null) {
      whereClause = 'year = ?';
      whereArgs = [year];
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'budgets',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'category ASC',
    );

    return List.generate(maps.length, (i) => Budget.fromMap(maps[i]));
  }

  Future<Budget?> getBudgetByCategory(
      String category, int month, int year) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'budgets',
      where: 'category = ? AND month = ? AND year = ?',
      whereArgs: [category, month, year],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return Budget.fromMap(maps.first);
  }

  Future<int> updateBudget(Budget budget) async {
    final db = await database;
    return await db.update(
      'budgets',
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  Future<int> deleteBudget(int id) async {
    final db = await database;
    return await db.delete(
      'budgets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Map<String, dynamic>> getBudgetProgress(
      String category, int month, int year) async {
    final db = await database;

    // Get budget
    final budget = await getBudgetByCategory(category, month, year);
    if (budget == null) {
      return {
        'budgetAmount': 0.0,
        'spentAmount': 0.0,
        'remaining': 0.0,
        'percentageUsed': 0.0,
        'isOverBudget': false,
      };
    }

    // Calculate spent amount for this category in this month
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT SUM(amount) as total
      FROM transactions
      WHERE direction = 'payment'
        AND (entity = ? OR subcategory = ?)
        AND date >= ?
        AND date <= ?
    ''', [
      category,
      category,
      startDate.toIso8601String(),
      endDate.toIso8601String()
    ]);

    final double spentAmount =
        (result.first['total'] as num?)?.toDouble() ?? 0.0;
    final double remaining = budget.amount - spentAmount;
    final double percentageUsed =
        budget.amount > 0 ? (spentAmount / budget.amount) * 100 : 0.0;

    return {
      'budgetAmount': budget.amount,
      'spentAmount': spentAmount,
      'remaining': remaining,
      'percentageUsed': percentageUsed,
      'isOverBudget': spentAmount > budget.amount,
    };
  }
}
