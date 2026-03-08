import 'package:flutter/material.dart';
import '../../../core/database/db_helper.dart';
import '../models/task_model.dart';
import '../../notification/services/notification_service.dart';

class EditTaskController extends ChangeNotifier {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  late int taskId;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  int priority = 5;
  String selectedCategory = 'Work';
  bool isCompleted = false;

  void initTask(TaskModel task) {
    taskId = task.id!;
    titleController.text = task.title;
    descriptionController.text = task.description;
    selectedDate = task.dateTime;
    selectedTime = TimeOfDay(hour: task.dateTime.hour, minute: task.dateTime.minute);
    priority = task.priority;
    selectedCategory = task.category;
    isCompleted = task.isCompleted;
  }

  bool get isValid => titleController.text.trim().isNotEmpty && selectedDate != null && selectedTime != null;

  void updateDate(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }

  void updateTime(TimeOfDay time) {
    selectedTime = time;
    notifyListeners();
  }

  void updatePriority(double value) {
    priority = value.toInt();
    notifyListeners();
  }

  void updateCategory(String category) {
    selectedCategory = category;
    notifyListeners();
  }

  Future<bool> saveUpdatedTask() async {
    if (!isValid) return false;

    final dateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    final updatedTask = TaskModel(
      id: taskId,
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      dateTime: dateTime,
      priority: priority,
      category: selectedCategory,
      isCompleted: isCompleted,
    );

    await DBHelper.instance.updateTask(updatedTask);
    await NotificationService.scheduleTaskNotifications(updatedTask);

    return true;
  }
}