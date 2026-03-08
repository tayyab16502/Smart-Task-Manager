import 'package:flutter/material.dart';
import '../../../core/database/db_helper.dart';
import '../models/task_model.dart';
import '../../notification/services/notification_service.dart';

class AddTaskController extends ChangeNotifier {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  int priority = 5;
  String selectedCategory = 'Work';

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

  Future<bool> saveTask() async {
    if (!isValid) return false;

    final dateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    final task = TaskModel(
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      dateTime: dateTime,
      priority: priority,
      category: selectedCategory,
      isCompleted: false,
    );

    final savedTask = await DBHelper.instance.insertTask(task);
    await NotificationService.scheduleTaskNotifications(savedTask);

    return true;
  }

  void reset() {
    titleController.clear();
    descriptionController.clear();
    selectedDate = null;
    selectedTime = null;
    priority = 5;
    selectedCategory = 'Work';
    notifyListeners();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}