import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:jhyapp/constants/colors.dart';
import 'package:jhyapp/constants/textstyle.dart';
import 'package:jhyapp/services/drink_service.dart';
import 'package:sizer/sizer.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  static const _typeColors = <String, Color>{
    'beer': Color(0xFFE99A32),
    'wine': Color(0xFFC6534B),
    'spirit': Color(0xFF7388D7),
    'cocktail': Color(0xFF60B98B),
  };

  List<Map<String, dynamic>> _drinks = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final drinks = await DrinkService.getAllDrinksForStats();
      if (!mounted) return;
      setState(() {
        _drinks = drinks;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, style: subtitleStyle, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              TextButton(onPressed: _loadStats, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final typeCounts = _countTypes();
    final totalTypeCount = typeCounts.values.fold<int>(0, (a, b) => a + b);
    final months = _monthlyCounts();
    final flavours = _flavourCounts();
    final topRated = _topRatedDrinks();
    final totalSpent = _drinks.fold<double>(
      0,
      (total, drink) => total + (_number(drink['price']) ?? 0),
    );

    return ListView(
      padding: EdgeInsets.fromLTRB(5.5.w, 2.2.h, 5.5.w, 3.h),
      children: [
        Text(
          'Stats',
          style: headingStyle.copyWith(fontSize: 24.sp, letterSpacing: -0.5),
        ),
        SizedBox(height: 0.3.h),
        Text('All time', style: subtitleStyle.copyWith(fontSize: 13.sp)),
        SizedBox(height: 2.4.h),
        _metrics(totalSpent),
        SizedBox(height: 3.2.h),
        _SectionHeading('By type'),
        SizedBox(height: 1.4.h),
        _TypeBreakdown(
          counts: typeCounts,
          colors: _typeColors,
          total: totalTypeCount,
        ),
        SizedBox(height: 2.2.h),
        _SectionHeading('Drinks per month'),
        SizedBox(height: 1.4.h),
        _MonthlyChart(months: months),
        SizedBox(height: 2.4.h),
        _SectionHeading('Flavour profile'),
        SizedBox(height: 1.4.h),
        _FlavourProfile(flavours: flavours),
        SizedBox(height: 2.4.h),
        _SectionHeading('Top rated'),
        SizedBox(height: 1.4.h),
        if (topRated.isEmpty)
          _EmptySection(message: 'Your rated drinks will appear here.')
        else
          ...topRated.map((drink) => _TopRatedCard(drink: drink)),
      ],
    );
  }

  Widget _metrics(double totalSpent) {
    final averageRating = _drinks.isEmpty
        ? 0.0
        : _drinks.fold<double>(
                0,
                (total, drink) => total + (_number(drink['rating']) ?? 0),
              ) /
              _drinks.length;
    final metrics = [
      ('Total logged', '${_drinks.length}', ''),
      ('Avg rating', averageRating.toStringAsFixed(1), '/ 5'),
      ('Longest streak', '${_longestStreak()}', 'days'),
      ('Total spent', '\$${totalSpent.toStringAsFixed(0)}', ''),
    ];

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 3.w,
      mainAxisSpacing: 1.3.h,
      childAspectRatio: 1.85,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: metrics
          .map(
            (metric) => Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
              decoration: BoxDecoration(
                color: tileClr,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    metric.$1,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: subtitleStyle.copyWith(fontSize: 12.sp),
                  ),
                  SizedBox(height: 0.5.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Flexible(
                        child: Text(
                          metric.$2,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: titleStyle.copyWith(
                            fontSize: 19.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (metric.$3.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Text(
                          metric.$3,
                          style: subtitleStyle.copyWith(fontSize: 11.sp),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Map<String, int> _countTypes() {
    final counts = <String, int>{
      'beer': 0,
      'wine': 0,
      'spirit': 0,
      'cocktail': 0,
    };
    for (final drink in _drinks) {
      final type = drink['type']?.toString().toLowerCase() ?? 'other';
      counts.update(type, (count) => count + 1, ifAbsent: () => 1);
    }
    return counts;
  }

  List<_MonthCount> _monthlyCounts() {
    final now = DateTime.now();
    final months = List.generate(
      6,
      (index) => DateTime(now.year, now.month - 5 + index),
    );
    final counts = {for (final month in months) _monthKey(month): 0};
    for (final drink in _drinks) {
      final date = DateTime.tryParse(drink['date']?.toString() ?? '');
      if (date == null) continue;
      final key = _monthKey(date);
      if (counts.containsKey(key)) counts.update(key, (count) => count + 1);
    }
    return months
        .map((month) => _MonthCount(month, counts[_monthKey(month)] ?? 0))
        .toList();
  }

  Map<String, int> _flavourCounts() {
    final counts = <String, int>{};
    for (final drink in _drinks) {
      final values = drink['flavour_notes'];
      if (values is! Iterable) continue;
      for (final value in values) {
        final flavour = value.toString().trim();
        if (flavour.isNotEmpty) {
          counts.update(flavour, (count) => count + 1, ifAbsent: () => 1);
        }
      }
    }
    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(entries.take(5));
  }

  List<Map<String, dynamic>> _topRatedDrinks() {
    final rated =
        _drinks.where((drink) => _number(drink['rating']) != null).toList()
          ..sort(
            (a, b) => (_number(b['rating']) ?? 0).compareTo(
              _number(a['rating']) ?? 0,
            ),
          );
    return rated.take(3).toList();
  }

  int _longestStreak() {
    final days =
        _drinks
            .map((drink) => DateTime.tryParse(drink['date']?.toString() ?? ''))
            .whereType<DateTime>()
            .map((date) => DateTime(date.year, date.month, date.day))
            .toSet()
            .toList()
          ..sort();
    if (days.isEmpty) return 0;

    var longest = 1;
    var current = 1;
    for (var index = 1; index < days.length; index++) {
      if (days[index].difference(days[index - 1]).inDays == 1) {
        current++;
        longest = math.max(longest, current);
      } else {
        current = 1;
      }
    }
    return longest;
  }

  static double? _number(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }

  static String _monthKey(DateTime date) => '${date.year}-${date.month}';
}

class _SectionHeading extends StatelessWidget {
  final String text;

  const _SectionHeading(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: titleStyle.copyWith(fontSize: 16.sp, fontWeight: FontWeight.w700),
  );
}

class _TypeBreakdown extends StatelessWidget {
  final Map<String, int> counts;
  final Map<String, Color> colors;
  final int total;

  const _TypeBreakdown({
    required this.counts,
    required this.colors,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final types = counts.entries.toList();
    return Container(
      height: 15.h,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.3.h),
      decoration: BoxDecoration(
        color: tileClr,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 25.w,
            child: CustomPaint(
              painter: _DonutPainter(
                counts: counts,
                colors: colors,
                total: total,
              ),
              child: Center(
                child: Text(
                  '$total',
                  style: titleStyle.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: types.map((entry) {
                final percentage = total == 0
                    ? 0
                    : (entry.value / total * 100).round();
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 0.25.h),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: colors[entry.key] ?? Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _label(entry.key),
                          style: subtitleStyle.copyWith(
                            color: const Color(0xFFE7EAEE),
                            fontSize: 11.5.sp,
                          ),
                        ),
                      ),
                      Text(
                        '$percentage%',
                        style: subtitleStyle.copyWith(fontSize: 11.5.sp),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  static String _label(String type) =>
      type.isEmpty ? type : '${type[0].toUpperCase()}${type.substring(1)}';
}

class _DonutPainter extends CustomPainter {
  final Map<String, int> counts;
  final Map<String, Color> colors;
  final int total;

  const _DonutPainter({
    required this.counts,
    required this.colors,
    required this.total,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final strokeWidth = math.min(size.width, size.height) * 0.14;
    final radius = math.min(size.width, size.height) / 2 - strokeWidth / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final backgroundPaint = Paint()
      ..color = const Color(0xFF35383D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, backgroundPaint);
    if (total == 0) return;

    var startAngle = -math.pi / 2;
    for (final entry in counts.entries) {
      if (entry.value == 0) continue;
      final sweep = entry.value / total * math.pi * 2;
      final paint = Paint()
        ..color = colors[entry.key] ?? Colors.grey
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(rect, startAngle, sweep, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      oldDelegate.counts != counts || oldDelegate.total != total;
}

class _MonthCount {
  final DateTime month;
  final int count;

  const _MonthCount(this.month, this.count);
}

class _MonthlyChart extends StatelessWidget {
  final List<_MonthCount> months;

  const _MonthlyChart({required this.months});

  @override
  Widget build(BuildContext context) {
    final maxCount = months.fold<int>(
      0,
      (maximum, month) => math.max(maximum, month.count),
    );
    return Container(
      height: 17.h,
      padding: EdgeInsets.fromLTRB(3.w, 2.h, 3.w, 1.3.h),
      decoration: BoxDecoration(
        color: tileClr,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: months.map((month) {
          final fraction = maxCount == 0 ? 0.0 : month.count / maxCount;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 1.w),
              child: Column(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor: fraction == 0 ? 0.035 : fraction,
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 3),
                          decoration: BoxDecoration(
                            color: amberClr,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 0.8.h),
                  Text(
                    _monthLabel(month.month.month),
                    style: subtitleStyle.copyWith(fontSize: 9.5.sp),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  static String _monthLabel(int month) => const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][month - 1];
}

class _FlavourProfile extends StatelessWidget {
  final Map<String, int> flavours;

  const _FlavourProfile({required this.flavours});

  @override
  Widget build(BuildContext context) {
    if (flavours.isEmpty) {
      return const _EmptySection(
        message: 'Add flavour notes to see your profile.',
      );
    }
    final maxCount = flavours.values.fold<int>(0, math.max);
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: tileClr,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: flavours.entries
            .map(
              (entry) => Padding(
                padding: EdgeInsets.symmetric(vertical: 0.7.h),
                child: Row(
                  children: [
                    SizedBox(
                      width: 23.w,
                      child: Text(
                        entry.key,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: subtitleStyle.copyWith(
                          color: const Color(0xFFE7EAEE),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: entry.value / maxCount,
                          minHeight: 8,
                          backgroundColor: const Color(0xFF35383D),
                          color: amberClr,
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Text('${entry.value}', style: subtitleStyle),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _TopRatedCard extends StatelessWidget {
  final Map<String, dynamic> drink;

  const _TopRatedCard({required this.drink});

  @override
  Widget build(BuildContext context) {
    final name = drink['name']?.toString().trim() ?? '';
    final brand = drink['brand']?.toString().trim() ?? '';
    final rating = drink['rating']?.toString() ?? '';
    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: tileClr,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.star_rounded, color: Color(0xFFE7C35A), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? 'Unnamed drink' : name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: titleStyle.copyWith(fontWeight: FontWeight.w600),
                ),
                if (brand.isNotEmpty) Text(brand, style: subtitleStyle),
              ],
            ),
          ),
          Text(
            '$rating / 5',
            style: titleStyle.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _EmptySection extends StatelessWidget {
  final String message;

  const _EmptySection({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: tileClr,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(message, style: subtitleStyle),
    );
  }
}
