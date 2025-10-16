import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:compounding_calculator/screens/calculator_screen.dart';
import 'package:compounding_calculator/screens/charts_screen.dart';
import 'package:compounding_calculator/screens/settings_screen.dart';
import 'package:compounding_calculator/screens/history_screen.dart';
import 'package:compounding_calculator/providers/settings_provider.dart';
import 'package:compounding_calculator/utils/constants.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: CompoundInterestApp()));
}

class CompoundInterestApp extends ConsumerWidget {
  const CompoundInterestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return CupertinoApp(
      title: 'Compound Interest Calculator',
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(
        primaryColor: AppColors.primary,
        brightness: settings.isDarkMode ? Brightness.dark : Brightness.light,
        scaffoldBackgroundColor: settings.isDarkMode
            ? CupertinoColors.black
            : CupertinoColors.systemBackground,
        textTheme: const CupertinoTextThemeData(
          primaryColor: CupertinoColors.label,
        ),
      ),
      home: const MainTabController(),
      routes: {
        '/calculator': (context) => const CalculatorScreen(),
        '/charts': (context) => const ChartsScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/history': (context) => const HistoryScreen(),
      },
    );
  }
}

class MainTabController extends StatelessWidget {
  const MainTabController({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
        border: const Border(
          top: BorderSide(color: CupertinoColors.separator, width: 0.5),
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.number),
            activeIcon: Icon(CupertinoIcons.textformat_123),
            label: 'Calculator',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chart_bar),
            activeIcon: Icon(CupertinoIcons.chart_bar_fill),
            label: 'Charts',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.clock),
            activeIcon: Icon(CupertinoIcons.clock_fill),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings),
            activeIcon: Icon(CupertinoIcons.settings_solid),
            label: 'Settings',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return const CalculatorScreen();
          case 1:
            return const ChartsScreen();
          case 2:
            return const HistoryScreen();
          case 3:
            return const SettingsScreen();
          default:
            return const CalculatorScreen();
        }
      },
    );
  }
}
