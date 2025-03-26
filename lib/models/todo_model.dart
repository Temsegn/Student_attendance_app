import 'package:hive/hive.dart';

part 'todo_model.g.dart';

enum TodoPriority { low, medium, high }

@HiveType(typeId: 1)
class TodoModel extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String description;
  
  @HiveField(3)
  final DateTime dueDate;
  
  @HiveField(4)
  final bool isCompleted;
  
  @HiveField(5)
  final TodoPriority priority;
  
  @HiveField(6)
  final String userId;
  
  @HiveField(7)
  final DateTime createdAt;
  
  TodoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.isCompleted = false,
    this.priority = TodoPriority.medium,
    required this.userId,
    required this.createdAt,
  });
  
  TodoModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    bool? isCompleted,
    TodoPriority? priority,
    String? userId,
    DateTime? createdAt,
  }) {
    return TodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

