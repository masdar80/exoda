import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../services/database_service.dart';
import '../services/file_manager_service.dart';
import '../models/entity.dart';
import '../models/expense_type.dart';
import 'about_screen.dart';
import 'file_selector_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'map_entities_screen.dart';
import '../models/transaction.dart' as model;
import 'package:share_plus/share_plus.dart';
import 'dart:io';

class SettingsScreen extends StatefulWidget {
  final Function(Locale) onLanguageChange;
  final VoidCallback? onDataChanged;

  const SettingsScreen({
    super.key,
    required this.onLanguageChange,
    this.onDataChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final FileManagerService _fileManager = FileManagerService();
  String _currentLanguage = 'ar';

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguage();
  }

  Future<void> _loadCurrentLanguage() async {
    final language = await _databaseService.getSetting('language') ?? 'ar';
    setState(() {
      _currentLanguage = language;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(tr.settingsTitle),
        backgroundColor: Colors.teal,
      ),
      body: ListView(
        children: [
          _buildFileManagementSection(tr),
          const Divider(),
          _buildLanguageSection(tr),
          const Divider(),
          _buildDataManagementSection(tr),
          const Divider(),
          _buildConfigurationSection(tr),
        ],
      ),
    );
  }

  Widget _buildFileManagementSection(AppLocalizations tr) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr.fileManagement,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.folder_open, color: Colors.blue),
              title: Text(tr.switchFile),
              subtitle: Text(tr.switchFileSubtitle),
              onTap: _switchFile,
            ),
            ListTile(
              leading: const Icon(Icons.create_new_folder, color: Colors.green),
              title: Text(tr.createNewFile),
              subtitle: Text(tr.createNewFileSubtitle),
              onTap: _createNewFile,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSection(AppLocalizations tr) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr.language,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            RadioListTile<String>(
              title: Text(tr.arabic),
              value: 'ar',
              groupValue: _currentLanguage,
              onChanged: (value) => _changeLanguage(value!),
            ),
            RadioListTile<String>(
              title: Text(tr.english),
              value: 'en',
              groupValue: _currentLanguage,
              onChanged: (value) => _changeLanguage(value!),
            ),
            RadioListTile<String>(
              title: Text(tr.spanish),
              value: 'es',
              groupValue: _currentLanguage,
              onChanged: (value) => _changeLanguage(value!),
            ),
            RadioListTile<String>(
              title: Text(tr.greek),
              value: 'el',
              groupValue: _currentLanguage,
              onChanged: (value) => _changeLanguage(value!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataManagementSection(AppLocalizations tr) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr.dataManagement,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.upload_file, color: Colors.orange),
              title: Text(tr.importFromExcel),
              subtitle: Text(tr.importFromExcelSubtitle),
              onTap: _importFromExcel,
            ),
            ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.green),
              title: Text(tr.exportTransactionsToExcel),
              subtitle: Text(tr.exportTransactionsToExcelSubtitle),
              onTap: _exportTransactionsToExcel,
            ),
            ListTile(
              leading: const Icon(Icons.download, color: Colors.blue),
              title: Text(tr.exportDatabase),
              subtitle: Text(tr.exportDatabaseSubtitle),
              onTap: _exportDatabaseFile,
            ),
            ListTile(
              leading: const Icon(Icons.analytics, color: Colors.purple),
              title: Text(tr.databaseDiagnostics),
              subtitle: Text(tr.databaseDiagnosticsSubtitle),
              onTap: _showDatabaseDiagnostics,
            ),
            ListTile(
              leading: const Icon(Icons.file_open, color: Colors.blueGrey),
              title: Text(tr.importDatabase),
              subtitle: Text(tr.importDatabaseSubtitle),
              onTap: _importDatabaseFile,
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: Text(_currentLanguage == 'ar' 
                ? 'إعادة تصفير قاعدة البيانات'
                : 'Reset Database'),
              subtitle: Text(_currentLanguage == 'ar' 
                ? 'حذف جميع البيانات والإعدادات من الملف الحالي'
                : 'Delete all data and settings from current file'),
              onTap: _confirmResetDatabase,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigurationSection(AppLocalizations tr) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr.appSettings,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.account_box, color: Colors.blue),
              title: Text(tr.manageEntities),
              subtitle: Text(tr.manageEntitiesSubtitle),
              onTap: () => _showEntitiesDialog(),
            ),
            ListTile(
              leading: const Icon(Icons.category, color: Colors.purple),
              title: Text(tr.manageExpenseTypes),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExpenseTypesManagementScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.payment, color: Colors.teal),
              title: Text(tr.managePaymentMethods),
              subtitle: Text(tr.managePaymentMethodsSubtitle),
              onTap: () => _showPaymentMethodsDialog(),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.grey),
              title: Text(tr.aboutApp),
              subtitle: Text(tr.aboutAppSubtitle),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AboutScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _switchFile() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => FileSelectorScreen(
          onFileSelected: (fileName) {
            Navigator.pop(context, fileName);
          },
        ),
      ),
    );

    if (result != null) {
      // تم اختيار ملف جديد، إعادة تحميل البيانات
      await _databaseService.switchToFile(result);
      widget.onDataChanged?.call();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم التبديل إلى الملف بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _createNewFile() async {
    final result = await showDialog<Map<String, String?>>(
      context: context,
      builder: (context) => _CreateNewFileDialog(),
    );

    if (result != null) {
      try {
        final fileInfo = await _fileManager.createNewFile(
          result['name']!,
          password: result['password'],
        );

        // التبديل إلى الملف الجديد
        await _databaseService.switchToFile(fileInfo.fileName);
        
        widget.onDataChanged?.call();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إنشاء الملف الجديد بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في إنشاء الملف: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _changeLanguage(String languageCode) async {
    await _databaseService.setSetting('language', languageCode);
    
    setState(() {
      _currentLanguage = languageCode;
    });
    
    widget.onLanguageChange(Locale(languageCode));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تغيير اللغة'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _exportTransactionsToExcel() async {
    final tr = AppLocalizations.of(context)!;
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                tr.exportTransactionsToExcel,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
      
      final tempPath = await _databaseService.exportTransactionsToExcel();
      Navigator.pop(context);
      
      // اختيار المسار النهائي للحفظ
      final saveResult = await FilePicker.platform.saveFile(
        dialogTitle: _currentLanguage == 'ar' 
          ? 'اختر مكان حفظ ملف Excel'
          : 'Choose location to save Excel file',
        fileName: tempPath.split('/').last,
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );
      
      if (saveResult != null) {
        final tempFile = File(tempPath);
        final destFile = File(saveResult);
        await destFile.writeAsBytes(await tempFile.readAsBytes());
        
        // إظهار رسالة النجاح
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _currentLanguage == 'ar' 
                ? 'تم تصدير الملف بنجاح إلى: $saveResult'
                : 'File exported successfully to: $saveResult'
            ),
            backgroundColor: Colors.green,
          ),
        );
        
        // إظهار خيار المشاركة
        _showShareDialog(saveResult, _currentLanguage == 'ar' 
          ? 'ملف Excel للمعاملات' 
          : 'Excel Transactions File');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _currentLanguage == 'ar' 
                ? 'تم إلغاء الحفظ'
                : 'Save cancelled'
            ),
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _currentLanguage == 'ar' 
              ? 'حدث خطأ في تصدير Excel: $e'
              : 'Error exporting Excel: $e'
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showDatabaseDiagnostics() async {
    try {
      final diagnostics = await _databaseService.getDatabaseDiagnostics();
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('تشخيص قاعدة البيانات'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('📊 المعاملات: ${diagnostics['transactions_count'] ?? 'خطأ'}'),
                  Text('🏢 الجهات: ${diagnostics['entities_count'] ?? 'خطأ'}'),
                  Text('📂 أنواع المصاريف: ${diagnostics['expense_types_count'] ?? 'خطأ'}'),
                  Text('💳 طرق الدفع: ${diagnostics['payment_methods_count'] ?? 'خطأ'}'),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('موافق'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في فحص قاعدة البيانات: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _importFromExcel() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['xlsx']);
      if (result == null || result.files.isEmpty) return;
      final filePath = result.files.single.path;
      if (filePath == null) return;

      // قراءة الحركات ومعرفة الجهات غير المعروفة
      final preview = await _databaseService.importFromExcelPreview(filePath);
      final transactions = preview['transactions'] as List<dynamic>;
      final unknownEntities = preview['unknownEntities'] as List<dynamic>;
      if (transactions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لا توجد بيانات صالحة للاستيراد')),
        );
        return;
      }
      if (unknownEntities.isNotEmpty) {
        // اجلب جميع الجهات المتوفرة
        final availableEntities = [
          ...(await _databaseService.getEntities('payment')).map((e) => e.name),
          ...(await _databaseService.getEntities('receipt')).map((e) => e.name),
        ];
        final entityMapping = await Navigator.push<Map<String, String>>(
          context,
          MaterialPageRoute(
            builder: (context) => MapEntitiesScreen(
              unknownEntities: unknownEntities.cast<String>(),
              availableEntities: availableEntities.cast<String>(),
            ),
          ),
        );
        if (entityMapping == null) return;
        // استبدل كل جهة غير معروفة بالجهة المختارة
        for (final tx in transactions) {
          if (entityMapping.containsKey(tx['entity'])) {
            final mapped = entityMapping[tx['entity']] ?? '';
            tx['entity'] = mapped.toString();
            tx['subcategory'] = mapped.toString();
          }
        }
      }
      // استيراد الحركات بعد الربط
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
      int importedCount = 0;
      for (final tx in transactions) {
        await _databaseService.insertTransaction(
          model.Transaction(
            direction: tx['direction'],
            paymentMethod: tx['paymentMethod'],
            amount: tx['amount'],
            entity: tx['entity'],
            subcategory: tx['subcategory'],
            date: DateTime.tryParse(tx['date'] ?? '') ?? DateTime.now(),
            type: tx['type'] ?? '',
            notes: tx['notes'] ?? '',
          ),
        );
        importedCount++;
      }
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم استيراد البيانات بنجاح: $importedCount معاملة')),
      );
      widget.onDataChanged?.call();
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ في استيراد البيانات: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _exportDatabaseFile() async {
    final tr = AppLocalizations.of(context)!;
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                tr.exportDatabase,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
      
      final tempPath = await _databaseService.exportDatabaseFile();
      Navigator.pop(context);
      
      // اختيار المسار النهائي للحفظ
      final saveResult = await FilePicker.platform.saveFile(
        dialogTitle: _currentLanguage == 'ar' 
          ? 'اختر مكان حفظ قاعدة البيانات'
          : 'Choose location to save database',
        fileName: tempPath.split('/').last,
        type: FileType.custom,
        allowedExtensions: ['db'],
      );
      
      if (saveResult != null) {
        final tempFile = File(tempPath);
        final destFile = File(saveResult);
        await destFile.writeAsBytes(await tempFile.readAsBytes());
        
        // إظهار رسالة النجاح
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _currentLanguage == 'ar' 
                ? 'تم تصدير قاعدة البيانات بنجاح إلى: $saveResult'
                : 'Database exported successfully to: $saveResult'
            ),
            backgroundColor: Colors.green,
          ),
        );
        
        // إظهار خيار المشاركة
        _showShareDialog(saveResult, _currentLanguage == 'ar' 
          ? 'ملف قاعدة بيانات Exoda' 
          : 'Exoda Database File');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _currentLanguage == 'ar' 
                ? 'تم إلغاء الحفظ'
                : 'Save cancelled'
            ),
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _currentLanguage == 'ar' 
              ? 'حدث خطأ في تصدير قاعدة البيانات: $e'
              : 'Error exporting database: $e'
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _confirmResetDatabase() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد إعادة التصفير'),
        content: const Text('هل أنت متأكد أنك تريد حذف جميع البيانات والإعدادات من الملف الحالي؟ لا يمكن التراجع عن هذه العملية!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('تصفير'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _databaseService.resetDatabase();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تصفير قاعدة البيانات بنجاح!')),
      );
      widget.onDataChanged?.call();
    }
  }

  Future<void> _importDatabaseFile() async {
    final tr = AppLocalizations.of(context)!;
    
    // إظهار تحذير قبل الاستيراد
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_currentLanguage == 'ar' 
          ? 'تأكيد استيراد قاعدة البيانات'
          : 'Confirm Database Import'),
        content: Text(_currentLanguage == 'ar' 
          ? 'سيتم استبدال قاعدة البيانات الحالية بالملف المختار. هذا الإجراء لا يمكن التراجع عنه.\n\nهل تريد المتابعة؟'
          : 'The current database will be replaced with the selected file. This action cannot be undone.\n\nDo you want to continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(_currentLanguage == 'ar' ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(_currentLanguage == 'ar' ? 'استيراد' : 'Import'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom, 
        allowedExtensions: ['db'],
        dialogTitle: _currentLanguage == 'ar' 
          ? 'اختر ملف قاعدة البيانات'
          : 'Select database file',
      );
      
      if (result == null || result.files.isEmpty) return;
      final filePath = result.files.single.path;
      if (filePath == null) return;
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                _currentLanguage == 'ar' 
                  ? 'جاري استيراد قاعدة البيانات...'
                  : 'Importing database...',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
      
      // انسخ الملف المختار إلى مكان قاعدة البيانات الحالية
      final dbPath = await _databaseService.getDatabasePath();
      final selectedFile = File(filePath);
      final destFile = File(dbPath);
      await destFile.writeAsBytes(await selectedFile.readAsBytes(), flush: true);
      await _databaseService.initDatabase();
      
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_currentLanguage == 'ar' 
            ? 'تم استيراد قاعدة البيانات بنجاح!'
            : 'Database imported successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      widget.onDataChanged?.call();
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_currentLanguage == 'ar' 
            ? 'حدث خطأ في استيراد قاعدة البيانات: $e'
            : 'Error importing database: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // دالة إظهار خيارات المشاركة
  Future<void> _showShareDialog(String filePath, String description) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_currentLanguage == 'ar' 
          ? 'مشاركة الملف'
          : 'Share File'),
        content: Text(_currentLanguage == 'ar' 
          ? 'هل تريد مشاركة الملف الآن؟'
          : 'Do you want to share the file now?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_currentLanguage == 'ar' ? 'لاحقاً' : 'Later'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await Share.shareXFiles([XFile(filePath)], text: description);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_currentLanguage == 'ar' 
                      ? 'حدث خطأ في المشاركة: $e'
                      : 'Error sharing: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(_currentLanguage == 'ar' ? 'مشاركة' : 'Share'),
          ),
        ],
      ),
    );
  }

  // دوال إدارة الإعدادات المختصرة
  void _showEntitiesDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EntitiesManagementScreen(),
      ),
    );
  }

  void _showTypesDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _TypesManagementScreen(
          databaseService: _databaseService,
          onDataChanged: widget.onDataChanged,
        ),
      ),
    );
  }

  void _showPaymentMethodsDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentMethodsManagementScreen(),
      ),
    );
  }
}

class _CreateNewFileDialog extends StatefulWidget {
  @override
  State<_CreateNewFileDialog> createState() => _CreateNewFileDialogState();
}

class _CreateNewFileDialogState extends State<_CreateNewFileDialog> {
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _hasPassword = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedLanguage = 'ar';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إنشاء ملف جديد'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'اسم الملف',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedLanguage,
              decoration: const InputDecoration(
                labelText: 'اللغة الافتراضية',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'ar', child: Text('العربية')),
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'es', child: Text('Español')),
                DropdownMenuItem(value: 'el', child: Text('Ελληνικά')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value ?? 'ar';
                });
              },
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('حماية بكلمة مرور'),
              value: _hasPassword,
              onChanged: (value) {
                setState(() {
                  _hasPassword = value ?? false;
                  if (!_hasPassword) {
                    _passwordController.clear();
                    _confirmPasswordController.clear();
                  }
                });
              },
            ),
            if (_hasPassword) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'تأكيد كلمة المرور',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('يرجى إدخال اسم الملف')),
              );
              return;
            }

            if (_hasPassword) {
              if (_passwordController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('يرجى إدخال كلمة المرور')),
                );
                return;
              }

              if (_passwordController.text != _confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('كلمات المرور غير متطابقة')),
                );
                return;
              }
            }

            Navigator.of(context).pop({
              'name': _nameController.text.trim(),
              'password': _hasPassword ? _passwordController.text : null,
              'language': _selectedLanguage,
            });
          },
          child: const Text('إنشاء'),
        ),
      ],
    );
  }
}

// شاشة إدارة الجهات
class EntitiesManagementScreen extends StatefulWidget {
  @override
  State<EntitiesManagementScreen> createState() => _EntitiesManagementScreenState();
}

class _EntitiesManagementScreenState extends State<EntitiesManagementScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<Entity> _entities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEntities();
  }

  Future<void> _loadEntities() async {
    setState(() => _isLoading = true);
    final payments = await _databaseService.getEntities('payment');
    final receipts = await _databaseService.getEntities('receipt');
    setState(() {
      _entities = [...payments, ...receipts];
      _isLoading = false;
    });
  }

  void _showAddEntityDialog() {
    final nameController = TextEditingController();
    String type = 'payment';
    bool isSub = false;
    String? parent;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text('إضافة جهة جديدة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'اسم الجهة'),
              ),
              DropdownButton<String>(
                value: type,
                items: [
                  DropdownMenuItem(value: 'payment', child: Text('جهة صرف')),
                  DropdownMenuItem(value: 'receipt', child: Text('جهة قبض')),
                ],
                onChanged: (v) => setStateDialog(() => type = v!),
              ),
              CheckboxListTile(
                value: isSub,
                onChanged: (v) => setStateDialog(() => isSub = v ?? false),
                title: Text('تصنيف فرعي'),
              ),
              if (isSub)
                DropdownButton<String>(
                  value: parent,
                  hint: Text('اختر الجهة الرئيسية'),
                  items: _entities.where((e) => e.type == type && e.isSubcategory == false).map((e) => DropdownMenuItem(value: e.name, child: Text(e.name))).toList(),
                  onChanged: (v) => setStateDialog(() => parent = v),
                ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) return;
                await _databaseService.insertEntity(Entity(
                  name: nameController.text.trim(),
                  type: type,
                  parentId: isSub ? parent : null,
                  isSubcategory: isSub,
                ));
                Navigator.pop(context);
                _loadEntities();
              },
              child: Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditEntityDialog(Entity entity) {
    final nameController = TextEditingController(text: entity.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تعديل الجهة'),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(labelText: 'اسم الجهة'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              await _databaseService.insertEntity(entity.copyWith(name: nameController.text.trim()));
              Navigator.pop(context);
              _loadEntities();
            },
            child: Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteEntity(Entity entity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف الجهة "${entity.name}"؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              await _databaseService.deleteEntity(entity.id!);
              Navigator.pop(context);
              _loadEntities();
            },
            child: Text('حذف'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إدارة الجهات'),
        actions: [
          IconButton(icon: Icon(Icons.add), onPressed: _showAddEntityDialog, tooltip: 'إضافة جهة'),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _entities.length,
              itemBuilder: (context, index) {
                final entity = _entities[index];
                return ListTile(
                  title: Text(entity.name),
                  subtitle: entity.isSubcategory && entity.parentId != null ? Text('فرعي من: ${entity.parentId}') : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: Icon(Icons.edit, color: Colors.blue), onPressed: () => _showEditEntityDialog(entity), tooltip: 'تعديل'),
                      IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => _confirmDeleteEntity(entity), tooltip: 'حذف'),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

// شاشة إدارة الأنواع
class _TypesManagementScreen extends StatefulWidget {
  final DatabaseService databaseService;
  final VoidCallback? onDataChanged;

  const _TypesManagementScreen({
    required this.databaseService,
    this.onDataChanged,
  });

  @override
  State<_TypesManagementScreen> createState() => _TypesManagementScreenState();
}

class _TypesManagementScreenState extends State<_TypesManagementScreen> {
  List<ExpenseType> _types = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTypes();
  }

  Future<void> _loadTypes() async {
    try {
      final types = await widget.databaseService.getExpenseTypes();
      setState(() {
        _types = types;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في تحميل الأنواع: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة أنواع المصاريف'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addType,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _types.length,
              itemBuilder: (context, index) {
                final type = _types[index];
                return ListTile(
                  title: Text(type.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteType(type),
                  ),
                );
              },
            ),
    );
  }

  void _addType() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة نوع جديد'),
        content: const Text('سيتم إضافة هذه الميزة قريباً'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  void _deleteType(ExpenseType type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف النوع'),
        content: Text('هل تريد حذف "${type.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await widget.databaseService.deleteExpenseType(type.id!);
                _loadTypes();
                widget.onDataChanged?.call();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('خطأ في حذف النوع: $e')),
                );
              }
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}

// شاشة إدارة طرق الدفع
class PaymentMethodsManagementScreen extends StatefulWidget {
  @override
  State<PaymentMethodsManagementScreen> createState() => _PaymentMethodsManagementScreenState();
}

class _PaymentMethodsManagementScreenState extends State<PaymentMethodsManagementScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<String> _methods = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMethods();
  }

  Future<void> _loadMethods() async {
    setState(() => _isLoading = true);
    final methods = await _databaseService.getPaymentMethods();
    setState(() {
      _methods = methods;
      _isLoading = false;
    });
  }

  void _showAddMethodDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('إضافة طريقة دفع'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: 'اسم الطريقة'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              await _databaseService.insertPaymentMethod(controller.text.trim());
              Navigator.pop(context);
              _loadMethods();
            },
            child: Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _showEditMethodDialog(String method) {
    final controller = TextEditingController(text: method);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تعديل طريقة الدفع'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: 'اسم الطريقة'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              await _databaseService.deletePaymentMethod(method);
              await _databaseService.insertPaymentMethod(controller.text.trim());
              Navigator.pop(context);
              _loadMethods();
            },
            child: Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteMethod(String method) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف طريقة الدفع "$method"؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              await _databaseService.deletePaymentMethod(method);
              Navigator.pop(context);
              _loadMethods();
            },
            child: Text('حذف'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إدارة طرق الدفع'),
        actions: [
          IconButton(icon: Icon(Icons.add), onPressed: _showAddMethodDialog, tooltip: 'إضافة طريقة'),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _methods.length,
              itemBuilder: (context, index) {
                final method = _methods[index];
                return ListTile(
                  title: Text(method),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: Icon(Icons.edit, color: Colors.blue), onPressed: () => _showEditMethodDialog(method), tooltip: 'تعديل'),
                      IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => _confirmDeleteMethod(method), tooltip: 'حذف'),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class ExpenseTypesManagementScreen extends StatefulWidget {
  @override
  State<ExpenseTypesManagementScreen> createState() => _ExpenseTypesManagementScreenState();
}

class _ExpenseTypesManagementScreenState extends State<ExpenseTypesManagementScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<ExpenseType> _types = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTypes();
  }

  Future<void> _loadTypes() async {
    setState(() => _isLoading = true);
    final types = await _databaseService.getExpenseTypes();
    setState(() {
      _types = types;
      _isLoading = false;
    });
  }

  void _showAddTypeDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('إضافة نوع جديد'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: 'اسم النوع'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              await _databaseService.insertExpenseType(ExpenseType(name: controller.text.trim()));
              Navigator.pop(context);
              _loadTypes();
            },
            child: Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _showEditTypeDialog(ExpenseType type) {
    final controller = TextEditingController(text: type.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تعديل النوع'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: 'اسم النوع'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              await _databaseService.updateExpenseType(type.copyWith(name: controller.text.trim()));
              Navigator.pop(context);
              _loadTypes();
            },
            child: Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteType(ExpenseType type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف النوع "${type.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _databaseService.deleteExpenseType(type.id!);
              Navigator.pop(context);
              _loadTypes();
            },
            child: Text('حذف'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إدارة أنواع المصاريف'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddTypeDialog,
            tooltip: 'إضافة نوع',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _types.length,
              itemBuilder: (context, index) {
                final type = _types[index];
                return ListTile(
                  title: Text(type.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showEditTypeDialog(type),
                        tooltip: 'تعديل',
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDeleteType(type),
                        tooltip: 'حذف',
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
} 