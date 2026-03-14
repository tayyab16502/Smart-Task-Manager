import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/theme.dart';
import '../../../core/controllers/theme_controller.dart';
import '../models/task_model.dart';
import '../controllers/task_detail_controller.dart';
import 'edit_task_screen.dart';

class TaskDetailScreen extends StatefulWidget {
  final TaskModel task;
  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskDetailController>().init(widget.task);
    });
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
    final controller = context.watch<TaskDetailController>();
    final theme = Theme.of(context);

    final task = controller.currentTask ?? widget.task;

    final color = _getCategoryColor(task.category);
    final isOverdue = !task.isCompleted && task.dateTime.isBefore(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context, true),
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.pencil, color: AppTheme.amber),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditTaskScreen(task: task)),
              );
              if (result == true) {
                Navigator.pop(context, true);
              }
            },
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.trash, color: Colors.redAccent),
            onPressed: () async {
              await controller.deleteTask();
              if (context.mounted) Navigator.pop(context, true);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withOpacity(0.5)),
                  ),
                  child: Text(
                    task.category,
                    style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Text(
                    'Priority: ${task.priority}',
                    style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.8), fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              task.title,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                height: 1.2,
                color: task.isCompleted ? theme.hintColor : theme.colorScheme.onSurface,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isOverdue ? Colors.redAccent.withOpacity(0.05) : theme.colorScheme.onSurface.withOpacity(0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isOverdue ? Colors.redAccent.withOpacity(0.3) : theme.dividerColor),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isOverdue ? Colors.redAccent.withOpacity(0.1) : theme.colorScheme.onSurface.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isOverdue ? CupertinoIcons.exclamationmark_triangle_fill : CupertinoIcons.clock,
                      color: isOverdue ? Colors.redAccent : theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isOverdue ? 'Overdue Deadline' : 'Scheduled Deadline',
                        style: TextStyle(
                          fontSize: 12,
                          color: isOverdue ? Colors.redAccent : theme.hintColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('EEEE, MMM dd • hh:mm a').format(task.dateTime),
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text('Task Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withOpacity(0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Text(
                task.description.isEmpty ? 'No description provided.' : task.description,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: task.description.isEmpty ? theme.hintColor : theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
            ),

            if (task.subTasks.isNotEmpty) ...[
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Sub-tasks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.teal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${task.subTasks.where((s) => s.isCompleted).length} / ${task.subTasks.length}',
                      style: const TextStyle(fontSize: 14, color: AppTheme.teal, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Column(
                  children: task.subTasks.asMap().entries.map((entry) {
                    final int index = entry.key;
                    final subTask = entry.value;
                    return CheckboxListTile(
                      title: Text(
                        subTask.title,
                        style: TextStyle(
                          fontSize: 15,
                          color: subTask.isCompleted ? theme.hintColor : theme.colorScheme.onSurface,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      // NAYA SECTION: SUB-TASK DEADLINE
                      subtitle: subTask.deadline != null
                          ? Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Row(
                          children: [
                            Icon(
                              CupertinoIcons.clock,
                              size: 12,
                              color: subTask.isCompleted ? theme.hintColor : AppTheme.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('MMM dd, hh:mm a').format(subTask.deadline!),
                              style: TextStyle(
                                fontSize: 12,
                                color: subTask.isCompleted ? theme.hintColor : AppTheme.amber,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                          : null,
                      // ---------------------------------
                      value: subTask.isCompleted,
                      activeColor: AppTheme.teal,
                      checkColor: theme.scaffoldBackgroundColor,
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      dense: true,
                      onChanged: (bool? value) {
                        if (value != null) {
                          controller.toggleSubTask(index, value);
                        }
                      },
                    );
                  }).toList(),
                ),
              ),
            ],

            const SizedBox(height: 48),
            if (!task.isCompleted)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await controller.markAsComplete();
                    if (context.mounted) Navigator.pop(context, true);
                  },
                  icon: Icon(CupertinoIcons.checkmark_alt, color: theme.scaffoldBackgroundColor),
                  label: Text('Mark as Completed', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.scaffoldBackgroundColor)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.teal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}