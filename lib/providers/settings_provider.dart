import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:compounding_calculator/services/storage_service.dart';
import 'package:compounding_calculator/utils/constants.dart';

class SettingsState {
  final bool isDarkMode;
  final String selectedCurrency;
  final int decimalPrecision;

  const SettingsState({
    required this.isDarkMode,
    required this.selectedCurrency,
    required this.decimalPrecision,
  });

  SettingsState copyWith({
    bool? isDarkMode,
    String? selectedCurrency,
    int? decimalPrecision,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      selectedCurrency: selectedCurrency ?? this.selectedCurrency,
      decimalPrecision: decimalPrecision ?? this.decimalPrecision,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final StorageService _storageService;

  SettingsNotifier(this._storageService)
    : super(
        const SettingsState(
          isDarkMode: AppConstants.defaultDarkMode,
          selectedCurrency: AppConstants.defaultCurrency,
          decimalPrecision: AppConstants.defaultDecimalPrecision,
        ),
      ) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final isDarkMode =
        await _storageService.getBool(AppConstants.isDarkModeKey) ??
        AppConstants.defaultDarkMode;
    final selectedCurrency =
        await _storageService.getString(AppConstants.selectedCurrencyKey) ??
        AppConstants.defaultCurrency;
    final decimalPrecision =
        await _storageService.getInt(AppConstants.decimalPrecisionKey) ??
        AppConstants.defaultDecimalPrecision;

    state = SettingsState(
      isDarkMode: isDarkMode,
      selectedCurrency: selectedCurrency,
      decimalPrecision: decimalPrecision,
    );
  }

  Future<void> toggleDarkMode() async {
    final newValue = !state.isDarkMode;
    await _storageService.setBool(AppConstants.isDarkModeKey, newValue);
    state = state.copyWith(isDarkMode: newValue);
  }

  Future<void> setCurrency(String currency) async {
    await _storageService.setString(AppConstants.selectedCurrencyKey, currency);
    state = state.copyWith(selectedCurrency: currency);
  }

  Future<void> setDecimalPrecision(int precision) async {
    await _storageService.setInt(AppConstants.decimalPrecisionKey, precision);
    state = state.copyWith(decimalPrecision: precision);
  }
}

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) {
    final storageService = ref.watch(storageServiceProvider);
    return SettingsNotifier(storageService);
  },
);
