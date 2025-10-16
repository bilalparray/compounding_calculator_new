import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:compounding_calculator/providers/calculation_provider.dart';
import 'package:compounding_calculator/providers/settings_provider.dart';
import 'package:compounding_calculator/utils/constants.dart';
import 'package:compounding_calculator/utils/formatters.dart';
import 'package:compounding_calculator/widgets/amortization_table.dart';

class ChartsScreen extends ConsumerStatefulWidget {
  const ChartsScreen({super.key});

  @override
  ConsumerState<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends ConsumerState<ChartsScreen> {
  int _selectedSegment = 0;

  @override
  Widget build(BuildContext context) {
    final calculationState = ref.watch(calculationProvider);
    final settings = ref.watch(settingsProvider);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Charts & Analysis'),
        backgroundColor: CupertinoColors.systemBackground,
      ),
      child: SafeArea(
        child: calculationState.currentResult == null
            ? _buildEmptyState()
            : Column(
                children: [
                  // Segment Control
                  Padding(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    child: CupertinoSlidingSegmentedControl<int>(
                      groupValue: _selectedSegment,
                      children: const {
                        0: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Text('Growth Chart'),
                        ),
                        1: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Text('Distribution'),
                        ),
                        2: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Text('Breakdown'),
                        ),
                      },
                      onValueChanged: (value) {
                        setState(() {
                          _selectedSegment = value ?? 0;
                        });
                      },
                    ),
                  ),

                  // Chart Content
                  Expanded(
                    child: _buildChartContent(
                      calculationState.currentResult!,
                      AppCurrencies.getCurrencyByCode(
                        settings.selectedCurrency,
                      ).symbol,
                      settings.decimalPrecision,
                    ),
                  ),
                ],
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
            CupertinoIcons.chart_bar,
            size: 64,
            color: CupertinoColors.systemGrey,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            'No calculation to display',
            style: CupertinoStyles.headline.copyWith(
              color: CupertinoColors.systemGrey,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'Perform a calculation to see charts and analysis',
            style: CupertinoStyles.body.copyWith(
              color: CupertinoColors.systemGrey2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChartContent(
    dynamic result,
    String currencySymbol,
    int decimalPrecision,
  ) {
    switch (_selectedSegment) {
      case 0:
        return _buildGrowthChart(result, currencySymbol, decimalPrecision);
      case 1:
        return _buildDistributionChart(
          result,
          currencySymbol,
          decimalPrecision,
        );
      case 2:
        return AmortizationTable(
          yearlyBreakdown: result.yearlyBreakdown,
          currencySymbol: currencySymbol,
          decimalPrecision: decimalPrecision,
        );
      default:
        return _buildGrowthChart(result, currencySymbol, decimalPrecision);
    }
  }

  Widget _buildGrowthChart(
    dynamic result,
    String currencySymbol,
    int decimalPrecision,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Growth Over Time', style: CupertinoStyles.largTitle),
          const SizedBox(height: AppConstants.defaultPadding),
          Container(
            height: 300,
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: CupertinoStyles.cardDecoration(context),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          CurrencyFormatter.formatCompact(
                            value,
                            currencySymbol,
                          ),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          'Y${value.toInt()}',
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      FlSpot(0, result.principal),
                      FlSpot(result.time, result.finalAmount),
                    ],
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionChart(
    dynamic result,
    String currencySymbol,
    int decimalPrecision,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Principal vs Interest', style: CupertinoStyles.largTitle),
          const SizedBox(height: AppConstants.defaultPadding),
          Container(
            height: 300,
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: CupertinoStyles.cardDecoration(context),
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: result.principal,
                    title:
                        'Principal\n${CurrencyFormatter.formatCompact(result.principal, currencySymbol)}',
                    color: AppColors.primary,
                    radius: 100,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: result.totalInterest,
                    title:
                        'Interest\n${CurrencyFormatter.formatCompact(result.totalInterest, currencySymbol)}',
                    color: AppColors.secondary,
                    radius: 100,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.white,
                    ),
                  ),
                ],
                centerSpaceRadius: 50,
                sectionsSpace: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
