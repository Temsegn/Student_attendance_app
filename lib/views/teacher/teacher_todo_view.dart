import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_management/models/todo_model.dart';
import 'package:student_management/view_models/auth_view_model.dart';
import 'package:student_management/view_models/todo_view_model.dart';
import 'package:intl/intl.dart';

class TeacherTodoView extends StatefulWidget {
  const TeacherTodoView({Key? key}) : super(key: key);

  @override
  State<TeacherTodoView> createState() => _TeacherTodoViewState();
}

class _TeacherTodoViewState extends State<TeacherTodoView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TodoPriority _selectedPriority = TodoPriority.medium;
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  @override
  void initState() {
    super.initState();
    _loadTodos();
  }
  
  Future<void> _loadTodos() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final todoViewModel = Provider.of<TodoViewModel>(context, listen: false);
    
    if (authViewModel.currentUser != null) {
      await todoViewModel.loadTodos(authViewModel.currentUser!.id);
    }
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  
  void _showAddTodoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Todo'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Due Date:'),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => _selectDate(context),
                      child: Text(
                        DateFormat('MMM dd, yyyy').format(_selectedDate),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<TodoPriority>(
                  value: _selectedPriority,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(),
                  ),
                  items: TodoPriority.values.map((priority) {
                    return DropdownMenuItem<TodoPriority>(
                      value: priority,
                      child: Text(priority.toString().split('.').last.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedPriority = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetForm();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _addTodo,
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
  
  void _resetForm() {
    _titleController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedDate = DateTime.now().add(const Duration(days: 1));
      _selectedPriority = TodoPriority.medium;
    });
  }
  
  Future<void> _addTodo() async {
    if (_formKey.currentState!.validate()) {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      final todoViewModel = Provider.of<TodoViewModel>(context, listen: false);
      
      if (authViewModel.currentUser != null) {
        final newTodo = TodoModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          dueDate: _selectedDate,
          priority: _selectedPriority,
          userId: authViewModel.currentUser!.id,
          createdAt: DateTime.now(),
        );
        
        final success = await todoViewModel.addTodo(newTodo);
        
        if (!mounted) return;
        
        Navigator.of(context).pop();
        
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Todo added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(todoViewModel.errorMessage ?? 'Failed to add todo.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        
        _resetForm();
      }
    }
  }
  
  Color _getPriorityColor(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.low:
        return Colors.green;
      case TodoPriority.medium:
        return Colors.orange;
      case TodoPriority.high:
        return Colors.red;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final todoViewModel = Provider.of<TodoViewModel>(context);
    
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadTodos,
        child: todoViewModel.isLoading
            ? const Center(child: CircularProgressIndicator())
            : todoViewModel.todos.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('No todos yet.'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _showAddTodoDialog,
                          child: const Text('Add Todo'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: todoViewModel.todos.length,
                    itemBuilder: (context, index) {
                      final todo = todoViewModel.todos[index];
                      final isOverdue = todo.dueDate.isBefore(DateTime.now()) && !todo.isCompleted;
                      
                      return Card(
                        color: todo.isCompleted
                            ? Colors.grey.shade100
                            : isOverdue
                                ? Colors.red.shade50
                                : null,
                        child: ListTile(
                          leading: Checkbox(
                            value: todo.isCompleted,
                            onChanged: (value) {
                              final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
                              if (authViewModel.currentUser != null) {
                                todoViewModel.toggleTodoCompletion(todo.id, authViewModel.currentUser!.id);
                              }
                            },
                          ),
                          title: Text(
                            todo.title,
                            style: TextStyle(
                              decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                              color: todo.isCompleted ? Colors.grey : null,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (todo.description.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  todo.description,
                                  style: TextStyle(
                                    decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                                    color: todo.isCompleted ? Colors.grey : null,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _getPriorityColor(todo.priority).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      todo.priority.toString().split('.').last.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: _getPriorityColor(todo.priority),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.calendar_today,
                                    size: 12,
                                    color: isOverdue ? Colors.red : Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormat('MMM dd, yyyy').format(todo.dueDate),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isOverdue ? Colors.red : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
                              if (authViewModel.currentUser != null) {
                                todoViewModel.deleteTodo(todo.id, authViewModel.currentUser!.id);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTodoDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

