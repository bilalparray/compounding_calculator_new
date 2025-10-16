import 'package:flutter/cupertino.dart';
import 'package:compounding_calculator/utils/constants.dart';

class CalculationForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController principalController;
  final TextEditingController rateController;
  final TextEditingController timeController;
  final TextEditingController additionalContributionController;
  final TextEditingController targetAmountController;
  final CompoundingFrequency selectedFrequency;
  final TimeUnit selectedTimeUnit;
  final CalculationType selectedCalculationType;
  final Function(CompoundingFrequency) onFrequencyChanged;
  final Function(TimeUnit) onTimeUnitChanged;
  final Function(CalculationType) onCalculationTypeChanged;

  const CalculationForm({
    super.key,
    required this.formKey,
    required this.principalController,
    required this.rateController,
    required this.timeController,
    required this.additionalContributionController,
    required this.targetAmountController,
    required this.selectedFrequency,
    required this.selectedTimeUnit,
    required this.selectedCalculationType,
    required this.onFrequencyChanged,
    required this.onTimeUnitChanged,
    required this.onCalculationTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calculation Type Selector
          _buildSectionTitle('Calculation Type'),
          CupertinoSlidingSegmentedControl<CalculationType>(
            groupValue: selectedCalculationType,
            children: {
              for (final type in CalculationType.values)
                type: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Text(type.label, style: const TextStyle(fontSize: 12)),
                ),
            },
            onValueChanged: (value) {
              if (value != null) onCalculationTypeChanged(value);
            },
          ),

          const SizedBox(height: AppConstants.defaultPadding),

          // Principal Amount
          _buildSectionTitle('Principal Amount'),
          CupertinoTextField(
            controller: principalController,
            placeholder: 'Enter principal amount',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefix: const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(CupertinoIcons.money_dollar_circle),
            ),
          ),

          const SizedBox(height: AppConstants.defaultPadding),

          // Interest Rate
          _buildSectionTitle('Annual Interest Rate (%)'),
          CupertinoTextField(
            controller: rateController,
            placeholder: 'Enter interest rate',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefix: const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(CupertinoIcons.percent),
            ),
          ),

          const SizedBox(height: AppConstants.defaultPadding),

          // Time Period
          _buildSectionTitle('Time Period'),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: CupertinoTextField(
                  controller: timeController,
                  placeholder: 'Enter time',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  prefix: const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(CupertinoIcons.clock),
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.smallPadding),
              Expanded(
                child: CupertinoSlidingSegmentedControl<TimeUnit>(
                  groupValue: selectedTimeUnit,
                  children: {
                    for (final unit in TimeUnit.values) unit: Text(unit.label),
                  },
                  onValueChanged: (value) {
                    if (value != null) onTimeUnitChanged(value);
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.defaultPadding),

          // Compounding Frequency (only for compound interest)
          if (selectedCalculationType == CalculationType.compound) ...[
            _buildSectionTitle('Compounding Frequency'),
            SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                color: CupertinoColors.systemGrey6,
                onPressed: () => _showFrequencyPicker(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedFrequency.label,
                      style: const TextStyle(color: CupertinoColors.label),
                    ),
                    const Icon(
                      CupertinoIcons.chevron_down,
                      color: CupertinoColors.label,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
          ],

          // Additional Contribution (Optional)
          _buildSectionTitle('Additional Contribution (Optional)'),
          CupertinoTextField(
            controller: additionalContributionController,
            placeholder: selectedTimeUnit == TimeUnit.years
                ? 'Annual contribution'
                : 'Monthly contribution',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefix: const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(CupertinoIcons.plus_circle),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      child: Text(title, style: CupertinoStyles.headline),
    );
  }

  void _showFrequencyPicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 250,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            Container(
              height: 44,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: CupertinoColors.separator,
                    width: 0.33,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  CupertinoButton(
                    child: const Text('Done'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 32,
                onSelectedItemChanged: (index) {
                  onFrequencyChanged(CompoundingFrequency.values[index]);
                },
                children: CompoundingFrequency.values
                    .map((frequency) => Text(frequency.label))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
