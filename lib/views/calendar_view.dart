import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  DateTime _focusedDay = DateTime(2026, 3, 1);
  DateTime? _selectedDay;

  final Map<DateTime, List<String>> _entries = {
    DateTime(2026, 3, 1): ['Octoberfest (2026)'],
    DateTime(2026, 3, 4): ['Premium Pils'],
    DateTime(2026, 3, 6): ['Stout Night'],
    DateTime(2026, 3, 8): ['Cider House'],
    DateTime(2026, 3, 12): ['Octoberfest (2026)'],
    DateTime(2026, 3, 13): ['Hazy IPA'],
    DateTime(2026, 3, 19): ['Premium Pils'],
    DateTime(2026, 3, 20): ['Golden Ale'],
    DateTime(2026, 3, 25): ['Octoberfest (2026)'],
    DateTime(2026, 3, 27): ['Best Bitter'],
  };

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime(2026, 3, 12);
  }

  List<String> _entriesForDay(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    return _entries[normalized] ?? const [];
  }

  DateTime _normalized(DateTime day) => DateTime(day.year, day.month, day.day);

  @override
  Widget build(BuildContext context) {
    final selectedDate = _selectedDay ?? _focusedDay;
    final dateLabel = DateFormat('MMMM d, yyyy').format(selectedDate);
    final items = _entriesForDay(selectedDate);

    return Scaffold(
      backgroundColor: const Color(0xFF171A1D),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 18, right: 18, top: 12, bottom: 10),
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
                      onPressed: () {
                        setState(() {
                          _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
                        });
                      },
                      icon: const Icon(
                        Icons.chevron_left,
                        color: Color(0xFFE7EAEE),
                        size: 28,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      DateFormat('MMMM yyyy').format(_focusedDay),
                      style: const TextStyle(
                        color: Color(0xFFF3F5F7),
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        setState(() {
                          _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
                        });
                      },
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
                  defaultTextStyle: const TextStyle(
                    color: Color(0xFFE7EAEE),
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                  weekendTextStyle: const TextStyle(
                    color: Color(0xFFE7EAEE),
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                  selectedTextStyle: const TextStyle(
                    color: Color(0xFFF3F5F7),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                  todayTextStyle: const TextStyle(
                    color: Color(0xFFF3F5F7),
                    fontSize: 17,
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
                  dowTextFormatter: (date, locale) => DateFormat.E(locale).format(date).substring(0, 1),
                  weekdayStyle: TextStyle(
                    color: Color(0xFF9AA0A8),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  weekendStyle: TextStyle(
                    color: Color(0xFF9AA0A8),
                    fontSize: 13,
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
                style: const TextStyle(
                  color: Color(0xFFF3F5F7),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              if (items.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F2227),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF4D535B),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
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
                        child: const Center(
                          child: Text(
                            'BE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
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
                              items.first,
                              style: const TextStyle(
                                color: Color(0xFFF3F5F7),
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Sierra Nevada Brewing Co.',
                              style: TextStyle(
                                color: Color(0xFF9AA0A8),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              else
                const SizedBox.shrink(),
            ],
          ),
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
    final borderColor = isSelected ? const Color(0xFFF3F5F7) : Colors.transparent;
    final textColor = isSelected || isToday ? const Color(0xFFF3F5F7) : const Color(0xFFE7EAEE);

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(
          color: borderColor,
          width: isSelected ? 1.8 : 0,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 8,
            child: Text(
              '$day',
              style: TextStyle(
                color: textColor,
                fontSize: 17,
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
