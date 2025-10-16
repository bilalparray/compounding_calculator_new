import 'package:flutter/cupertino.dart';
import 'package:compounding_calculator/models/calculation_model.dart';
import 'package:compounding_calculator/utils/constants.dart';
import 'package:compounding_calculator/utils/formatters.dart';

class ResultDisplay extends StatelessWidget {
  final CalculationResult result;
  final String currencySymbol;
  final int decimalPrecision;

  const ResultDisplay({
    super.key,
    required this.result,
    required this.currencySymbol,
    required this.decimalPrecision,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: CupertinoStyles.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Results', style: CupertinoStyles.largTitle),
          const SizedBox(height: AppConstants.defaultPadding),

          // Main Results
          _buildResultRow(
            'Final Amount:',
            CurrencyFormatter.format(
              result.finalAmount,
              currencySymbol,
              decimalPrecision,
            ),
            isHighlighted: true,
          ),

          _buildResultRow(
            'Principal:',
            CurrencyFormatter.format(
              result.principal,
              currencySymbol,
              decimalPrecision,
            ),
          ),

          _buildResultRow(
            'Total Interest:',
            CurrencyFormatter.format(
              result.totalInterest,
              currencySymbol,
              decimalPrecision,
            ),
          ),

          _buildResultRow(
            'Interest Rate:',
            PercentageFormatter.format(result.rate, 2),
          ),

          _buildResultRow(
            'Time Period:',
            '${NumberFormatter.format(result.time, 1)} years',
          ),

          const SizedBox(height: AppConstants.defaultPadding),

          // Formula Used
          Container(
            padding: const EdgeInsets.all(AppConstants.smallPadding),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(AppConstants.smallPadding),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Formula Used:',
                  style: CupertinoStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  result.formulaUsed,
                  style: CupertinoStyles.body.copyWith(
                    fontFamily: 'Courier',
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(
    String label,
    String value, {
    bool isHighlighted = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: CupertinoStyles.body.copyWith(
              color: CupertinoColors.secondaryLabel,
            ),
          ),
          Text(
            value,
            style: CupertinoStyles.body.copyWith(
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              color: isHighlighted ? AppColors.primary : CupertinoColors.label,
              fontSize: isHighlighted ? 18 : 17,
            ),
          ),
        ],
      ),
    );
  }
}
