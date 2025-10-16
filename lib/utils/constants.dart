import 'package:flutter/cupertino.dart';

class AppColors {
  static const Color primary = CupertinoColors.systemBlue;
  static const Color secondary = CupertinoColors.systemTeal;
  static const Color success = CupertinoColors.systemGreen;
  static const Color warning = CupertinoColors.systemOrange;
  static const Color error = CupertinoColors.systemRed;
  static const Color surface = CupertinoColors.systemBackground;
  static const Color secondaryBackground =
      CupertinoColors.secondarySystemBackground;
}

class AppConstants {
  static const String appName = 'Compound Interest Calculator';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String isDarkModeKey = 'isDarkMode';
  static const String selectedCurrencyKey = 'selectedCurrency';
  static const String decimalPrecisionKey = 'decimalPrecision';
  static const String calculationHistoryKey = 'calculationHistory';

  // Default Values
  static const bool defaultDarkMode = false;
  static const String defaultCurrency = 'USD';
  static const int defaultDecimalPrecision = 2;
  static const int maxHistoryItems = 100;

  // Calculation Limits
  static const double minPrincipal = 0.01;
  static const double maxPrincipal = 1000000000.0;
  static const double minRate = 0.01;
  static const double maxRate = 100.0;
  static const double minTime = 0.01;
  static const double maxTime = 100.0;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;
}

enum CompoundingFrequency {
  daily(365, 'Daily'),
  monthly(12, 'Monthly'),
  quarterly(4, 'Quarterly'),
  semiAnnual(2, 'Semi-Annual'),
  annual(1, 'Annual');

  const CompoundingFrequency(this.value, this.label);

  final int value;
  final String label;
}

enum TimeUnit {
  months('Months'),
  years('Years');

  const TimeUnit(this.label);

  final String label;
}

enum CalculationType {
  simple('Simple Interest'),
  compound('Compound Interest'),
  continuous('Continuous Compounding');

  const CalculationType(this.label);

  final String label;
}

class CurrencyInfo {
  final String code;
  final String symbol;
  final String name;

  const CurrencyInfo({
    required this.code,
    required this.symbol,
    required this.name,
  });
}

class AppCurrencies {
  static const List<CurrencyInfo> currencies = [
    CurrencyInfo(code: 'USD', symbol: r'$', name: 'US Dollar'),
    CurrencyInfo(code: 'EUR', symbol: '€', name: 'Euro'),
    CurrencyInfo(code: 'GBP', symbol: '£', name: 'British Pound'),
    CurrencyInfo(code: 'INR', symbol: '₹', name: 'Indian Rupee'),
    CurrencyInfo(code: 'JPY', symbol: '¥', name: 'Japanese Yen'),
    CurrencyInfo(code: 'CNY', symbol: '¥', name: 'Chinese Yuan'),
    CurrencyInfo(code: 'CAD', symbol: r'C$', name: 'Canadian Dollar'),
    CurrencyInfo(code: 'AUD', symbol: r'A$', name: 'Australian Dollar'),
  ];

  static CurrencyInfo getCurrencyByCode(String code) {
    return currencies.firstWhere(
      (currency) => currency.code == code,
      orElse: () => currencies.first,
    );
  }
}

class FormValidators {
  static String? validatePrincipal(String? value) {
    if (value == null || value.isEmpty) {
      return 'Principal amount is required';
    }

    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Please enter a valid number';
    }

    if (amount < AppConstants.minPrincipal) {
      return 'Principal must be at least ${AppConstants.minPrincipal}';
    }

    if (amount > AppConstants.maxPrincipal) {
      return 'Principal cannot exceed ${AppConstants.maxPrincipal}';
    }

    return null;
  }

  static String? validateRate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Interest rate is required';
    }

    final rate = double.tryParse(value);
    if (rate == null) {
      return 'Please enter a valid number';
    }

    if (rate < AppConstants.minRate) {
      return 'Rate must be at least ${AppConstants.minRate}%';
    }

    if (rate > AppConstants.maxRate) {
      return 'Rate cannot exceed ${AppConstants.maxRate}%';
    }

    return null;
  }

  static String? validateTime(String? value) {
    if (value == null || value.isEmpty) {
      return 'Time period is required';
    }

    final time = double.tryParse(value);
    if (time == null) {
      return 'Please enter a valid number';
    }

    if (time < AppConstants.minTime) {
      return 'Time must be at least ${AppConstants.minTime}';
    }

    if (time > AppConstants.maxTime) {
      return 'Time cannot exceed ${AppConstants.maxTime} years';
    }

    return null;
  }
}

// Cupertino-specific styling helpers
class CupertinoStyles {
  static const TextStyle navigationTitle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: CupertinoColors.label,
  );

  static const TextStyle largTitle = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.bold,
    color: CupertinoColors.label,
  );

  static const TextStyle headline = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: CupertinoColors.label,
  );

  static const TextStyle body = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.normal,
    color: CupertinoColors.label,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: CupertinoColors.secondaryLabel,
  );

  static BoxDecoration cardDecoration(BuildContext context) {
    return BoxDecoration(
      color: CupertinoTheme.of(context).scaffoldBackgroundColor,
      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      boxShadow: [
        BoxShadow(
          color: CupertinoColors.systemGrey.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}
