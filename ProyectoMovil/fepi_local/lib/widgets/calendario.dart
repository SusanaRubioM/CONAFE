import 'package:fepi_local/constansts/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class ActivityCalendar extends StatefulWidget {
  final Map<DateTime, List<Map<String, String>>> activities;

  const ActivityCalendar({Key? key, required this.activities}) : super(key: key);

  @override
  _ActivityCalendarState createState() => _ActivityCalendarState();
}

class _ActivityCalendarState extends State<ActivityCalendar> {
  late Map<DateTime, List<Map<String, String>>> _groupedActivities;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _groupedActivities = {};
    final now = DateTime.now();
    for (var entry in widget.activities.entries) {
      final key = DateTime(entry.key.year, entry.key.month, entry.key.day);
      if (key.isAfter(DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1)))) {
        _groupedActivities[key] = entry.value;
      }
    }
  }

  List<Map<String, String>> _getActivitiesForDay(DateTime day) {
    return _groupedActivities[DateTime(day.year, day.month, day.day)] ?? [];
  }

  void _showActivityPopup(List<Map<String, String>> activities) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Actividades'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: activities.map((activity) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  '${activity['Hora']}: ${activity['Actividad']}',
                  style: const TextStyle(fontSize: 16),
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario de Actividades'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              final activities = _getActivitiesForDay(selectedDay);
              if (activities.isNotEmpty) {
                _showActivityPopup(activities);
              }
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: _getActivitiesForDay,
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, date, _) {
                final hasEvents = _getActivitiesForDay(date).isNotEmpty;
                return Container(
                  margin: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: hasEvents ? AppColors.color3 : const Color.fromARGB(0, 255, 255, 255),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${date.day}',
                    style: TextStyle(
                      color: hasEvents ? AppColors.color1 : Colors.grey.shade700,
                      fontWeight: hasEvents ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
              selectedBuilder: (context, date, _) {
                return Container(
                  margin: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: AppColors.color2,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${date.day}',
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
