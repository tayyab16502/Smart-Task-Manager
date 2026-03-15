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

  // --- NAYA FUNCTION: SUB-TASKS HANDLE KARNE KE LIYE ---
  Future<void> toggleSubTask(int index, bool value) async {
    if (currentTask == null) return;

    // Purani list ki ek copy banate hain
    List<SubTask> updatedSubTasks = List.from(currentTask!.subTasks);

    // Specific sub-task ka status update karte hain
    updatedSubTasks[index] = updatedSubTasks[index].copyWith(isCompleted: value);

    // Check karte hain ke kya saare sub-tasks tick ho gaye hain?
    bool areAllSubTasksCompleted = updatedSubTasks.isNotEmpty &&
        updatedSubTasks.every((st) => st.isCompleted);

    // Naya task model banate hain updated list ke sath
    final updatedTask = currentTask!.copyWith(
      subTasks: updatedSubTasks,
      // Agar saare sub-tasks complete hain, to main task ko bhi complete kar do
      isCompleted: areAllSubTasksCompleted ? true : currentTask!.isCompleted,
    );

    // Database mein save karte hain
    await DBHelper.instance.updateTask(updatedTask);
    currentTask = updatedTask;

    // NAYA LOGIC: Agar sub-task complete hua hai to uski specific notification cancel karein
    if (value && currentTask!.id != null) {
      await AwesomeNotifications().cancel(currentTask!.id! * 1000 + index);
    }

    // Agar saare sub-tasks tick hone ki wajah se main task complete hua hai,
    // to uski aur uske sub-tasks ki notifications cancel kar dein
    if (areAllSubTasksCompleted && currentTask!.id != null) {
      await AwesomeNotifications().cancel(currentTask!.id!);
      await AwesomeNotifications().cancel(currentTask!.id! * 10 + 1);
      await AwesomeNotifications().cancel(currentTask!.id! * 10 + 2);
      await AwesomeNotifications().cancel(currentTask!.id! * 10 + 3);

      // Saare sub-tasks ki notifications bhi cancel kar dein ehtiyatan
      for (int i = 0; i < currentTask!.subTasks.length; i++) {
        await AwesomeNotifications().cancel(currentTask!.id! * 1000 + i);
      }
    }

    notifyListeners();
  }
  // -----------------------------------------------------

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

      // NAYA LOGIC: Main task complete hone par saare sub-tasks ki notifications bhi cancel karein
      for (int i = 0; i < currentTask!.subTasks.length; i++) {
        await AwesomeNotifications().cancel(currentTask!.id! * 1000 + i);
      }
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

      // NAYA LOGIC: Task delete hone par saare sub-tasks ki notifications bhi cancel karein
      for (int i = 0; i < currentTask!.subTasks.length; i++) {
        await AwesomeNotifications().cancel(currentTask!.id! * 1000 + i);
      }
    }
  }
}