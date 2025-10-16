import 'dart:math' as math;
import 'package:compounding_calculator/utils/constants.dart';

class CalculationModel {
  final String id;
  final double principal;
  final double rate;
  final double time;
  final TimeUnit timeUnit;
  final CompoundingFrequency frequency;
  final CalculationType calculationType;
  final double additionalMonthlyContribution;
  final double additionalYearlyContribution;
  final double targetAmount;
  final DateTime createdAt;
  final String title;

  const CalculationModel({
    required this.id,
    required this.principal,
    required this.rate,
    required this.time,
    required this.timeUnit,
    required this.frequency,
    required this.calculationType,
    this.additionalMonthlyContribution = 0.0,
    this.additionalYearlyContribution = 0.0,
    this.targetAmount = 0.0,
    required this.createdAt,
    this.title = '',
  });

  CalculationResult calculateResult() {
    final timeInYears = timeUnit == TimeUnit.years ? time : time / 12;

    switch (calculationType) {
      case CalculationType.simple:
        return _calculateSimpleInterest(timeInYears);

      case CalculationType.compound:
        return _calculateCompoundInterest(timeInYears);

      case CalculationType.continuous:
        return _calculateContinuousCompounding(timeInYears);
    }
  }

  CalculationResult _calculateSimpleInterest(double timeInYears) {
    final interest = principal * (rate / 100) * timeInYears;
    final finalAmount = principal + interest;

    return CalculationResult(
      principal: principal,
      rate: rate,
      time: timeInYears,
      finalAmount: finalAmount,
      totalInterest: interest,
      calculationType: calculationType,
      frequency: frequency,
      yearlyBreakdown: _generateSimpleInterestBreakdown(timeInYears),
    );
  }

  CalculationResult _calculateCompoundInterest(double timeInYears) {
    final n = frequency.value.toDouble();
    final t = timeInYears;
    final r = rate / 100;

    // A = P(1 + r/n)^(nt)
    final finalAmount = principal * math.pow(1 + r / n, n * t);
    final totalInterest = finalAmount - principal;

    return CalculationResult(
      principal: principal,
      rate: rate,
      time: timeInYears,
      finalAmount: finalAmount,
      totalInterest: totalInterest,
      calculationType: calculationType,
      frequency: frequency,
      yearlyBreakdown: _generateCompoundInterestBreakdown(timeInYears),
    );
  }

  CalculationResult _calculateContinuousCompounding(double timeInYears) {
    final r = rate / 100;
    final t = timeInYears;

    // A = Pe^(rt)
    final finalAmount = principal * math.exp(r * t);
    final totalInterest = finalAmount - principal;

    return CalculationResult(
      principal: principal,
      rate: rate,
      time: timeInYears,
      finalAmount: finalAmount,
      totalInterest: totalInterest,
      calculationType: calculationType,
      frequency: frequency,
      yearlyBreakdown: _generateContinuousCompoundingBreakdown(timeInYears),
    );
  }

  List<YearlyBreakdown> _generateSimpleInterestBreakdown(double timeInYears) {
    final breakdown = <YearlyBreakdown>[];
    final annualInterest = principal * (rate / 100);

    for (int year = 1; year <= timeInYears.ceil(); year++) {
      final interestEarned = year <= timeInYears
          ? annualInterest
          : annualInterest * (timeInYears - year + 1);
      final totalInterest =
          annualInterest * (year <= timeInYears ? year : timeInYears);
      final balance = principal + totalInterest;

      breakdown.add(
        YearlyBreakdown(
          year: year,
          startingBalance: year == 1
              ? principal
              : breakdown[year - 2].endingBalance,
          interestEarned: interestEarned,
          endingBalance: balance,
          totalInterest: totalInterest,
        ),
      );

      if (year >= timeInYears) break;
    }

    return breakdown;
  }

  List<YearlyBreakdown> _generateCompoundInterestBreakdown(double timeInYears) {
    final breakdown = <YearlyBreakdown>[];
    var currentBalance = principal;
    var totalInterestAccumulated = 0.0;

    for (int year = 1; year <= timeInYears.ceil(); year++) {
      final startingBalance = currentBalance;
      final yearlyTime = year <= timeInYears ? 1.0 : timeInYears - year + 1;

      final n = frequency.value.toDouble();
      final r = rate / 100;
      final endingBalance =
          startingBalance * math.pow(1 + r / n, n * yearlyTime);

      final interestEarned = endingBalance - startingBalance;
      totalInterestAccumulated += interestEarned;

      breakdown.add(
        YearlyBreakdown(
          year: year,
          startingBalance: startingBalance,
          interestEarned: interestEarned,
          endingBalance: endingBalance,
          totalInterest: totalInterestAccumulated,
        ),
      );

      currentBalance = endingBalance;
      if (year >= timeInYears) break;
    }

    return breakdown;
  }

  List<YearlyBreakdown> _generateContinuousCompoundingBreakdown(
    double timeInYears,
  ) {
    final breakdown = <YearlyBreakdown>[];
    var totalInterestAccumulated = 0.0;

    for (int year = 1; year <= timeInYears.ceil(); year++) {
      final t1 = year - 1;
      final t2 = year <= timeInYears ? year : timeInYears;

      final startingBalance = principal * math.exp((rate / 100) * t1);
      final endingBalance = principal * math.exp((rate / 100) * t2);
      final interestEarned = endingBalance - startingBalance;
      totalInterestAccumulated += interestEarned;

      breakdown.add(
        YearlyBreakdown(
          year: year,
          startingBalance: startingBalance,
          interestEarned: interestEarned,
          endingBalance: endingBalance,
          totalInterest: totalInterestAccumulated,
        ),
      );

      if (year >= timeInYears) break;
    }

    return breakdown;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'principal': principal,
      'rate': rate,
      'time': time,
      'timeUnit': timeUnit.name,
      'frequency': frequency.name,
      'calculationType': calculationType.name,
      'additionalMonthlyContribution': additionalMonthlyContribution,
      'additionalYearlyContribution': additionalYearlyContribution,
      'targetAmount': targetAmount,
      'createdAt': createdAt.toIso8601String(),
      'title': title,
    };
  }

  factory CalculationModel.fromJson(Map<String, dynamic> json) {
    return CalculationModel(
      id: json['id'],
      principal: json['principal'].toDouble(),
      rate: json['rate'].toDouble(),
      time: json['time'].toDouble(),
      timeUnit: TimeUnit.values.firstWhere((e) => e.name == json['timeUnit']),
      frequency: CompoundingFrequency.values.firstWhere(
        (e) => e.name == json['frequency'],
      ),
      calculationType: CalculationType.values.firstWhere(
        (e) => e.name == json['calculationType'],
      ),
      additionalMonthlyContribution:
          json['additionalMonthlyContribution']?.toDouble() ?? 0.0,
      additionalYearlyContribution:
          json['additionalYearlyContribution']?.toDouble() ?? 0.0,
      targetAmount: json['targetAmount']?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['createdAt']),
      title: json['title'] ?? '',
    );
  }

  CalculationModel copyWith({
    String? id,
    double? principal,
    double? rate,
    double? time,
    TimeUnit? timeUnit,
    CompoundingFrequency? frequency,
    CalculationType? calculationType,
    double? additionalMonthlyContribution,
    double? additionalYearlyContribution,
    double? targetAmount,
    DateTime? createdAt,
    String? title,
  }) {
    return CalculationModel(
      id: id ?? this.id,
      principal: principal ?? this.principal,
      rate: rate ?? this.rate,
      time: time ?? this.time,
      timeUnit: timeUnit ?? this.timeUnit,
      frequency: frequency ?? this.frequency,
      calculationType: calculationType ?? this.calculationType,
      additionalMonthlyContribution:
          additionalMonthlyContribution ?? this.additionalMonthlyContribution,
      additionalYearlyContribution:
          additionalYearlyContribution ?? this.additionalYearlyContribution,
      targetAmount: targetAmount ?? this.targetAmount,
      createdAt: createdAt ?? this.createdAt,
      title: title ?? this.title,
    );
  }
}

class CalculationResult {
  final double principal;
  final double rate;
  final double time;
  final double finalAmount;
  final double totalInterest;
  final CalculationType calculationType;
  final CompoundingFrequency frequency;
  final List<YearlyBreakdown> yearlyBreakdown;

  const CalculationResult({
    required this.principal,
    required this.rate,
    required this.time,
    required this.finalAmount,
    required this.totalInterest,
    required this.calculationType,
    required this.frequency,
    required this.yearlyBreakdown,
  });

  String get formulaUsed {
    switch (calculationType) {
      case CalculationType.simple:
        return 'A = P + P × r × t\nA = P(1 + rt)';
      case CalculationType.compound:
        return 'A = P(1 + r/n)^(nt)';
      case CalculationType.continuous:
        return 'A = Pe^(rt)';
    }
  }
}

class YearlyBreakdown {
  final int year;
  final double startingBalance;
  final double interestEarned;
  final double endingBalance;
  final double totalInterest;

  const YearlyBreakdown({
    required this.year,
    required this.startingBalance,
    required this.interestEarned,
    required this.endingBalance,
    required this.totalInterest,
  });
}
