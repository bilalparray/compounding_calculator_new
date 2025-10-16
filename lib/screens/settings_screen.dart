import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:compounding_calculator/providers/settings_provider.dart';
import 'package:compounding_calculator/utils/constants.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Settings'),
        backgroundColor: CupertinoColors.systemBackground,
      ),
      child: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: AppConstants.defaultPadding),

            // Appearance Section
            _buildSection('Appearance', [
              _buildSwitchTile(
                context,
                'Dark Mode',
                settings.isDarkMode,
                CupertinoIcons.moon,
                () => ref.read(settingsProvider.notifier).toggleDarkMode(),
              ),
            ]),

            const SizedBox(height: AppConstants.defaultPadding),

            // Currency Section
            _buildSection('Currency', [
              _buildNavigationTile(
                context,
                'Currency',
                AppCurrencies.getCurrencyByCode(settings.selectedCurrency).name,
                CupertinoIcons.money_dollar_circle,
                () => _showCurrencyPicker(context, ref),
              ),
            ]),

            const SizedBox(height: AppConstants.defaultPadding),

            // Precision Section
            _buildSection('Display', [
              _buildNavigationTile(
                context,
                'Decimal Precision',
                '${settings.decimalPrecision} digits',
                CupertinoIcons.number,
                () => _showPrecisionPicker(context, ref),
              ),
            ]),

            const SizedBox(height: AppConstants.defaultPadding),

            // About Section
            _buildSection('About', [
              _buildInfoTile(
                context,
                'Version',
                AppConstants.appVersion,
                CupertinoIcons.info,
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: AppConstants.smallPadding,
          ),
          child: Text(
            title.toUpperCase(),
            style: CupertinoStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
          ),
          decoration: BoxDecoration(
            color: CupertinoColors.secondarySystemGroupedBackground,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    String title,
    bool value,
    IconData icon,
    VoidCallback onChanged,
  ) {
    return CupertinoListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      trailing: CupertinoSwitch(value: value, onChanged: (_) => onChanged()),
    );
  }

  Widget _buildNavigationTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return CupertinoListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const CupertinoListTileChevron(),
      onTap: onTap,
    );
  }

  Widget _buildInfoTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return CupertinoListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }

  void _showCurrencyPicker(BuildContext context, WidgetRef ref) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
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
                  const Text(
                    'Select Currency',
                    style: CupertinoStyles.navigationTitle,
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
                  ref
                      .read(settingsProvider.notifier)
                      .setCurrency(AppCurrencies.currencies[index].code);
                },
                children: AppCurrencies.currencies
                    .map(
                      (currency) => Text('${currency.symbol} ${currency.name}'),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrecisionPicker(BuildContext context, WidgetRef ref) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
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
                  const Text(
                    'Decimal Places',
                    style: CupertinoStyles.navigationTitle,
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
                  ref
                      .read(settingsProvider.notifier)
                      .setDecimalPrecision(index);
                },
                children: List.generate(6, (index) => Text('$index digits')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
