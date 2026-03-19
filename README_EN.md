# Exoda - Household Expense Manager

## Overview
Exoda is a comprehensive household expense management application designed to help families track and manage their daily expenses efficiently. The app supports multiple languages (Arabic, English, Spanish, Greek) and uses a local SQLite database to ensure data privacy.

## Key Features
- ✅ **User-Friendly Interface**: Supports Arabic and English (and more).
- ✅ **Comprehensive Transaction Management**: Track payments and receipts easily.
- ✅ **Flexible Categorization**: Manage entities with subcategory support.
- ✅ **Advanced Reports**: Detailed and summary reports with advanced filtering.
- ✅ **Yearly Reports**: Comprehensive yearly overview of expenses.
- ✅ **Visual Analytics**: Pie charts and bar charts for expense distribution and monthly comparisons.
- ✅ **Multi-File Support**: Create and manage multiple database files (profiles) for different needs.
- ✅ **Data Backup & Restore**: Secure your data locally.
- ✅ **Excel Integration**: Import transactions from Excel with smart entity recognition and export data to Excel.
- ✅ **Privacy Focused**: Local database ensures your financial data stays on your device.

## Technical Requirements
- Flutter SDK 3.7.0+
- Dart 3.0+
- Android 5.0+ / iOS 12.0+

## Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.3.2          # Local database
  intl: ^0.19.0            # Internationalization
  shared_preferences: ^2.2.2  # App settings
  file_picker: ^6.1.1      # File operations
  path_provider: ^2.1.2    # File paths
  google_fonts: ^6.1.0     # Fonts
  fl_chart: ^0.66.0        # Charts
  share_plus: ^7.2.1       # Sharing
```

## Installation & Setup
```bash
# Clone the repository
git clone <repository-url>
cd exoda

# Get dependencies
flutter pub get

# Run the app
flutter run
```

## App Structure
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
│   ├── advanced_reports_screen.dart
│   ├── yearly_report_screen.dart
│   └── settings_screen.dart
└── l10n/                    # Localization
    ├── app_ar.arb
    └── app_en.arb
```

## Usage
1. **First Launch**: Choose to create a new file or import an existing database.
2. **Add Transaction**: Use the "Add Transaction" tab to record payments or receipts.
3. **View Reports**: Review your financial history in the "Reports" tab.
4. **Advanced Analytics**: Access charts and yearly reports via the icons in the Reports screen.
5. **Settings**: Customize entities, expense types, payment methods, and manage your data files.

## Database Schema
**Main Tables:**
- `transactions`: Financial records.
- `entities`: Payees/Payers and categories.
- `expense_types`: Types of expenses (e.g., Groceries, Utilities).
- `payment_methods`: Methods like Cash, Card, etc.

## Detailed Features

### 🏠 Home Screen
- View total expenses for the current month.
- Quick access to the last 5 transactions.
- Easy navigation via the bottom bar.

### 💰 Transaction Management
- Add Payment or Receipt transactions.
- Select Payment Method (Cash, Card, etc.).
- Choose Entity and Subcategory.
- Add Date and Expense Type.
- **Notes field** for additional details.

### 📊 Reports & Analytics
- Detailed list of all transactions.
- Summary cards for Total Payments, Total Receipts, and Net Balance.
- **Yearly Reports**: Month-by-month summary.
- **Pie Charts**: Visualize expense distribution by category.
- **Monthly Comparison**: Compare expenses between two different months.
- Advanced filtering by Date, Entity, and Payment Method.

### ⚙️ Advanced Settings
- Change Language (Arabic, English, Spanish, Greek).
- **File Management**: Create new database files or switch between existing ones.
- Manage Entities (Payers/Payees) and Subcategories.
- Manage Expense Types.
- Manage Payment Methods.

### 💾 Data Management
- Export database file for backup.
- Import database from backup.
- **Import Transactions from Excel** with "Smart Recognition" for entities.
- Export Transactions to Excel for external analysis.

## Excel Import Guide

### Required Excel Format
The Excel file must contain **5 columns in the following order**:

| Column | Name | Description | Example |
|--------|------|-------------|---------|
| 1 | Date | Transaction Date | 15/01/2024 |
| 2 | Receipt Entity | Payer (Income Source) | Salary ABC |
| 3 | Payment Entity | Payee (Expense Destination) | Carrefour |
| 4 | Amount | Transaction Value | 500.50 |
| 5 | Payment Method | Method used | card |

### Supported Payment Methods
| Excel Value | App Equivalent |
|-------------|----------------|
| `card` | Card |
| `cash` | Cash |
| `income` | Cash (Receipt) |
| `InCard` | Card (Receipt) |

### Smart Entity Recognition
The app automatically analyzes entity names to categorize them (e.g., Supermarket, Transport, Medical). If an entity is unknown, the app will prompt you to map it manually during import.

### Import Steps
1. **Prepare File**: Ensure your Excel file matches the required format.
2. **Open App**: Go to **Settings** > **Data Management**.
3. **Select Import**: Tap on **"Import from Excel"**.
4. **Choose File**: Select the file from your device.
5. **Review**: A report will show the number of imported transactions.

## Contributing
We welcome contributions! Please follow these steps:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License
This project is licensed under the MIT License - see the LICENSE file for details.

## Support
For support and questions, please open an issue on GitHub.

---

**Developed with ❤️ for the Community**
mashhourmd@gmail.com
Eng: Machhour Darwich
