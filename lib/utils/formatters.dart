import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(
    double amount,
    String currencySymbol,
    int decimalPlaces,
  ) {
    final formatter = NumberFormat.currency(
      symbol: currencySymbol,
      decimalDigits: decimalPlaces,
    );
    return formatter.format(amount);
  }

  static String formatCompact(double amount, String currencySymbol) {
    if (amount >= 1000000000) {
      return '$currencySymbol${(amount / 1000000000).toStringAsFixed(1)}B';
    } else if (amount >= 1000000) {
      return '$currencySymbol${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '$currencySymbol${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '$currencySymbol${amount.toStringAsFixed(2)}';
  }
}

class PercentageFormatter {
  static String format(double percentage, int decimalPlaces) {
    return '${percentage.toStringAsFixed(decimalPlaces)}%';
  }
}

class NumberFormatter {
  static String format(double number, int decimalPlaces) {
    return number.toStringAsFixed(decimalPlaces);
  }

  static String formatWithCommas(double number, int decimalPlaces) {
    final pattern = '#,##0.${'0' * decimalPlaces}';
    final formatter = NumberFormat(pattern);
    return formatter.format(number);
  }
}

class DateFormatter {
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy HH:mm').format(dateTime);
  }
}
