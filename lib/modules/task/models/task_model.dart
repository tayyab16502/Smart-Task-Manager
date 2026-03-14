import 'dart:convert';

class SubTask {
  final String title;
  final bool isCompleted;
  final DateTime? deadline;

  SubTask({
    required this.title,
    this.isCompleted = false,
    this.deadline,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isCompleted': isCompleted ? 1 : 0,
      'deadline': deadline?.toIso8601String(),
    };
  }

  factory SubTask.fromMap(Map<String, dynamic> map) {
    return SubTask(
      title: map['title'] as String,
      isCompleted: map['isCompleted'] == 1 || map['isCompleted'] == true,
      deadline: map['deadline'] != null ? DateTime.parse(map['deadline'] as String) : null,
    );
  }

  SubTask copyWith({
    String? title,
    bool? isCompleted,
    DateTime? deadline,
  }) {
    return SubTask(
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      deadline: deadline ?? this.deadline,
    );
  }
}

class TaskModel {
  final int? id;
  final String title;
  final String description;
  final DateTime dateTime;
  final int priority;
  final String category;
  final bool isCompleted;
  final List<SubTask> subTasks;

  TaskModel({
    this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.priority,
    required this.category,
    required this.isCompleted,
    this.subTasks = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
      'priority': priority,
      'category': category,
      'isCompleted': isCompleted ? 1 : 0,
      'subTasks': jsonEncode(subTasks.map((e) => e.toMap()).toList()),
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    List<SubTask> parsedSubTasks = [];
    if (map['subTasks'] != null) {
      try {
        final List<dynamic> decodedList = jsonDecode(map['subTasks'] as String);
        parsedSubTasks = decodedList
            .map((e) => SubTask.fromMap(e as Map<String, dynamic>))
            .toList();
      } catch (e) {
        parsedSubTasks = [];
      }
    }

    return TaskModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      dateTime: DateTime.parse(map['dateTime'] as String),
      priority: map['priority'] as int,
      category: map['category'] as String,
      isCompleted: map['isCompleted'] == 1,
      subTasks: parsedSubTasks,
    );
  }

  TaskModel copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? dateTime,
    int? priority,
    String? category,
    bool? isCompleted,
    List<SubTask>? subTasks,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      subTasks: subTasks ?? this.subTasks,
    );
  }
}