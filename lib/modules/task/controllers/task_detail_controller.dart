import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import '../../../core/database/db_helper.dart';
import '../models/task_model.dart';

class TaskDetailController extends ChangeNotifier {
  TaskModel? currentTask;

  void init(TaskModel task) {
    currentTask = task;
    notifyListeners();
  }

  void updateTaskState(TaskModel updatedTask) {
    currentTask = updatedTask;
    notifyListeners();
  }

  Future<void> markAsComplete() async {
    if (currentTask == null) return;

    final updatedTask = currentTask!.copyWith(isCompleted: true);
    await DBHelper.instance.updateTask(updatedTask);
    currentTask = updatedTask;

    if (currentTask!.id != null) {
      await AwesomeNotifications().cancel(currentTask!.id!);
      await AwesomeNotifications().cancel(currentTask!.id! * 10 + 1);
      await AwesomeNotifications().cancel(currentTask!.id! * 10 + 2);
      await AwesomeNotifications().cancel(currentTask!.id! * 10 + 3);
    }

    notifyListeners();
  }

  Future<void> deleteTask() async {
    if (currentTask?.id != null) {
      await DBHelper.instance.deleteTask(currentTask!.id!);

      await AwesomeNotifications().cancel(currentTask!.id!);
      await AwesomeNotifications().cancel(currentTask!.id! * 10 + 1);
      await AwesomeNotifications().cancel(currentTask!.id! * 10 + 2);
      await AwesomeNotifications().cancel(currentTask!.id! * 10 + 3);
    }
  }
}