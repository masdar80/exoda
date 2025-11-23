# Exoda - إكسودا
## تطبيق إدارة مصاريف المنزل / Household Expense Management App

### النظرة العامة / Overview

**العربية:**
إكسودا هو تطبيق شامل لإدارة مصاريف المنزل، مصمم لمساعدة العائلات في تتبع وإدارة مصاريفهم اليومية بطريقة سهلة وفعالة. يدعم التطبيق اللغتين العربية والإنجليزية ويستخدم قاعدة بيانات SQLite محلية لضمان خصوصية البيانات.

**English:**
Exoda is a comprehensive household expense management application designed to help families track and manage their daily expenses efficiently. The app supports both Arabic and English languages and uses local SQLite database to ensure data privacy.

### المميزات الرئيسية / Key Features

**العربية:**
- ✅ واجهة سهلة الاستخدام تدعم العربية والإنجليزية
- ✅ إدارة شاملة للمعاملات المالية (دفعات ومقبوضات)
- ✅ تصنيف مرن للجهات مع إمكانية إضافة تصنيفات فرعية
- ✅ تقارير تفصيلية وموجزة مع إمكانيات تصفية متقدمة
- ✅ نسخ احتياطي واستعادة البيانات
- ✅ قاعدة بيانات محلية تضمن الخصوصية
- ✅ إعدادات قابلة للتخصيص لطرق الدفع والأنواع والجهات

**English:**
- ✅ User-friendly interface supporting Arabic and English
- ✅ Comprehensive financial transaction management (payments & receipts)
- ✅ Flexible entity categorization with subcategory support
- ✅ Detailed and summary reports with advanced filtering
- ✅ Data backup and restore functionality
- ✅ Local database ensuring privacy
- ✅ Customizable settings for payment methods, types, and entities

### المتطلبات التقنية / Technical Requirements

- Flutter SDK 3.7.0+
- Dart 3.0+
- Android 5.0+ / iOS 12.0+

### التبعيات / Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.3.2          # Local database
  intl: ^0.19.0            # Internationalization
  shared_preferences: ^2.2.2  # App settings
  file_picker: ^6.1.1      # File operations
  path_provider: ^2.1.2    # File paths
  google_fonts: ^6.1.0     # Arabic fonts
```

### التثبيت والتشغيل / Installation & Setup

```bash
# Clone the repository
git clone <repository-url>
cd exoda

# Get dependencies
flutter pub get

# Run the app
flutter run
```

### بنية التطبيق / App Structure

```
lib/
├── main.dart                 # Entry point
├── models/                   # Data models
│   ├── transaction.dart
│   ├── entity.dart
│   └── expense_type.dart
├── services/                 # Business logic
│   └── database_service.dart
├── screens/                  # UI screens
│   ├── startup_screen.dart
│   ├── home_screen.dart
│   ├── add_transaction_screen.dart
│   ├── reports_screen.dart
│   └── settings_screen.dart
└── l10n/                    # Localization
    ├── app_ar.arb
    └── app_en.arb
```

### الاستخدام / Usage

**العربية:**
1. **التشغيل الأول**: اختر إنشاء ملف جديد أو استيراد ملف موجود
2. **إضافة حركة**: استخدم علامة التبويب "إضافة حركة" لتسجيل المعاملات
3. **عرض التقارير**: راجع المعاملات والتقارير في علامة تبويب "التقارير"
4. **الإعدادات**: خصص الجهات والأنواع وطرق الدفع في "الإعدادات"

**English:**
1. **First Launch**: Choose to create new file or import existing data
2. **Add Transaction**: Use "Add Transaction" tab to record transactions
3. **View Reports**: Review transactions and reports in "Reports" tab
4. **Settings**: Customize entities, types, and payment methods in "Settings"

### قاعدة البيانات / Database Schema

**الجداول الرئيسية / Main Tables:**
- `transactions` - المعاملات المالية
- `entities` - الجهات والتصنيفات
- `expense_types` - أنواع المصاريف
- `payment_methods` - طرق الدفع

### المساهمة / Contributing

نرحب بالمساهمات! يرجى اتباع الخطوات التالية:
We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

### الترخيص / License

هذا المشروع مرخص تحت رخصة MIT - راجع ملف LICENSE للتفاصيل.
This project is licensed under the MIT License - see the LICENSE file for details.

### الدعم / Support

للدعم والاستفسارات، يرجى فتح issue في GitHub.
For support and questions, please open an issue on GitHub.

---

**تم التطوير بـ ❤️ للمجتمع العربي / Developed with ❤️ for the Arabic community**

## المميزات الأساسية

### 🏠 الشاشة الرئيسية
- عرض إجمالي مصاريف الشهر الحالي
- آخر 5 معاملات مالية
- تنقل سهل عبر التبويبات

### 💰 إدارة المعاملات
- إضافة معاملات دفع وقبض
- اختيار طريقة الدفع (نقدي، بطاقة، الخ)
- تحديد الجهة والتصنيف الفرعي
- إضافة التاريخ ونوع المصروف
- **حقل ملاحظات للمعلومات الإضافية**

### 📊 التقارير المتقدمة
- تقرير مفصل بجميع المعاملات
- تقرير ملخص بالإجماليات
- فلترة بالتاريخ، الجهة، وطريقة الدفع

### ⚙️ الإعدادات المتقدمة
- تغيير اللغة (عربي/إنجليزي)
- إدارة الجهات (دفع/قبض) مع التصنيفات الفرعية
- إدارة أنواع المصاريف
- إدارة طرق الدفع

### 💾 النسخ الاحتياطي
- تصدير البيانات كملف قاعدة بيانات
- استيراد البيانات من نسخة احتياطية
- **استيراد المعاملات من ملف Excel**

## استيراد البيانات من Excel

### تنسيق ملف Excel المطلوب

يجب أن يحتوي ملف Excel على **5 أعمدة بالترتيب التالي**:

| العمود | الاسم | الوصف | مثال |
|--------|------|--------|-------|
| 1 | التاريخ | تاريخ المعاملة | 15/01/2024 |
| 2 | جهة مقبوضات | الجهة التي تم القبض منها | راتب شركة ABC |
| 3 | جهة مدفوعات | الجهة التي تم الدفع لها | كارفور |
| 4 | المبلغ | قيمة المعاملة | 500.50 |
| 5 | طريقة الدفع | وسيلة الدفع | card |

### طرق الدفع المدعومة

| القيمة في Excel | المعنى | التحويل في التطبيق |
|-----------------|---------|-------------------|
| `card` | دفع بالبطاقة | بطاقة |
| `cash` | دفع نقدي | نقدي |
| `income` | مقبوضات نقدية | نقدي (قبض) |
| `InCard` | مقبوضات للبطاقة | بطاقة (قبض) |

### التحليل الذكي للجهات

يقوم التطبيق بتحليل أسماء الجهات تلقائياً وتصنيفها:

#### 🛒 سوبر ماركت
كلمات مفتاحية: `طعام، أكل، خضار، فواكه، لحم، دجاج، سمك، خبز، حليب، جبن، سوبر، بقالة، كارفور، لولو، نستو، العثيم، بنده، الدانوب`

#### 🚗 مواصلات
كلمات مفتاحية: `بنزين، وقود، تاكسي، أوبر، كريم، مواصلات، نقل، باص، قطار`

#### 🏥 طبي
كلمات مفتاحية: `طبيب، دواء، صيدلية، مستشفى، علاج، فحص، أسنان`

#### 🧾 فواتير
كلمات مفتاحية: `كهرباء، ماء، غاز، هاتف، انترنت، اتصالات`

#### 🏛️ معاملات حكومية
كلمات مفتاحية: `حكومي، رسوم، معاملة، ورقية، مكتب، وزارة، بلدية، جوازات، أحوال`

#### 🎓 تعليم
كلمات مفتاحية: `مدرسة، جامعة، كتاب، قرطاسية، دراسة، تعليم`

#### 👕 ملابس
كلمات مفتاحية: `ملابس، حذاء، قميص، بنطلون، فستان`

#### 🎮 ترفيه
كلمات مفتاحية: `سينما، مطعم، كافي، ترفيه، ألعاب`

#### 💼 راتب (للمقبوضات)
كلمات مفتاحية: `راتب، أجر، دخل، مكافأة، علاوة`

### مثال على ملف Excel

```
التاريخ | جهة مقبوضات | جهة مدفوعات | المبلغ | طريقة الدفع
01/01/2024 | راتب شركة XYZ | | 5000 | income
02/01/2024 | | كارفور خضار | 250.50 | card
03/01/2024 | | بنزين محطة الوقود | 100 | cash
04/01/2024 | | أجور معاملات ورقية | 150 | cash
```

### خطوات الاستيراد

1. **إعداد الملف**: تأكد من أن ملف Excel يحتوي على البيانات بالتنسيق الصحيح
2. **فتح التطبيق**: اذهب إلى **الإعدادات** > **إدارة البيانات**
3. **اختيار الاستيراد**: اضغط على **"استيراد من Excel"**
4. **اختيار الملف**: حدد ملف Excel من جهازك
5. **مراجعة النتائج**: سيظهر تقرير بعدد المعاملات المستوردة والجهات الجديدة

### معالجة الأخطاء

- **الجهات غير المُعرَّفة**: سيتم وضعها تحت جهة "آخر" مع إضافة النص الأصلي في الملاحظات
- **التواريخ غير صحيحة**: سيتم استخدام التاريخ الحالي
- **المبالغ غير صحيحة**: سيتم تجاهل هذه الصفوف
- **الصفوف الفارغة**: سيتم تجاهلها تلقائياً

## المتطلبات التقنية

- Flutter 3.7.0+
- Android SDK 21+
- مساحة تخزين محلية

## التقنيات المستخدمة

- **Flutter**: إطار العمل الرئيسي
- **SQLite**: قاعدة البيانات المحلية
- **Excel Package**: قراءة ملفات Excel
- **Intl**: دعم التوطين والعملات
- **File Picker**: اختيار الملفات
- **Path Provider**: إدارة مسارات الملفات
- **Shared Preferences**: حفظ الإعدادات
- **Google Fonts**: دعم الخطوط العربية

## التطوير

```bash
# تنزيل المتطلبات
flutter pub get

# تشغيل التطبيق
flutter run

# بناء ملف APK
flutter build apk
```

## المساهمة

نرحب بالمساهمات! يرجى فتح Issue أو Pull Request لأي تحسينات.

## الترخيص

هذا المشروع مفتوح المصدر تحت رخصة MIT.

---

**طُور بحب في الكويت 🇰🇼**
