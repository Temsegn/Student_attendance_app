import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_management/models/user_model.dart';
import 'package:student_management/view_models/auth_view_model.dart';
import 'package:student_management/view_models/teacher_view_model.dart';
import 'package:student_management/view_models/todo_view_model.dart';
import 'package:student_management/views/teacher/teacher_classes_view.dart';
import 'package:student_management/views/teacher/teacher_attendance_view.dart';
import 'package:student_management/views/teacher/teacher_results_view.dart';
import 'package:student_management/views/teacher/teacher_reports_view.dart';
import 'package:student_management/views/teacher/teacher_todo_view.dart';
import 'package:student_management/views/auth/login_screen.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({Key? key}) : super(key: key);

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  int _selectedIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final teacherViewModel = Provider.of<TeacherViewModel>(context, listen: false);
    final todoViewModel = Provider.of<TodoViewModel>(context, listen: false);
    
    if (authViewModel.currentUser != null) {
      await teacherViewModel.loadTeacherClasses(authViewModel.currentUser!.id);
      await todoViewModel.loadTodos(authViewModel.currentUser!.id);
    }
  }
  
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  
  Future<void> _logout() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    await authViewModel.signOut();
    
    if (!mounted) return;
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final teacherViewModel = Provider.of<TeacherViewModel>(context);
    
    if (authViewModel.currentUser == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    final UserModel teacher = authViewModel.currentUser!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${teacher.name}'),
        actions: [
          if (teacherViewModel.activeAttendanceSession != null)
            IconButton(
              icon: const Icon(Icons.timer_off),
              onPressed: () async {
                final result = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('End Attendance Session'),
                    content: const Text('Are you sure you want to end the current attendance session?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('End Session'),
                      ),
                    ],
                  ),
                );
                
                if (result == true) {
                  await teacherViewModel.endAttendanceSession();
                  
                  if (!mounted) return;
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Attendance session ended successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              tooltip: 'End Attendance Session',
            ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: _logout,
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.class_),
            label: 'Classes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_turned_in),
            label: 'Attendance',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Results',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_box),
            label: 'Todo',
          ),
        ],
      ),
    );
  }
  
  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const TeacherClassesView();
      case 1:
        return const TeacherAttendanceView();
      case 2:
        return const TeacherResultsView();
      case 3:
        return const TeacherReportsView();
      case 4:
        return const TeacherTodoView();
      default:
        return const TeacherClassesView();
    }
  }
}

