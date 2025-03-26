import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:student_management/models/todo_model.dart';
import 'package:student_management/services/notification_service.dart';

class TodoViewModel with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  
  List<TodoModel> _todos = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  List<TodoModel> get todos => _todos;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  Future<void> loadTodos(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final todoBox = await Hive.openBox<TodoModel>('todoBox');
      
      // Filter todos by userId
      _todos = todoBox.values
          .where((todo) => todo.userId == userId)
          .toList();
      
      // Sort by due date (closest first) and then by priority (high to low)
      _todos.sort((a, b) {
        final dateComparison = a.dueDate.compareTo(b.dueDate);
        if (dateComparison != 0) return dateComparison;
        
        return b.priority.index.compareTo(a.priority.index);
      });
    } catch (e) {
      _errorMessage = e.toString();
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<bool> addTodo(TodoModel todo) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final todoBox = await Hive.openBox<TodoModel>('todoBox');
      await todoBox.put(todo.id, todo);
      
      // Schedule notification for the todo
      await _notificationService.scheduleTodoNotification(
        id: int.parse(todo.id),
        title: 'Todo Reminder',
        body: todo.title,
        scheduledDate: todo.dueDate.subtract(const Duration(hours: 1)),
      );
      
      await loadTodos(todo.userId);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> updateTodo(TodoModel todo) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final todoBox = await Hive.openBox<TodoModel>('todoBox');
      await todoBox.put(todo.id, todo);
      
      // Cancel previous notification and schedule a new one if not completed
      await _notificationService.cancelNotification(int.parse(todo.id));
      
      if (!todo.isCompleted) {
        await _notificationService.scheduleTodoNotification(
          id: int.parse(todo.id),
          title: 'Todo Reminder',
          body: todo.title,
          scheduledDate: todo.dueDate.subtract(const Duration(hours: 1)),
        );
      }
      
      await loadTodos(todo.userId);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> deleteTodo(String todoId, String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final todoBox = await Hive.openBox<TodoModel>('todoBox');
      await todoBox.delete(todoId);
      
      // Cancel notification
      await _notificationService.cancelNotification(int.parse(todoId));
      
      await loadTodos(userId);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> toggleTodoCompletion(String todoId, String userId) async {
    try {
      final todoBox = await Hive.openBox<TodoModel>('todoBox');
      final todo = todoBox.get(todoId);
      
      if (todo != null) {
        final updatedTodo = todo.copyWith(isCompleted: !todo.isCompleted);
        
        // Cancel notification if completed
        if (updatedTodo.isCompleted) {
          await _notificationService.cancelNotification(int.parse(todoId));
        } else {
          // Reschedule notification if uncompleted and due date is in the future
          if (updatedTodo.dueDate.isAfter(DateTime.now())) {
            await _notificationService.scheduleTodoNotification(
              id: int.parse(todoId),
              title: 'Todo Reminder',
              body: updatedTodo.title,
              scheduledDate: updatedTodo.dueDate.subtract(const Duration(hours: 1)),
            );
          }
        }
        
        return await updateTodo(updatedTodo);
      }
      
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}

