import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/theme.dart';
import '../../../core/controllers/theme_controller.dart';
import '../controllers/add_task_controller.dart';
import '../../../core/database/db_helper.dart';
import '../models/task_model.dart';

class SubTaskInput {
  final TextEditingController controller = TextEditingController();
  DateTime? deadline;
}

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final List<SubTaskInput> _subTaskInputs = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddTaskController>().reset();
    });
  }

  @override
  void dispose() {
    for (var input in _subTaskInputs) {
      input.controller.dispose();
    }
    super.dispose();
  }

  Future<void> _selectDate(bool isDark) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
          data: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
          child: child!
      ),
    );
    if (picked != null && mounted) {
      context.read<AddTaskController>().updateDate(picked);
    }
  }

  Future<void> _selectTime(bool isDark) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
          data: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
          child: child!
      ),
    );
    if (picked != null && mounted) {
      context.read<AddTaskController>().updateTime(picked);
    }
  }

  Future<void> _selectSubTaskDeadline(int index, bool isDark) async {
    final controller = context.read<AddTaskController>();
    DateTime? mainDeadline;

    if (controller.selectedDate != null && controller.selectedTime != null) {
      mainDeadline = DateTime(
        controller.selectedDate!.year,
        controller.selectedDate!.month,
        controller.selectedDate!.day,
        controller.selectedTime!.hour,
        controller.selectedTime!.minute,
      );
    }

    DateTime minAllowedDateTime = DateTime.now();
    for (int i = index - 1; i >= 0; i--) {
      if (_subTaskInputs[i].deadline != null) {
        if (_subTaskInputs[i].deadline!.isAfter(minAllowedDateTime)) {
          minAllowedDateTime = _subTaskInputs[i].deadline!;
        }
        break;
      }
    }

    DateTime maxAllowedDateTime = mainDeadline ?? DateTime(2100);
    for (int i = index + 1; i < _subTaskInputs.length; i++) {
      if (_subTaskInputs[i].deadline != null) {
        if (_subTaskInputs[i].deadline!.isBefore(maxAllowedDateTime)) {
          maxAllowedDateTime = _subTaskInputs[i].deadline!;
        }
        break;
      }
    }

    DateTime firstAllowedDate = DateTime(minAllowedDateTime.year, minAllowedDateTime.month, minAllowedDateTime.day);
    DateTime lastAllowedDate = DateTime(maxAllowedDateTime.year, maxAllowedDateTime.month, maxAllowedDateTime.day);

    if (lastAllowedDate.isBefore(firstAllowedDate)) {
      firstAllowedDate = lastAllowedDate;
    }

    DateTime initialD = DateTime.now();
    if (initialD.isAfter(lastAllowedDate)) {
      initialD = lastAllowedDate;
    } else if (initialD.isBefore(firstAllowedDate)) {
      initialD = firstAllowedDate;
    }

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialD,
      firstDate: firstAllowedDate,
      lastDate: lastAllowedDate,
      builder: (context, child) => Theme(
          data: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
          child: child!
      ),
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) => Theme(
            data: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
            child: child!
        ),
      );
      if (pickedTime != null && mounted) {
        final subTaskDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        if (subTaskDateTime.isBefore(minAllowedDateTime)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Sub-task cannot be scheduled before the previous sub-task (${DateFormat('MMM dd, hh:mm a').format(minAllowedDateTime)})!'
              ),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }

        if (subTaskDateTime.isAfter(maxAllowedDateTime)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Sub-task cannot be scheduled after the allowed limit (${DateFormat('MMM dd, hh:mm a').format(maxAllowedDateTime)})!'
              ),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }

        setState(() {
          _subTaskInputs[index].deadline = subTaskDateTime;
        });
      }
    }
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
    final controller = context.watch<AddTaskController>();
    final theme = Theme.of(context);
    final isDark = context.watch<ThemeController>().isDarkMode;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Create New Task', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Task Name', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
            const SizedBox(height: 8),
            TextField(
              controller: controller.titleController,
              style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface),
              decoration: const InputDecoration(hintText: 'e.g. Complete UI Design...'),
            ),
            const SizedBox(height: 24),
            Text('Description (Optional)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
            const SizedBox(height: 8),
            TextField(
              controller: controller.descriptionController,
              maxLines: 4,
              style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface),
              decoration: const InputDecoration(hintText: 'Add details about your task...'),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _selectDate(isDark),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: theme.inputDecorationTheme.fillColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: theme.dividerColor),
                          ),
                          child: Row(
                            children: [
                              const Icon(CupertinoIcons.calendar, color: AppTheme.teal, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  controller.selectedDate == null ? 'Select Date' : DateFormat('MMM dd, yyyy').format(controller.selectedDate!),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: controller.selectedDate == null ? theme.hintColor : theme.colorScheme.onSurface,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Time', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _selectTime(isDark),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: theme.inputDecorationTheme.fillColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: theme.dividerColor),
                          ),
                          child: Row(
                            children: [
                              const Icon(CupertinoIcons.clock, color: AppTheme.violet, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  controller.selectedTime == null ? 'Select Time' : controller.selectedTime!.format(context),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: controller.selectedTime == null ? theme.hintColor : theme.colorScheme.onSurface,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Priority (0 - 10)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: theme.inputDecorationTheme.fillColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: controller.priority.toDouble(),
                      min: 0,
                      max: 10,
                      divisions: 10,
                      activeColor: AppTheme.amber,
                      inactiveColor: theme.dividerColor,
                      onChanged: controller.updatePriority,
                    ),
                  ),
                  Container(
                    width: 40,
                    alignment: Alignment.center,
                    child: Text('${controller.priority}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.amber)),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Category', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
            const SizedBox(height: 12),
            Row(
              children: ['Work', 'Study', 'Personal'].map((category) {
                final isSelected = controller.selectedCategory == category;
                final color = _getCategoryColor(category);
                return Expanded(
                  child: GestureDetector(
                    onTap: () => controller.updateCategory(category),
                    child: Container(
                      margin: EdgeInsets.only(right: category != 'Personal' ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? color.withOpacity(0.2) : theme.inputDecorationTheme.fillColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isSelected ? color : theme.dividerColor),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 13,
                          color: isSelected ? color : theme.hintColor,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Sub-tasks (Optional)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _subTaskInputs.add(SubTaskInput());
                    });
                  },
                  icon: const Icon(CupertinoIcons.add, size: 16),
                  label: const Text('Add'),
                  style: TextButton.styleFrom(foregroundColor: AppTheme.teal),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ..._subTaskInputs.asMap().entries.map((entry) {
              int idx = entry.key;
              SubTaskInput input = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: const Icon(CupertinoIcons.circle, size: 16, color: Colors.grey),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: input.controller,
                            style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface),
                            decoration: InputDecoration(
                              hintText: 'Sub-task ${idx + 1}...',
                              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: theme.dividerColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: theme.dividerColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppTheme.teal),
                              ),
                            ),
                          ),
                          if (input.deadline != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Deadline: ${DateFormat('MMM dd, hh:mm a').format(input.deadline!)}',
                              style: const TextStyle(fontSize: 11, color: AppTheme.amber, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                          input.deadline == null ? CupertinoIcons.calendar_badge_plus : CupertinoIcons.calendar_today,
                          color: input.deadline == null ? theme.hintColor : AppTheme.teal,
                          size: 22
                      ),
                      onPressed: () {
                        if (controller.selectedDate == null || controller.selectedTime == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select Main Task Date & Time first!'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        } else {
                          _selectSubTaskDeadline(idx, isDark);
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(CupertinoIcons.delete, color: Colors.redAccent, size: 20),
                      onPressed: () {
                        setState(() {
                          input.controller.dispose();
                          _subTaskInputs.removeAt(idx);
                        });
                      },
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  if (!controller.isValid) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please set Task Name, Date, and Time!'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                    return;
                  }

                  bool missingSubTaskDeadline = false;
                  for (var input in _subTaskInputs) {
                    if (input.controller.text.trim().isNotEmpty && input.deadline == null) {
                      missingSubTaskDeadline = true;
                      break;
                    }
                  }

                  if (missingSubTaskDeadline) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please set a deadline for all added sub-tasks!'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                    return;
                  }

                  final String newTaskTitle = controller.titleController.text.trim();
                  final List<TaskModel> allTasks = await DBHelper.instance.fetchAllTasks();
                  TaskModel? duplicateTask;

                  for (var task in allTasks) {
                    if (task.title.toLowerCase() == newTaskTitle.toLowerCase()) {
                      duplicateTask = task;
                      break;
                    }
                  }

                  if (duplicateTask != null && context.mounted) {
                    final String formattedDeadline = DateFormat('MMM dd, yyyy - hh:mm a').format(duplicateTask.dateTime);
                    final bool? proceed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: theme.cardColor,
                        title: Text('Duplicate Task Found', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold)),
                        content: Text(
                          'A task named "$newTaskTitle" already exists in your list with a deadline of $formattedDeadline.\n\nAre you sure you want to create another task with the exact same name? We suggest changing the name to avoid confusion.',
                          style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.8)),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('No, Change Name', style: TextStyle(color: Colors.redAccent)),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Yes, Create Anyway', style: TextStyle(color: AppTheme.teal)),
                          ),
                        ],
                      ),
                    );

                    if (proceed != true) {
                      return;
                    }
                  }

                  List<Map<String, dynamic>> subTasksData = _subTaskInputs
                      .where((item) => item.controller.text.trim().isNotEmpty)
                      .map((item) => {
                    'title': item.controller.text.trim(),
                    'deadline': item.deadline,
                  })
                      .toList();

                  controller.setSubTasksData(subTasksData);

                  final success = await controller.saveTask();
                  if (success && context.mounted) Navigator.pop(context, true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.teal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(
                  'Create Task',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.scaffoldBackgroundColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}