import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:compounding_calculator/models/calculation_model.dart';
import 'package:compounding_calculator/services/storage_service.dart';
import 'package:compounding_calculator/utils/constants.dart';
import 'package:compounding_calculator/providers/settings_provider.dart';

class CalculationState {
  final CalculationModel? currentCalculation;
  final CalculationResult? currentResult;
  final List<CalculationModel> history;
  final bool isLoading;

  const CalculationState({
    this.currentCalculation,
    this.currentResult,
    this.history = const [],
    this.isLoading = false,
  });

  CalculationState copyWith({
    CalculationModel? currentCalculation,
    CalculationResult? currentResult,
    List<CalculationModel>? history,
    bool? isLoading,
  }) {
    return CalculationState(
      currentCalculation: currentCalculation ?? this.currentCalculation,
      currentResult: currentResult ?? this.currentResult,
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class CalculationNotifier extends StateNotifier<CalculationState> {
  final StorageService _storageService;

  CalculationNotifier(this._storageService) : super(const CalculationState()) {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final historyJson = await _storageService.getStringList(
      AppConstants.calculationHistoryKey,
    );
    if (historyJson != null) {
      final history = historyJson
          .map((json) => CalculationModel.fromJson(jsonDecode(json)))
          .toList();
      state = state.copyWith(history: history);
    }
  }

  void calculate(CalculationModel calculation) {
    state = state.copyWith(isLoading: true);

    final result = calculation.calculateResult();

    state = state.copyWith(
      currentCalculation: calculation,
      currentResult: result,
      isLoading: false,
    );
  }

  Future<void> saveToHistory(CalculationModel calculation) async {
    final newHistory = [calculation, ...state.history];

    // Limit history to max items
    if (newHistory.length > AppConstants.maxHistoryItems) {
      newHistory.removeRange(AppConstants.maxHistoryItems, newHistory.length);
    }

    final historyJson = newHistory
        .map((calc) => jsonEncode(calc.toJson()))
        .toList();
    await _storageService.setStringList(
      AppConstants.calculationHistoryKey,
      historyJson,
    );

    state = state.copyWith(history: newHistory);
  }

  Future<void> deleteFromHistory(String id) async {
    final newHistory = state.history.where((calc) => calc.id != id).toList();

    final historyJson = newHistory
        .map((calc) => jsonEncode(calc.toJson()))
        .toList();
    await _storageService.setStringList(
      AppConstants.calculationHistoryKey,
      historyJson,
    );

    state = state.copyWith(history: newHistory);
  }

  void clearResult() {
    state = state.copyWith(currentCalculation: null, currentResult: null);
  }

  Future<void> clearHistory() async {
    await _storageService.remove(AppConstants.calculationHistoryKey);
    state = state.copyWith(history: []);
  }
}

final calculationProvider =
    StateNotifierProvider<CalculationNotifier, CalculationState>((ref) {
      final storageService = ref.watch(storageServiceProvider);
      return CalculationNotifier(storageService);
    });
