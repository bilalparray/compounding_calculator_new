import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:compounding_calculator/models/calculation_model.dart';
import 'package:compounding_calculator/providers/calculation_provider.dart';
import 'package:compounding_calculator/providers/settings_provider.dart';
import 'package:compounding_calculator/utils/constants.dart';
import 'package:compounding_calculator/utils/formatters.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calculationState = ref.watch(calculationProvider);
    final settings = ref.watch(settingsProvider);
    final currencySymbol = AppCurrencies.getCurrencyByCode(
      settings.selectedCurrency,
    ).symbol;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('History'),
        backgroundColor: CupertinoColors.systemBackground,
        trailing: calculationState.history.isNotEmpty
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Text('Clear All'),
                onPressed: () => _showClearConfirmation(context, ref),
              )
            : null,
      ),
      child: SafeArea(
        child: calculationState.history.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                itemCount: calculationState.history.length,
                itemBuilder: (context, index) {
                  final calculation = calculationState.history[index];
                  return _buildHistoryItem(
                    context,
                    ref,
                    calculation,
                    currencySymbol,
                    settings.decimalPrecision,
                  );
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.clock,
            size: 64,
            color: CupertinoColors.systemGrey,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            'No calculations yet',
            style: CupertinoStyles.headline.copyWith(
              color: CupertinoColors.systemGrey,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'Your calculation history will appear here',
            style: CupertinoStyles.body.copyWith(
              color: CupertinoColors.systemGrey2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(
    BuildContext context,
    WidgetRef ref,
    CalculationModel calculation,
    String currencySymbol,
    int decimalPrecision,
  ) {
    final result = calculation.calculateResult();

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: CupertinoStyles.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  calculation.title.isNotEmpty
                      ? calculation.title
                      : 'Calculation',
                  style: CupertinoStyles.headline,
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Icon(
                  CupertinoIcons.delete,
                  color: CupertinoColors.systemRed,
                ),
                onPressed: () =>
                    _showDeleteConfirmation(context, ref, calculation.id),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.smallPadding),

          Text(
            DateFormatter.formatDateTime(calculation.createdAt),
            style: CupertinoStyles.caption,
          ),

          const SizedBox(height: AppConstants.defaultPadding),

          // Key Details
          Row(
            children: [
              Expanded(
                child: _buildDetailColumn(
                  'Principal',
                  CurrencyFormatter.format(
                    calculation.principal,
                    currencySymbol,
                    decimalPrecision,
                  ),
                ),
              ),
              Expanded(
                child: _buildDetailColumn(
                  'Rate',
                  PercentageFormatter.format(calculation.rate, 2),
                ),
              ),
              Expanded(
                child: _buildDetailColumn(
                  'Time',
                  '${NumberFormatter.format(calculation.time, 1)} ${calculation.timeUnit.label.toLowerCase()}',
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.defaultPadding),

          // Result Summary
          Container(
            padding: const EdgeInsets.all(AppConstants.smallPadding),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.smallPadding),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Final Amount:',
                  style: CupertinoStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  CurrencyFormatter.format(
                    result.finalAmount,
                    currencySymbol,
                    decimalPrecision,
                  ),
                  style: CupertinoStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppConstants.defaultPadding),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  color: AppColors.primary,
                  child: const Text('Recalculate'),
                  onPressed: () => _recalculate(context, ref, calculation),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: CupertinoStyles.caption),
        const SizedBox(height: 2),
        Text(
          value,
          style: CupertinoStyles.body.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  void _showClearConfirmation(BuildContext context, WidgetRef ref) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Clear History'),
        content: const Text(
          'Are you sure you want to clear all calculation history? This action cannot be undone.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Clear All'),
            onPressed: () {
              ref.read(calculationProvider.notifier).clearHistory();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, String id) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Calculation'),
        content: const Text(
          'Are you sure you want to delete this calculation?',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Delete'),
            onPressed: () {
              ref.read(calculationProvider.notifier).deleteFromHistory(id);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _recalculate(
    BuildContext context,
    WidgetRef ref,
    CalculationModel calculation,
  ) {
    ref.read(calculationProvider.notifier).calculate(calculation);
  }
}
