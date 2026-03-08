class TaskModel {
  final int? id;
  final String title;
  final String description;
  final DateTime dateTime;
  final int priority;
  final String category;
  final bool isCompleted;

  TaskModel({
    this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.priority,
    required this.category,
    required this.isCompleted,
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
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      dateTime: DateTime.parse(map['dateTime'] as String),
      priority: map['priority'] as int,
      category: map['category'] as String,
      isCompleted: map['isCompleted'] == 1,
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
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}