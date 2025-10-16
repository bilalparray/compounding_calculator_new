import 'package:flutter/cupertino.dart';
import 'package:compounding_calculator/models/calculation_model.dart';
import 'package:compounding_calculator/utils/constants.dart';
import 'package:compounding_calculator/utils/formatters.dart';

class AmortizationTable extends StatelessWidget {
  final List<YearlyBreakdown> yearlyBreakdown;
  final String currencySymbol;
  final int decimalPrecision;

  const AmortizationTable({
    super.key,
    required this.yearlyBreakdown,
    required this.currencySymbol,
    required this.decimalPrecision,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Yearly Breakdown', style: CupertinoStyles.largTitle),
          const SizedBox(height: AppConstants.defaultPadding),

          Container(
            decoration: CupertinoStyles.cardDecoration(context),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(AppConstants.smallPadding),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppConstants.borderRadius),
                      topRight: Radius.circular(AppConstants.borderRadius),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Year',
                          style: CupertinoStyles.body.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Starting',
                          style: CupertinoStyles.body.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Interest',
                          style: CupertinoStyles.body.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Ending',
                          style: CupertinoStyles.body.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),

                // Show placeholder data if no breakdown available
                if (yearlyBreakdown.isEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    child: Text(
                      'Yearly breakdown will be shown here after calculation',
                      style: CupertinoStyles.body.copyWith(
                        color: CupertinoColors.systemGrey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ] else ...[
                  // Rows
                  ...yearlyBreakdown.asMap().entries.map((entry) {
                    final index = entry.key;
                    final breakdown = entry.value;
                    final isEven = index % 2 == 0;

                    return Container(
                      padding: const EdgeInsets.all(AppConstants.smallPadding),
                      decoration: BoxDecoration(
                        color: isEven
                            ? CupertinoColors.systemBackground
                            : CupertinoColors.systemGrey6.withOpacity(0.3),
                        borderRadius: index == yearlyBreakdown.length - 1
                            ? const BorderRadius.only(
                                bottomLeft: Radius.circular(
                                  AppConstants.borderRadius,
                                ),
                                bottomRight: Radius.circular(
                                  AppConstants.borderRadius,
                                ),
                              )
                            : null,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text(
                              breakdown.year.toString(),
                              style: CupertinoStyles.body,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              CurrencyFormatter.formatCompact(
                                breakdown.startingBalance,
                                currencySymbol,
                              ),
                              style: CupertinoStyles.body,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              CurrencyFormatter.formatCompact(
                                breakdown.interestEarned,
                                currencySymbol,
                              ),
                              style: CupertinoStyles.body.copyWith(
                                color: AppColors.success,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              CurrencyFormatter.formatCompact(
                                breakdown.endingBalance,
                                currencySymbol,
                              ),
                              style: CupertinoStyles.body.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),

          if (yearlyBreakdown.isNotEmpty) ...[
            const SizedBox(height: AppConstants.defaultPadding),

            // Summary
            Container(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Interest Earned:',
                        style: CupertinoStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(
                          yearlyBreakdown.last.totalInterest,
                          currencySymbol,
                          decimalPrecision,
                        ),
                        style: CupertinoStyles.body.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.smallPadding),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Final Balance:',
                        style: CupertinoStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(
                          yearlyBreakdown.last.endingBalance,
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
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
