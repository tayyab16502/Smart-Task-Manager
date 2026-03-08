import 'package:flutter/material.dart';
import '../../../core/database/db_helper.dart';
import '../../task/models/task_model.dart';

class NotificationController extends ChangeNotifier {
  List<TaskModel> overdueTasks = [];
  List<TaskModel> upcomingTasks = [];
  bool isLoading = true;

  NotificationController();

  Future<void> loadNotifications() async {
    isLoading = true;
    notifyListeners();

    final allTasks = await DBHelper.instance.fetchAllTasks();
    final now = DateTime.now();

    overdueTasks = allTasks.where((t) => !t.isCompleted && t.dateTime.isBefore(now)).toList();

    upcomingTasks = allTasks.where((t) =>
    !t.isCompleted &&
        t.dateTime.isAfter(now) &&
        t.dateTime.difference(now).inHours <= 24
    ).toList();

    isLoading = false;
    notifyListeners();
  }

  int get totalNotifications => overdueTasks.length + upcomingTasks.length;
}