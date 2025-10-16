import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:compounding_calculator/models/calculation_model.dart';
import 'package:compounding_calculator/providers/calculation_provider.dart';
import 'package:compounding_calculator/providers/settings_provider.dart';
import 'package:compounding_calculator/utils/constants.dart';
import 'package:compounding_calculator/widgets/calculation_form.dart';
import 'package:compounding_calculator/widgets/result_display.dart';

class CalculatorScreen extends ConsumerStatefulWidget {
  const CalculatorScreen({super.key});

  @override
  ConsumerState<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends ConsumerState<CalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _principalController = TextEditingController();
  final _rateController = TextEditingController();
  final _timeController = TextEditingController();
  final _additionalContributionController = TextEditingController();
  final _targetAmountController = TextEditingController();

  CompoundingFrequency _selectedFrequency = CompoundingFrequency.annual;
  TimeUnit _selectedTimeUnit = TimeUnit.years;
  CalculationType _selectedCalculationType = CalculationType.compound;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final calculationState = ref.watch(calculationProvider);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Calculator'),
        backgroundColor: CupertinoColors.systemBackground,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            children: [
              // Input Form
              Container(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                decoration: CupertinoStyles.cardDecoration(context),
                child: CalculationForm(
                  formKey: _formKey,
                  principalController: _principalController,
                  rateController: _rateController,
                  timeController: _timeController,
                  additionalContributionController:
                      _additionalContributionController,
                  targetAmountController: _targetAmountController,
                  selectedFrequency: _selectedFrequency,
                  selectedTimeUnit: _selectedTimeUnit,
                  selectedCalculationType: _selectedCalculationType,
                  onFrequencyChanged: (frequency) {
                    setState(() {
                      _selectedFrequency = frequency;
                    });
                  },
                  onTimeUnitChanged: (timeUnit) {
                    setState(() {
                      _selectedTimeUnit = timeUnit;
                    });
                  },
                  onCalculationTypeChanged: (calculationType) {
                    setState(() {
                      _selectedCalculationType = calculationType;
                    });
                  },
                ),
              ),

              const SizedBox(height: AppConstants.defaultPadding),

              // Calculate Button
              SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  onPressed: _calculateResult,
                  child: const Text(
                    'Calculate',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: AppConstants.defaultPadding),

              // Results
              if (calculationState.currentResult != null) ...[
                ResultDisplay(
                  result: calculationState.currentResult!,
                  currencySymbol: AppCurrencies.getCurrencyByCode(
                    settings.selectedCurrency,
                  ).symbol,
                  decimalPrecision: settings.decimalPrecision,
                ),

                const SizedBox(height: AppConstants.defaultPadding),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: CupertinoButton(
                        onPressed: _saveCalculation,
                        color: AppColors.secondary,
                        child: const Text('Save'),
                      ),
                    ),
                    const SizedBox(width: AppConstants.smallPadding),
                    Expanded(
                      child: CupertinoButton(
                        onPressed: _clearForm,
                        color: CupertinoColors.systemGrey,
                        child: const Text('Clear'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _calculateResult() {
    if (_formKey.currentState?.validate() ?? false) {
      final principal = double.parse(_principalController.text);
      final rate = double.parse(_rateController.text);
      final time = double.parse(_timeController.text);
      final additionalContribution =
          double.tryParse(_additionalContributionController.text) ?? 0.0;
      final targetAmount = double.tryParse(_targetAmountController.text) ?? 0.0;

      final calculation = CalculationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        principal: principal,
        rate: rate,
        time: time,
        timeUnit: _selectedTimeUnit,
        frequency: _selectedFrequency,
        calculationType: _selectedCalculationType,
        additionalMonthlyContribution: _selectedTimeUnit == TimeUnit.months
            ? additionalContribution
            : 0.0,
        additionalYearlyContribution: _selectedTimeUnit == TimeUnit.years
            ? additionalContribution
            : 0.0,
        targetAmount: targetAmount,
        createdAt: DateTime.now(),
        title: 'Calculation ${DateTime.now().toString().substring(0, 16)}',
      );

      ref.read(calculationProvider.notifier).calculate(calculation);
    }
  }

  void _saveCalculation() {
    final calculationState = ref.read(calculationProvider);
    if (calculationState.currentCalculation != null) {
      ref
          .read(calculationProvider.notifier)
          .saveToHistory(calculationState.currentCalculation!);

      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Saved'),
          content: const Text('Calculation has been saved to history.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }

  void _clearForm() {
    _principalController.clear();
    _rateController.clear();
    _timeController.clear();
    _additionalContributionController.clear();
    _targetAmountController.clear();

    setState(() {
      _selectedFrequency = CompoundingFrequency.annual;
      _selectedTimeUnit = TimeUnit.years;
      _selectedCalculationType = CalculationType.compound;
    });

    ref.read(calculationProvider.notifier).clearResult();
  }

  @override
  void dispose() {
    _principalController.dispose();
    _rateController.dispose();
    _timeController.dispose();
    _additionalContributionController.dispose();
    _targetAmountController.dispose();
    super.dispose();
  }
}
