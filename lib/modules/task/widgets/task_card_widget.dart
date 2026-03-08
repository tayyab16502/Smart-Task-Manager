import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/theme.dart';
import '../models/task_model.dart';

class TaskCardWidget extends StatefulWidget {
  final TaskModel task;
  final VoidCallback onTap;
  final VoidCallback onComplete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCardWidget({
    super.key,
    required this.task,
    required this.onTap,
    required this.onComplete,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<TaskCardWidget> createState() => _TaskCardWidgetState();
}

class _TaskCardWidgetState extends State<TaskCardWidget> {
  Timer? _timer;
  late bool isOverdue;
  late Duration timeRemaining;

  @override
  void initState() {
    super.initState();
    _calculateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!widget.task.isCompleted && mounted) {
        _calculateTime();
      }
    });
  }

  void _calculateTime() {
    final now = DateTime.now();
    setState(() {
      isOverdue = widget.task.dateTime.isBefore(now);
      if (!isOverdue) {
        timeRemaining = widget.task.dateTime.difference(now);
      } else {
        timeRemaining = Duration.zero;
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String hours = twoDigits(d.inHours);
    String minutes = twoDigits(d.inMinutes.remainder(60));
    String seconds = twoDigits(d.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Work': return AppTheme.teal;
      case 'Study': return AppTheme.violet;
      case 'Personal': return AppTheme.amber;
      default: return AppTheme.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final theme = Theme.of(context);
    final bool showCountdown = !task.isCompleted && !isOverdue && timeRemaining.inHours < 24;
    final color = isOverdue && !task.isCompleted ? Colors.redAccent : _getCategoryColor(task.category);

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isOverdue && !task.isCompleted ? Colors.redAccent.withOpacity(0.05) : theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isOverdue && !task.isCompleted ? color.withOpacity(0.3) : theme.dividerColor),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  height: 12,
                  width: 12,
                  decoration: BoxDecoration(
                    color: task.isCompleted ? color.withOpacity(0.3) : color,
                    shape: BoxShape.circle,
                    boxShadow: task.isCompleted ? [] : [BoxShadow(color: color.withOpacity(0.5), blurRadius: 6)],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: task.isCompleted ? theme.hintColor : theme.colorScheme.onSurface,
                          decoration: TextDecoration.none, // Strike-through line hata di gayi hai
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            isOverdue && !task.isCompleted ? CupertinoIcons.exclamationmark_triangle_fill : CupertinoIcons.clock,
                            size: 12,
                            color: isOverdue && !task.isCompleted ? Colors.redAccent : theme.hintColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isOverdue && !task.isCompleted
                                ? 'Overdue: ${DateFormat('MMM d, hh:mm a').format(task.dateTime)}'
                                : DateFormat('MMM d, hh:mm a').format(task.dateTime),
                            style: TextStyle(
                              fontSize: 11,
                              color: isOverdue && !task.isCompleted ? Colors.redAccent : theme.hintColor,
                              fontWeight: isOverdue && !task.isCompleted ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'P${task.priority}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: task.isCompleted ? theme.hintColor : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    if (showCountdown) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _formatDuration(timeRemaining),
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.amber),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            if (!task.isCompleted) ...[
              const SizedBox(height: 12),
              Divider(color: theme.dividerColor, height: 1),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: widget.onDelete,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), shape: BoxShape.circle),
                      child: const Icon(CupertinoIcons.trash, size: 16, color: Colors.redAccent),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: widget.onEdit,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppTheme.amber.withOpacity(0.1), shape: BoxShape.circle),
                      child: const Icon(CupertinoIcons.pencil, size: 16, color: AppTheme.amber),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: widget.onComplete,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: AppTheme.teal.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        children: const [
                          Icon(CupertinoIcons.checkmark_alt, size: 16, color: AppTheme.teal),
                          SizedBox(width: 4),
                          Text('Complete', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.teal)),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            ] else ...[
              const SizedBox(height: 12),
              Divider(color: theme.dividerColor, height: 1),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: widget.onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.05), shape: BoxShape.circle),
                    child: Icon(CupertinoIcons.trash, size: 16, color: Colors.redAccent.withOpacity(0.5)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}