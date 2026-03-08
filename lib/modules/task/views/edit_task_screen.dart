import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/theme.dart';
import '../../../core/controllers/theme_controller.dart';
import '../controllers/edit_task_controller.dart';
import '../models/task_model.dart';

class EditTaskScreen extends StatefulWidget {
  final TaskModel task;
  const EditTaskScreen({super.key, required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {

  @override
  void initState() {
    super.initState();
    // Screen khulte hi task data load kar rahay hain provider k andar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EditTaskController>().initTask(widget.task);
    });
  }

  // Dispose controller ki ab zaroorat nahi kyun k Provider manage karega

  Future<void> _selectDate(bool isDark, EditTaskController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
          data: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
          child: child!
      ),
    );
    if (picked != null && mounted) {
      context.read<EditTaskController>().updateDate(picked);
    }
  }

  Future<void> _selectTime(bool isDark, EditTaskController controller) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: controller.selectedTime ?? TimeOfDay.now(),
      builder: (context, child) => Theme(
          data: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
          child: child!
      ),
    );
    if (picked != null && mounted) {
      context.read<EditTaskController>().updateTime(picked);
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
    // Controller aur Theme seedha build se milay ga
    final controller = context.watch<EditTaskController>();
    final theme = Theme.of(context);
    final isDark = context.watch<ThemeController>().isDarkMode;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Edit Task', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Task Name', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
            const SizedBox(height: 8),
            // TextField ko clean kar diya
            TextField(
              controller: controller.titleController,
              style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface),
              decoration: const InputDecoration(hintText: 'e.g. Complete UI Design...'),
            ),
            const SizedBox(height: 24),
            Text('Description', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
            const SizedBox(height: 8),
            // TextField ko clean kar diya
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
                        onTap: () => _selectDate(isDark, controller),
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
                        onTap: () => _selectTime(isDark, controller),
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
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: controller.isValid ? () async {
                  final success = await controller.saveUpdatedTask();
                  if (success && context.mounted) Navigator.pop(context, true);
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.teal,
                  disabledBackgroundColor: theme.dividerColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(
                  'Update Task',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: controller.isValid ? theme.scaffoldBackgroundColor : theme.hintColor,
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