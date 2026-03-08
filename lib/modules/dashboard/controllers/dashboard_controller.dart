import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import '../../../core/database/db_helper.dart';
import '../../task/models/task_model.dart';

class DashboardController extends ChangeNotifier {
  List<TaskModel> _allTasks = [];
  bool isLoading = true;

  String searchQuery = '';
  String selectedCategory = 'All';
  String sortBy = 'Time';
  bool showCompleted = false;

  // Constructor se fetchTasks() nikal diya gaya hai ta k "Double Fetching" ka masla na aye.
  // Ab yeh automatically DashboardScreen k initState se fetch hoga.
  DashboardController();

  // Dynamic Greeting Logic based on Time
  String get greeting {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good Morning,';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon,';
    } else if (hour >= 17 && hour < 21) {
      return 'Good Evening,';
    } else {
      return 'Good Night,';
    }
  }

  Future<void> fetchTasks() async {
    isLoading = true;
    notifyListeners(); // UI ko bataye k loading shuru ho gayi hai

    _allTasks = await DBHelper.instance.fetchAllTasks();

    isLoading = false;
    notifyListeners(); // UI ko bataye k data aa gaya hai, screen refresh karein
  }

  int get totalTasks => _allTasks.length;
  int get completedTasks => _allTasks.where((t) => t.isCompleted).length;
  int get pendingTasks => totalTasks - completedTasks;
  double get productivityPercentage => totalTasks == 0 ? 0 : completedTasks / totalTasks;

  void updateSearch(String query) {
    searchQuery = query;
    notifyListeners(); // Search likhtay hi UI foran filter hogi
  }

  void updateCategoryFilter(String category) {
    selectedCategory = category;
    notifyListeners();
  }

  void updateSort(String sort) {
    sortBy = sort;
    notifyListeners();
  }

  void toggleView(bool isCompletedView) {
    showCompleted = isCompletedView;
    notifyListeners();
  }

  Future<void> markTaskAsCompleted(TaskModel task) async {
    final updatedTask = task.copyWith(isCompleted: true);
    await DBHelper.instance.updateTask(updatedTask);

    // Task complete hone par uske saare alarms/reminders cancel kar dein
    if (task.id != null) {
      await AwesomeNotifications().cancel(task.id!);
      await AwesomeNotifications().cancel(task.id! * 10 + 1);
      await AwesomeNotifications().cancel(task.id! * 10 + 2);
      await AwesomeNotifications().cancel(task.id! * 10 + 3);
    }

    await fetchTasks(); // Yeh automatically notifyListeners() call kar dega
  }

  Future<void> deleteTask(int id) async {
    await DBHelper.instance.deleteTask(id);

    // Task delete hone par uske saare alarms/reminders delete kar dein
    await AwesomeNotifications().cancel(id);
    await AwesomeNotifications().cancel(id * 10 + 1);
    await AwesomeNotifications().cancel(id * 10 + 2);
    await AwesomeNotifications().cancel(id * 10 + 3);

    await fetchTasks(); // Yeh automatically notifyListeners() call kar dega
  }

  // UI ko jo tasks show karne hain (Filtered aur Sorted)
  List<TaskModel> get displayTasks {
    List<TaskModel> filtered = _allTasks.where((task) {
      final matchesCompletion = task.isCompleted == showCompleted;
      final matchesSearch = task.title.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesCategory = selectedCategory == 'All' || task.category == selectedCategory;
      return matchesCompletion && matchesSearch && matchesCategory;
    }).toList();

    filtered.sort((a, b) {
      if (sortBy == 'Time') {
        int timeCompare = a.dateTime.compareTo(b.dateTime);
        if (timeCompare != 0) return timeCompare;
        return b.priority.compareTo(a.priority);
      } else {
        int priorityCompare = b.priority.compareTo(a.priority);
        if (priorityCompare != 0) return priorityCompare;
        return a.dateTime.compareTo(b.dateTime);
      }
    });

    return filtered;
  }
}