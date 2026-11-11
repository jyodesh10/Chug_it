import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jhyapp/app/app_routes.dart';
import 'package:intl/intl.dart';
import 'package:jhyapp/constants/textstyle.dart';
import 'package:jhyapp/services/drink_service.dart';
import 'package:sizer/sizer.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  DateTime _focusedDay = DateUtils.dateOnly(DateTime.now());
  DateTime? _selectedDay;
  Map<DateTime, List<Map<String, dynamic>>> _entries = {};
  bool _isLoading = true;
  String? _loadError;
  int _loadRequest = 0;

  @override
  void initState() {
    super.initState();
    _selectedDay = _normalized(DateTime.now());
    _loadMonth(_focusedDay);
  }

  Future<void> _loadMonth(DateTime month) async {
    final request = ++_loadRequest;
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final drinks = await DrinkService.getDrinksForMonth(month);
      if (!mounted || request != _loadRequest) return;

      final entries = <DateTime, List<Map<String, dynamic>>>{};
      for (final drink in drinks) {
        final date = DateTime.tryParse(drink['date']?.toString() ?? '');
        if (date == null) continue;
        entries.putIfAbsent(_normalized(date), () => []).add(drink);
      }
      setState(() {
        _entries = entries;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted || request != _loadRequest) return;
      setState(() {
        _loadError = error.toString().replaceFirst('Exception: ', '');
        _entries = {};
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _entriesForDay(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    return _entries[normalized] ?? const <Map<String, dynamic>>[];
  }

  DateTime _normalized(DateTime day) => DateTime(day.year, day.month, day.day);

  void _changeMonth(int offset) {
    final month = DateTime(_focusedDay.year, _focusedDay.month + offset);
    setState(() => _focusedDay = month);
    _loadMonth(month);
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = _selectedDay ?? _focusedDay;
    final dateLabel = DateFormat('MMMM d, yyyy').format(selectedDate);
    final items = _entriesForDay(selectedDate);

    return Scaffold(
      backgroundColor: const Color(0xFF171A1D),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 18,
            right: 18,
            top: 12,
            bottom: 10,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 46,
                child: Row(
                  children: [
                    const SizedBox(width: 4),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _changeMonth(-1),
                      icon: const Icon(
                        Icons.chevron_left,
                        color: Color(0xFFE7EAEE),
                        size: 28,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      DateFormat('MMMM yyyy').format(_focusedDay),
                      style: headingStyle.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _changeMonth(1),
                      icon: const Icon(
                        Icons.chevron_right,
                        color: Color(0xFFE7EAEE),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              TableCalendar<String>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2035, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = _normalized(selectedDay);
                    _focusedDay = focusedDay;
                  });
                },
                onPageChanged: (focusedDay) {
                  setState(() => _focusedDay = focusedDay);
                  _loadMonth(focusedDay);
                },
                startingDayOfWeek: StartingDayOfWeek.sunday,
                daysOfWeekHeight: 26,
                rowHeight: 62,
                calendarFormat: CalendarFormat.month,
                headerVisible: false,
                daysOfWeekVisible: true,
                pageAnimationEnabled: false,
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  cellPadding: EdgeInsets.zero,
                  defaultTextStyle: titleStyle.copyWith(
                    color: const Color(0xFFE7EAEE),
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  weekendTextStyle: titleStyle.copyWith(
                    color: const Color(0xFFE7EAEE),
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  selectedTextStyle: titleStyle.copyWith(
                    color: const Color(0xFFF3F5F7),
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  todayTextStyle: titleStyle.copyWith(
                    color: const Color(0xFFF3F5F7),
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(
                      color: const Color(0xFFF3F5F7),
                      width: 1.8,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  todayDecoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  defaultDecoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  weekendDecoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  cellMargin: const EdgeInsets.all(4),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  dowTextFormatter: (date, locale) =>
                      DateFormat.E(locale).format(date).substring(0, 1),
                  weekdayStyle: subtitleStyle.copyWith(
                    color: const Color(0xFF9AA0A8),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  weekendStyle: subtitleStyle.copyWith(
                    color: const Color(0xFF9AA0A8),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    final hasEvent = _entriesForDay(day).isNotEmpty;
                    return _CalendarDayCell(
                      day: day.day,
                      hasEvent: hasEvent,
                      isSelected: isSameDay(_selectedDay, day),
                      isToday: isSameDay(DateTime.now(), day),
                    );
                  },
                  selectedBuilder: (context, day, focusedDay) {
                    final hasEvent = _entriesForDay(day).isNotEmpty;
                    return _CalendarDayCell(
                      day: day.day,
                      hasEvent: hasEvent,
                      isSelected: true,
                      isToday: false,
                    );
                  },
                  todayBuilder: (context, day, focusedDay) {
                    final hasEvent = _entriesForDay(day).isNotEmpty;
                    return _CalendarDayCell(
                      day: day.day,
                      hasEvent: hasEvent,
                      isSelected: isSameDay(_selectedDay, day),
                      isToday: true,
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
              Text(
                dateLabel,
                style: subheadingStyle.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_loadError != null)
                _CalendarMessage(
                  message: _loadError!,
                  actionLabel: 'Retry',
                  onPressed: () => _loadMonth(_focusedDay),
                )
              else if (items.isEmpty)
                const _CalendarMessage(
                  message: 'No drinks logged on this date.',
                )
              else
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: items.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) => _DrinkCalendarCard(
                      drink: items[index],
                      onTap: () => context.push(
                        AppRoutes.drinkDetail,
                        extra: items[index],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrinkCalendarCard extends StatelessWidget {
  final Map<String, dynamic> drink;
  final VoidCallback onTap;

  const _DrinkCalendarCard({required this.drink, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = drink['name']?.toString().trim();
    final brand = drink['brand']?.toString().trim();
    final category = drink['category']?.toString().trim();
    final rating = drink['rating'];
    final details = [
      if (category != null && category.isNotEmpty) category,
      if (drink['abv'] != null) '${drink['abv']}% ABV',
      if (drink['volume'] != null) drink['volume'].toString(),
      if (drink['quantity'] != null) 'Qty ${drink['quantity']}',
    ].join(' · ');

    return Material(
      color: const Color(0xFF1F2227),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF4D535B), width: 1.2),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  drink['photo_url']?.toString() ?? '',
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF7C2D16),
                          Color(0xFFD97706),
                          Color(0xFFF59E0B),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        (drink['type']?.toString().characters.firstOrNull ??
                                'D')
                            .toUpperCase(),
                        style: titleStyle.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name?.isNotEmpty == true ? name! : 'Unnamed drink',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: titleStyle.copyWith(fontWeight: FontWeight.w700),
                    ),
                    if (brand?.isNotEmpty == true) ...[
                      const SizedBox(height: 4),
                      Text(
                        brand!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: subtitleStyle.copyWith(
                          color: const Color(0xFF9AA0A8),
                        ),
                      ),
                    ],
                    if (details.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        details,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: subtitleStyle,
                      ),
                    ],
                  ],
                ),
              ),
              if (rating is num) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.star_rounded,
                  color: Color(0xFFE7C35A),
                  size: 18,
                ),
                Text(
                  rating.toString(),
                  style: subtitleStyle.copyWith(color: Colors.white),
                ),
              ],
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF9AA0A8),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CalendarMessage extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onPressed;

  const _CalendarMessage({
    required this.message,
    this.actionLabel,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Center(
        child: Column(
          children: [
            Text(message, style: subtitleStyle, textAlign: TextAlign.center),
            if (actionLabel != null && onPressed != null)
              TextButton(onPressed: onPressed, child: Text(actionLabel!)),
          ],
        ),
      ),
    );
  }
}

class _CalendarDayCell extends StatelessWidget {
  final int day;
  final bool hasEvent;
  final bool isSelected;
  final bool isToday;

  const _CalendarDayCell({
    required this.day,
    required this.hasEvent,
    required this.isSelected,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected
        ? const Color(0xFFF3F5F7)
        : Colors.transparent;
    final textColor = isSelected || isToday
        ? const Color(0xFFF3F5F7)
        : const Color(0xFFE7EAEE);

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: borderColor, width: isSelected ? 1.8 : 0),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 8,
            child: Text(
              '$day',
              style: titleStyle.copyWith(
                color: textColor,
                fontSize: 15.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          if (hasEvent)
            Positioned(
              bottom: 10,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFFDE9400),
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
