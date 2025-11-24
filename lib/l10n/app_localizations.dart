import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_el.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('el'),
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Exoda'**
  String get appTitle;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// No description provided for @addTransactionTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get addTransactionTitle;

  /// No description provided for @reportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reportsTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @totalExpenses.
  ///
  /// In en, this message translates to:
  /// **'Total Expenses'**
  String get totalExpenses;

  /// No description provided for @lastTransactions.
  ///
  /// In en, this message translates to:
  /// **'Last 5 Transactions'**
  String get lastTransactions;

  /// No description provided for @noTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions'**
  String get noTransactions;

  /// No description provided for @direction.
  ///
  /// In en, this message translates to:
  /// **'Direction'**
  String get direction;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @receipt.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get receipt;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @visa.
  ///
  /// In en, this message translates to:
  /// **'Visa'**
  String get visa;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @entity.
  ///
  /// In en, this message translates to:
  /// **'Entity'**
  String get entity;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @transactionAdded.
  ///
  /// In en, this message translates to:
  /// **'Transaction added successfully'**
  String get transactionAdded;

  /// No description provided for @transactionUpdated.
  ///
  /// In en, this message translates to:
  /// **'Transaction updated successfully'**
  String get transactionUpdated;

  /// No description provided for @transactionDeleted.
  ///
  /// In en, this message translates to:
  /// **'Transaction deleted successfully'**
  String get transactionDeleted;

  /// No description provided for @invalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get invalidAmount;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get requiredField;

  /// No description provided for @paymentEntities.
  ///
  /// In en, this message translates to:
  /// **'Payment Entities'**
  String get paymentEntities;

  /// No description provided for @receiptEntities.
  ///
  /// In en, this message translates to:
  /// **'Receipt Entities'**
  String get receiptEntities;

  /// No description provided for @types.
  ///
  /// In en, this message translates to:
  /// **'Types'**
  String get types;

  /// No description provided for @paymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get paymentMethods;

  /// No description provided for @addEntity.
  ///
  /// In en, this message translates to:
  /// **'Add New Entity'**
  String get addEntity;

  /// No description provided for @addType.
  ///
  /// In en, this message translates to:
  /// **'Add New Type'**
  String get addType;

  /// No description provided for @addPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Add New Payment Method'**
  String get addPaymentMethod;

  /// No description provided for @entityName.
  ///
  /// In en, this message translates to:
  /// **'Entity Name'**
  String get entityName;

  /// No description provided for @typeName.
  ///
  /// In en, this message translates to:
  /// **'Type Name'**
  String get typeName;

  /// No description provided for @paymentMethodName.
  ///
  /// In en, this message translates to:
  /// **'Method Name'**
  String get paymentMethodName;

  /// No description provided for @generalCategory.
  ///
  /// In en, this message translates to:
  /// **'General Category'**
  String get generalCategory;

  /// No description provided for @subcategory.
  ///
  /// In en, this message translates to:
  /// **'Subcategory'**
  String get subcategory;

  /// No description provided for @addSubcategory.
  ///
  /// In en, this message translates to:
  /// **'Add Subcategory'**
  String get addSubcategory;

  /// No description provided for @subcategoryName.
  ///
  /// In en, this message translates to:
  /// **'Subcategory Name'**
  String get subcategoryName;

  /// No description provided for @showPayments.
  ///
  /// In en, this message translates to:
  /// **'Show Payments'**
  String get showPayments;

  /// No description provided for @showReceipts.
  ///
  /// In en, this message translates to:
  /// **'Show Receipts'**
  String get showReceipts;

  /// No description provided for @showAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get showAll;

  /// No description provided for @filterByCash.
  ///
  /// In en, this message translates to:
  /// **'Cash Only'**
  String get filterByCash;

  /// No description provided for @filterByVisa.
  ///
  /// In en, this message translates to:
  /// **'Visa Only'**
  String get filterByVisa;

  /// No description provided for @lastWeek.
  ///
  /// In en, this message translates to:
  /// **'Last Week'**
  String get lastWeek;

  /// No description provided for @currentMonth.
  ///
  /// In en, this message translates to:
  /// **'Current Month'**
  String get currentMonth;

  /// No description provided for @dateRange.
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get dateRange;

  /// No description provided for @fromDate.
  ///
  /// In en, this message translates to:
  /// **'From Date'**
  String get fromDate;

  /// No description provided for @toDate.
  ///
  /// In en, this message translates to:
  /// **'To Date'**
  String get toDate;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @filterByEntity.
  ///
  /// In en, this message translates to:
  /// **'Search by Entity'**
  String get filterByEntity;

  /// No description provided for @filterByType.
  ///
  /// In en, this message translates to:
  /// **'Search by Type'**
  String get filterByType;

  /// No description provided for @searchInfo.
  ///
  /// In en, this message translates to:
  /// **'Search Info'**
  String get searchInfo;

  /// No description provided for @detailedReport.
  ///
  /// In en, this message translates to:
  /// **'Detailed Report'**
  String get detailedReport;

  /// No description provided for @summaryReport.
  ///
  /// In en, this message translates to:
  /// **'Summary Report'**
  String get summaryReport;

  /// No description provided for @totalPayments.
  ///
  /// In en, this message translates to:
  /// **'Total Payments'**
  String get totalPayments;

  /// No description provided for @totalReceipts.
  ///
  /// In en, this message translates to:
  /// **'Total Receipts'**
  String get totalReceipts;

  /// No description provided for @netAmount.
  ///
  /// In en, this message translates to:
  /// **'Net Amount'**
  String get netAmount;

  /// No description provided for @compareMonths.
  ///
  /// In en, this message translates to:
  /// **'Compare Months'**
  String get compareMonths;

  /// No description provided for @compareYears.
  ///
  /// In en, this message translates to:
  /// **'Compare Years'**
  String get compareYears;

  /// No description provided for @selectMonth.
  ///
  /// In en, this message translates to:
  /// **'Select Month'**
  String get selectMonth;

  /// No description provided for @selectYear.
  ///
  /// In en, this message translates to:
  /// **'Select Year'**
  String get selectYear;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// No description provided for @importData.
  ///
  /// In en, this message translates to:
  /// **'Import Data'**
  String get importData;

  /// No description provided for @createNewFile.
  ///
  /// In en, this message translates to:
  /// **'Create New File'**
  String get createNewFile;

  /// No description provided for @importFile.
  ///
  /// In en, this message translates to:
  /// **'Import File'**
  String get importFile;

  /// No description provided for @dataExported.
  ///
  /// In en, this message translates to:
  /// **'Data exported successfully'**
  String get dataExported;

  /// No description provided for @dataImported.
  ///
  /// In en, this message translates to:
  /// **'Data imported successfully'**
  String get dataImported;

  /// No description provided for @fileNotFound.
  ///
  /// In en, this message translates to:
  /// **'File not found'**
  String get fileNotFound;

  /// No description provided for @invalidFile.
  ///
  /// In en, this message translates to:
  /// **'Invalid file format'**
  String get invalidFile;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @backupData.
  ///
  /// In en, this message translates to:
  /// **'Backup Data'**
  String get backupData;

  /// No description provided for @restoreData.
  ///
  /// In en, this message translates to:
  /// **'Restore Data'**
  String get restoreData;

  /// No description provided for @selectFile.
  ///
  /// In en, this message translates to:
  /// **'Select File'**
  String get selectFile;

  /// No description provided for @january.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get january;

  /// No description provided for @february.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get february;

  /// No description provided for @march.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get march;

  /// No description provided for @april.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get april;

  /// No description provided for @may.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// No description provided for @june.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get june;

  /// No description provided for @july.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get july;

  /// No description provided for @august.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get august;

  /// No description provided for @september.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get september;

  /// No description provided for @october.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get october;

  /// No description provided for @november.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get november;

  /// No description provided for @december.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get december;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'SAR'**
  String get currency;

  /// No description provided for @selectCurrency.
  ///
  /// In en, this message translates to:
  /// **'Select Currency'**
  String get selectCurrency;

  /// No description provided for @currencyCode.
  ///
  /// In en, this message translates to:
  /// **'Currency Code'**
  String get currencyCode;

  /// No description provided for @currencyNameAr.
  ///
  /// In en, this message translates to:
  /// **'Currency Name in Arabic'**
  String get currencyNameAr;

  /// No description provided for @currencyNameEn.
  ///
  /// In en, this message translates to:
  /// **'Currency Name in English'**
  String get currencyNameEn;

  /// No description provided for @exchangeRate.
  ///
  /// In en, this message translates to:
  /// **'Exchange Rate vs USD'**
  String get exchangeRate;

  /// No description provided for @currencySettings.
  ///
  /// In en, this message translates to:
  /// **'Currency Settings'**
  String get currencySettings;

  /// No description provided for @addCurrency.
  ///
  /// In en, this message translates to:
  /// **'Add Currency'**
  String get addCurrency;

  /// No description provided for @valueInUsd.
  ///
  /// In en, this message translates to:
  /// **'Value in USD'**
  String get valueInUsd;

  /// No description provided for @expensesByCategory.
  ///
  /// In en, this message translates to:
  /// **'Expenses by Category'**
  String get expensesByCategory;

  /// No description provided for @pieChart.
  ///
  /// In en, this message translates to:
  /// **'Pie Chart'**
  String get pieChart;

  /// No description provided for @monthlyComparison.
  ///
  /// In en, this message translates to:
  /// **'Monthly Comparison'**
  String get monthlyComparison;

  /// No description provided for @yearlyComparison.
  ///
  /// In en, this message translates to:
  /// **'Yearly Comparison'**
  String get yearlyComparison;

  /// No description provided for @categoryComparison.
  ///
  /// In en, this message translates to:
  /// **'Category Comparison'**
  String get categoryComparison;

  /// No description provided for @selectPeriod.
  ///
  /// In en, this message translates to:
  /// **'Select Period'**
  String get selectPeriod;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @lastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last Month'**
  String get lastMonth;

  /// No description provided for @thisYear.
  ///
  /// In en, this message translates to:
  /// **'This Year'**
  String get thisYear;

  /// No description provided for @lastYear.
  ///
  /// In en, this message translates to:
  /// **'Last Year'**
  String get lastYear;

  /// No description provided for @customPeriod.
  ///
  /// In en, this message translates to:
  /// **'Custom Period'**
  String get customPeriod;

  /// No description provided for @shareFile.
  ///
  /// In en, this message translates to:
  /// **'Share File'**
  String get shareFile;

  /// No description provided for @saveFile.
  ///
  /// In en, this message translates to:
  /// **'Save File'**
  String get saveFile;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All Categories'**
  String get allCategories;

  /// No description provided for @parentCategory.
  ///
  /// In en, this message translates to:
  /// **'Parent Category'**
  String get parentCategory;

  /// No description provided for @pleaseSelectPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Please select payment method'**
  String get pleaseSelectPaymentMethod;

  /// No description provided for @pleaseEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter amount'**
  String get pleaseEnterAmount;

  /// No description provided for @pleaseEnterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid amount'**
  String get pleaseEnterValidAmount;

  /// No description provided for @amountMustBeGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'Amount must be greater than zero'**
  String get amountMustBeGreaterThanZero;

  /// No description provided for @pleaseSelectEntity.
  ///
  /// In en, this message translates to:
  /// **'Please select entity'**
  String get pleaseSelectEntity;

  /// No description provided for @pleaseSelectType.
  ///
  /// In en, this message translates to:
  /// **'Please select type'**
  String get pleaseSelectType;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @updateTransaction.
  ///
  /// In en, this message translates to:
  /// **'Update Transaction'**
  String get updateTransaction;

  /// No description provided for @deleteTransaction.
  ///
  /// In en, this message translates to:
  /// **'Delete Transaction'**
  String get deleteTransaction;

  /// No description provided for @areYouSureDeleteTransaction.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this transaction?'**
  String get areYouSureDeleteTransaction;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @payments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get payments;

  /// No description provided for @receipts.
  ///
  /// In en, this message translates to:
  /// **'Receipts'**
  String get receipts;

  /// No description provided for @net.
  ///
  /// In en, this message translates to:
  /// **'Net'**
  String get net;

  /// No description provided for @advancedReportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Advanced Reports'**
  String get advancedReportsTitle;

  /// No description provided for @expensesByCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Expenses by Category'**
  String get expensesByCategoryTitle;

  /// No description provided for @selectPeriodTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Period'**
  String get selectPeriodTitle;

  /// No description provided for @monthlyComparisonTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly Comparison'**
  String get monthlyComparisonTitle;

  /// No description provided for @firstMonthTitle.
  ///
  /// In en, this message translates to:
  /// **'First Month'**
  String get firstMonthTitle;

  /// No description provided for @secondMonthTitle.
  ///
  /// In en, this message translates to:
  /// **'Second Month'**
  String get secondMonthTitle;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'Exoda app for personal expense management'**
  String get aboutDescription;

  /// No description provided for @filterInfo.
  ///
  /// In en, this message translates to:
  /// **'Filter Info'**
  String get filterInfo;

  /// No description provided for @appInfo.
  ///
  /// In en, this message translates to:
  /// **'App Information'**
  String get appInfo;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @releaseDate.
  ///
  /// In en, this message translates to:
  /// **'Release Date'**
  String get releaseDate;

  /// No description provided for @developer.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developer;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @noDataToShow.
  ///
  /// In en, this message translates to:
  /// **'No data to show'**
  String get noDataToShow;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @moneyManagementApp.
  ///
  /// In en, this message translates to:
  /// **'Money Management App'**
  String get moneyManagementApp;

  /// No description provided for @welcomeCreateFile.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Exoda!\nLet\'s create your first file to start tracking your money'**
  String get welcomeCreateFile;

  /// No description provided for @passwordProtection.
  ///
  /// In en, this message translates to:
  /// **'Password Protection'**
  String get passwordProtection;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @showMore.
  ///
  /// In en, this message translates to:
  /// **'Show More'**
  String get showMore;

  /// No description provided for @allRightsReserved.
  ///
  /// In en, this message translates to:
  /// **'All Rights Reserved'**
  String get allRightsReserved;

  /// No description provided for @copyrightDescription.
  ///
  /// In en, this message translates to:
  /// **'This application has been developed for personal expense management to help families track their daily spending in an easy and effective way.'**
  String get copyrightDescription;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @createFileWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Exoda!\nLet\'s create your first file to start tracking your money'**
  String get createFileWelcome;

  /// No description provided for @fileName.
  ///
  /// In en, this message translates to:
  /// **'File Name'**
  String get fileName;

  /// No description provided for @fileNameHint.
  ///
  /// In en, this message translates to:
  /// **'Example: My Personal File'**
  String get fileNameHint;

  /// No description provided for @defaultLanguage.
  ///
  /// In en, this message translates to:
  /// **'Default Language'**
  String get defaultLanguage;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @noFiles.
  ///
  /// In en, this message translates to:
  /// **'No files\nClick \"Create New File\" to start'**
  String get noFiles;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @pleaseEnterFileName.
  ///
  /// In en, this message translates to:
  /// **'Please enter file name'**
  String get pleaseEnterFileName;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get pleaseEnterPassword;

  /// No description provided for @noDataForPeriod.
  ///
  /// In en, this message translates to:
  /// **'No data for selected period'**
  String get noDataForPeriod;

  /// No description provided for @noDataForComparison.
  ///
  /// In en, this message translates to:
  /// **'No data for comparison'**
  String get noDataForComparison;

  /// No description provided for @comingSoonCategoryComparison.
  ///
  /// In en, this message translates to:
  /// **'Coming soon - detailed category comparison'**
  String get comingSoonCategoryComparison;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @fileManagement.
  ///
  /// In en, this message translates to:
  /// **'File Management'**
  String get fileManagement;

  /// No description provided for @switchFile.
  ///
  /// In en, this message translates to:
  /// **'Switch Files'**
  String get switchFile;

  /// No description provided for @switchFileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose another file or create new'**
  String get switchFileSubtitle;

  /// No description provided for @createNewFileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create separate file for your data'**
  String get createNewFileSubtitle;

  /// No description provided for @dataManagement.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagement;

  /// No description provided for @importFromExcel.
  ///
  /// In en, this message translates to:
  /// **'Import from Excel'**
  String get importFromExcel;

  /// No description provided for @importFromExcelSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Import transactions from Excel file'**
  String get importFromExcelSubtitle;

  /// No description provided for @exportTransactionsToExcel.
  ///
  /// In en, this message translates to:
  /// **'Export Transactions to Excel'**
  String get exportTransactionsToExcel;

  /// No description provided for @exportTransactionsToExcelSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Export transactions only as Excel file'**
  String get exportTransactionsToExcelSubtitle;

  /// No description provided for @exportDatabase.
  ///
  /// In en, this message translates to:
  /// **'Export Database'**
  String get exportDatabase;

  /// No description provided for @exportDatabaseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Complete backup'**
  String get exportDatabaseSubtitle;

  /// No description provided for @databaseDiagnostics.
  ///
  /// In en, this message translates to:
  /// **'Database Diagnostics'**
  String get databaseDiagnostics;

  /// No description provided for @databaseDiagnosticsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show database content details'**
  String get databaseDiagnosticsSubtitle;

  /// No description provided for @appSettings.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get appSettings;

  /// No description provided for @manageEntities.
  ///
  /// In en, this message translates to:
  /// **'Manage Entities'**
  String get manageEntities;

  /// No description provided for @manageEntitiesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add and edit payment/receipt entities'**
  String get manageEntitiesSubtitle;

  /// No description provided for @manageExpenseTypes.
  ///
  /// In en, this message translates to:
  /// **'Manage Expense Types'**
  String get manageExpenseTypes;

  /// No description provided for @managePaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Manage Payment Methods'**
  String get managePaymentMethods;

  /// No description provided for @managePaymentMethodsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add and edit available payment methods'**
  String get managePaymentMethodsSubtitle;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// No description provided for @aboutAppSubtitle.
  ///
  /// In en, this message translates to:
  /// **'App and developer information'**
  String get aboutAppSubtitle;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// No description provided for @greek.
  ///
  /// In en, this message translates to:
  /// **'Greek'**
  String get greek;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @importDatabase.
  ///
  /// In en, this message translates to:
  /// **'Import Database'**
  String get importDatabase;

  /// No description provided for @importDatabaseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Replace current database with external file'**
  String get importDatabaseSubtitle;

  /// No description provided for @resetDatabase.
  ///
  /// In en, this message translates to:
  /// **'Reset Database'**
  String get resetDatabase;

  /// No description provided for @resetDatabaseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all data and settings from current file'**
  String get resetDatabaseSubtitle;

  /// No description provided for @confirmDatabaseImport.
  ///
  /// In en, this message translates to:
  /// **'Confirm Database Import'**
  String get confirmDatabaseImport;

  /// No description provided for @databaseImportWarning.
  ///
  /// In en, this message translates to:
  /// **'The current database will be replaced with the selected file. This action cannot be undone.\n\nDo you want to continue?'**
  String get databaseImportWarning;

  /// No description provided for @importingDatabase.
  ///
  /// In en, this message translates to:
  /// **'Importing database...'**
  String get importingDatabase;

  /// No description provided for @databaseImportedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Database imported successfully!'**
  String get databaseImportedSuccessfully;

  /// No description provided for @errorImportingDatabase.
  ///
  /// In en, this message translates to:
  /// **'Error importing database'**
  String get errorImportingDatabase;

  /// No description provided for @shareFileQuestion.
  ///
  /// In en, this message translates to:
  /// **'Do you want to share the file now?'**
  String get shareFileQuestion;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @errorSharing.
  ///
  /// In en, this message translates to:
  /// **'Error sharing'**
  String get errorSharing;

  /// No description provided for @fileExportedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'File exported successfully to'**
  String get fileExportedSuccessfully;

  /// No description provided for @databaseExportedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Database exported successfully to'**
  String get databaseExportedSuccessfully;

  /// No description provided for @saveCancelled.
  ///
  /// In en, this message translates to:
  /// **'Save cancelled'**
  String get saveCancelled;

  /// No description provided for @errorExportingExcel.
  ///
  /// In en, this message translates to:
  /// **'Error exporting Excel'**
  String get errorExportingExcel;

  /// No description provided for @errorExportingDatabase.
  ///
  /// In en, this message translates to:
  /// **'Error exporting database'**
  String get errorExportingDatabase;

  /// No description provided for @chooseLocationToSaveExcel.
  ///
  /// In en, this message translates to:
  /// **'Choose location to save Excel file'**
  String get chooseLocationToSaveExcel;

  /// No description provided for @chooseLocationToSaveDatabase.
  ///
  /// In en, this message translates to:
  /// **'Choose location to save database'**
  String get chooseLocationToSaveDatabase;

  /// No description provided for @selectDatabaseFile.
  ///
  /// In en, this message translates to:
  /// **'Select database file'**
  String get selectDatabaseFile;

  /// No description provided for @excelTransactionsFile.
  ///
  /// In en, this message translates to:
  /// **'Excel Transactions File'**
  String get excelTransactionsFile;

  /// No description provided for @exodaDatabaseFile.
  ///
  /// In en, this message translates to:
  /// **'Exoda Database File'**
  String get exodaDatabaseFile;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @netBalance.
  ///
  /// In en, this message translates to:
  /// **'Net Balance'**
  String get netBalance;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @noTransactionsYet.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactionsYet;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @familyInsights.
  ///
  /// In en, this message translates to:
  /// **'Family Insights'**
  String get familyInsights;

  /// No description provided for @familyMember.
  ///
  /// In en, this message translates to:
  /// **'Family Member'**
  String get familyMember;

  /// No description provided for @spendingShare.
  ///
  /// In en, this message translates to:
  /// **'Spending Share'**
  String get spendingShare;

  /// No description provided for @noFamilyData.
  ///
  /// In en, this message translates to:
  /// **'No family data'**
  String get noFamilyData;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'el', 'en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'el':
      return AppLocalizationsEl();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
