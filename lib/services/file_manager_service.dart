import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/file_info.dart';
import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class FileManagerService {
  static final FileManagerService _instance = FileManagerService._internal();
  factory FileManagerService() => _instance;
  FileManagerService._internal();

  static Database? _metaDatabase;
  static String? _currentFileName;

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // قاعدة البيانات الرئيسية لحفظ معلومات الملفات
  Future<Database> get metaDatabase async {
    if (_metaDatabase != null) return _metaDatabase!;
    _metaDatabase = await _initMetaDatabase();
    return _metaDatabase!;
  }

  Future<Database> _initMetaDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'exoda_files.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE files (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            fileName TEXT NOT NULL UNIQUE,
            password TEXT,
            createdAt TEXT NOT NULL,
            lastAccessed TEXT NOT NULL,
            isDefault INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
  }

  // الحصول على قائمة جميع الملفات
  Future<List<FileInfo>> getAllFiles() async {
    final db = await metaDatabase;
    final List<Map<String, dynamic>> maps = await db.query(
      'files',
      orderBy: 'lastAccessed DESC',
    );
    return List.generate(maps.length, (i) => FileInfo.fromMap(maps[i]));
  }

  // إنشاء ملف جديد
  Future<FileInfo> createNewFile(String name, {String? password}) async {
    final now = DateTime.now();
    final fileName = 'exoda_${now.millisecondsSinceEpoch}.db';
    
    final fileInfo = FileInfo(
      name: name,
      fileName: fileName,
      password: password != null ? _hashPassword(password) : null,
      createdAt: now,
      lastAccessed: now,
    );

    final db = await metaDatabase;
    final id = await db.insert('files', fileInfo.toMap());
    
    return fileInfo.copyWith(id: id);
  }

  // الحصول على الملف الافتراضي أو الأحدث
  Future<FileInfo?> getDefaultFile() async {
    final db = await metaDatabase;
    
    // البحث عن الملف الافتراضي أولاً
    final defaultResult = await db.query(
      'files',
      where: 'isDefault = 1',
      limit: 1,
    );
    
    if (defaultResult.isNotEmpty) {
      return FileInfo.fromMap(defaultResult.first);
    }
    
    // إذا لم يوجد ملف افتراضي، أحضر الأحدث
    final latestResult = await db.query(
      'files',
      orderBy: 'lastAccessed DESC',
      limit: 1,
    );
    
    if (latestResult.isNotEmpty) {
      return FileInfo.fromMap(latestResult.first);
    }
    
    return null;
  }

  // تحديث وقت الوصول للملف
  Future<void> updateLastAccessed(int fileId) async {
    final db = await metaDatabase;
    await db.update(
      'files',
      {'lastAccessed': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [fileId],
    );
  }

  // تعيين ملف كافتراضي
  Future<void> setDefaultFile(int fileId) async {
    final db = await metaDatabase;
    
    // إزالة الافتراضي من جميع الملفات
    await db.update(
      'files',
      {'isDefault': 0},
      where: 'isDefault = 1',
    );
    
    // تعيين الملف الجديد كافتراضي
    await db.update(
      'files',
      {'isDefault': 1},
      where: 'id = ?',
      whereArgs: [fileId],
    );
  }

  // التحقق من كلمة المرور
  Future<bool> verifyPassword(int fileId, String? inputPassword) async {
    final db = await metaDatabase;
    final result = await db.query(
      'files',
      where: 'id = ?',
      whereArgs: [fileId],
    );
    
    if (result.isEmpty) return false;
    
    final fileInfo = FileInfo.fromMap(result.first);
    
    // إذا لم تكن هناك كلمة مرور محفوظة
    if (!fileInfo.hasPassword) return true;
    
    // التحقق من كلمة المرور
    if (inputPassword == null) return false;
    return fileInfo.password == _hashPassword(inputPassword);
  }

  // الحصول على مسار ملف قاعدة البيانات
  Future<String> getFilePath(String fileName) async {
    final databasesPath = await getDatabasesPath();
    return join(databasesPath, fileName);
  }

  // حذف ملف
  Future<bool> deleteFile(int fileId) async {
    try {
      final db = await metaDatabase;
      
      // الحصول على معلومات الملف
      final result = await db.query(
        'files',
        where: 'id = ?',
        whereArgs: [fileId],
      );
      
      if (result.isEmpty) return false;
      
      final fileInfo = FileInfo.fromMap(result.first);
      
      // حذف ملف قاعدة البيانات
      final filePath = await getFilePath(fileInfo.fileName);
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
      
      // حذف السجل من قاعدة البيانات الرئيسية
      await db.delete(
        'files',
        where: 'id = ?',
        whereArgs: [fileId],
      );
      
      return true;
    } catch (e) {
      print('خطأ في حذف الملف: $e');
      return false;
    }
  }

  // تحديث معلومات الملف
  Future<void> updateFile(FileInfo fileInfo) async {
    final db = await metaDatabase;
    await db.update(
      'files',
      fileInfo.toMap(),
      where: 'id = ?',
      whereArgs: [fileInfo.id],
    );
  }

  // تعيين الملف الحالي
  void setCurrentFile(String fileName) {
    _currentFileName = fileName;
  }

  // الحصول على الملف الحالي
  String? getCurrentFileName() {
    return _currentFileName;
  }

  // التحقق من وجود ملفات
  Future<bool> hasFiles() async {
    final files = await getAllFiles();
    return files.isNotEmpty;
  }
} 