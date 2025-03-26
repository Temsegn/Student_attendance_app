import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_management/models/user_model.dart';
import 'package:student_management/view_models/auth_view_model.dart';
import 'package:student_management/view_models/admin_view_model.dart';
import 'package:student_management/view_models/todo_view_model.dart';
import 'package:student_management/views/admin/admin_teachers_view.dart';
import 'package:student_management/views/admin/admin_students_view.dart';
import 'package:student_management/views/admin/admin_pending_view.dart';
import 'package:student_management/views/admin/admin_notifications_view.dart';
import 'package:student_management/views/admin/admin_todo_view.dart';
import 'package:student_management/views/auth/login_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    final adminViewModel = Provider.of<AdminViewModel>(context, listen: false);
    final todoViewModel = Provider.of<TodoViewModel>(context, listen: false);
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    
    await adminViewModel.loadAllUsers();
    
    if (authViewModel.currentUser != null) {
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
    
    if (authViewModel.currentUser == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    final UserModel admin = authViewModel.currentUser!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard - ${admin.name}'),
        actions: [
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
            icon: Icon(Icons.person),
            label: 'Teachers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Students',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pending_actions),
            label: 'Pending',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
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
        return const AdminTeachersView();
      case 1:
        return const AdminStudentsView();
      case 2:
        return const AdminPendingView();
      case 3:
        return const AdminNotificationsView();
      case 4:
        return const AdminTodoView();
      default:
        return const AdminTeachersView();
    }
  }
}

