import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/theme.dart';
import '../../../core/database/db_helper.dart';
import '../../task/models/task_model.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<TaskModel> _allTasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fetchTasks();
  }

  // Database se direct tasks fetch karna
  Future<void> _fetchTasks() async {
    final tasks = await DBHelper.instance.fetchAllTasks();
    setState(() {
      _allTasks = tasks;
      _isLoading = false;
    });
  }

  // Calendar ke dots ke liye: Check karna ke kis date par kitne tasks hain
  List<TaskModel> _getTasksForDay(DateTime day) {
    return _allTasks.where((task) {
      return task.dateTime.year == day.year &&
          task.dateTime.month == day.month &&
          task.dateTime.day == day.day;
    }).toList();
  }

  // Chart ke liye: Pichle 7 din ka data nikalna
  List<BarChartGroupData> _getWeeklyBarChartData() {
    List<BarChartGroupData> barGroups = [];
    final today = DateTime.now();

    for (int i = 0; i < 7; i++) {
      // 6 din pehle se shuru kar ke aaj tak
      final targetDate = today.subtract(Duration(days: 6 - i));

      // Us din ke completed tasks count karna
      int completedTasksCount = _allTasks.where((task) {
        return task.isCompleted &&
            task.dateTime.year == targetDate.year &&
            task.dateTime.month == targetDate.month &&
            task.dateTime.day == targetDate.day;
      }).length;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: completedTasksCount.toDouble(),
              color: AppTheme.teal,
              width: 16,
              borderRadius: BorderRadius.circular(4),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: 5, // Maximum scale (aap isay dynamic bhi kar sakte hain)
                color: AppTheme.teal.withOpacity(0.1),
              ),
            ),
          ],
        ),
      );
    }
    return barGroups;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tasksForSelectedDay = _getTasksForDay(_selectedDay ?? _focusedDay);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Analytics & Calendar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.teal))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- CALENDAR SECTION ---
            Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.dividerColor),
              ),
              padding: const EdgeInsets.all(8),
              child: TableCalendar<TaskModel>(
                firstDay: DateTime.utc(2020, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                eventLoader: _getTasksForDay,
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: AppTheme.teal.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: AppTheme.teal,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: AppTheme.amber,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- SELECTED DAY TASKS ---
            Text(
              'Tasks on ${DateFormat('MMM dd').format(_selectedDay ?? _focusedDay)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
            ),
            const SizedBox(height: 12),
            if (tasksForSelectedDay.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text('No tasks for this day', style: TextStyle(color: theme.hintColor)),
              )
            else
              ...tasksForSelectedDay.map((task) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Row(
                  children: [
                    Icon(
                      task.isCompleted ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.circle,
                      color: task.isCompleted ? AppTheme.teal : theme.hintColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 15,
                          color: task.isCompleted ? theme.hintColor : theme.colorScheme.onSurface,
                          decoration: TextDecoration.none, // FIX: Strike-through yahan se hata diya hai
                        ),
                      ),
                    ),
                  ],
                ),
              )),

            const SizedBox(height: 32),

            // --- WEEKLY ANALYTICS CHART ---
            Text(
              'Weekly Productivity (Last 7 Days)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
            ),
            const SizedBox(height: 16),
            Container(
              height: 250,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.dividerColor),
              ),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 5, // Graph ki maximum height (tasks limit)
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          // Bottom par din ke naam dikhana (e.g. Mon, Tue)
                          final date = DateTime.now().subtract(Duration(days: 6 - value.toInt()));
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              DateFormat('E').format(date),
                              style: TextStyle(color: theme.hintColor, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(color: theme.hintColor, fontSize: 10),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: theme.dividerColor,
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: _getWeeklyBarChartData(),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}