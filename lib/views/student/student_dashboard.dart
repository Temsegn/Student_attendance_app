import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_management/models/user_model.dart';
import 'package:student_management/view_models/auth_view_model.dart';
import 'package:student_management/view_models/student_view_model.dart';
import 'package:student_management/view_models/todo_view_model.dart';
import 'package:student_management/views/student/student_attendance_view.dart';
import 'package:student_management/views/student/student_results_view.dart';
import 'package:student_management/views/student/student_notifications_view.dart';
import 'package:student_management/views/student/student_todo_view.dart';
import 'package:student_management/views/student/student_subject_results_view.dart';
import 'package:student_management/views/auth/login_screen.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({Key? key}) : super(key: key);

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _selectedIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final studentViewModel = Provider.of<StudentViewModel>(context, listen: false);
    final todoViewModel = Provider.of<TodoViewModel>(context, listen: false);
    
    if (authViewModel.currentUser != null) {
      await studentViewModel.loadEnrolledClasses(authViewModel.currentUser!.id);
      await studentViewModel.loadNotifications(authViewModel.currentUser!.id);
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
    final studentViewModel = Provider.of<StudentViewModel>(context);
    
    if (authViewModel.currentUser == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    final UserModel student = authViewModel.currentUser!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${student.name}'),
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
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
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
        return _buildDashboard();
      case 1:
        return const StudentAttendanceView();
      case 2:
        return const StudentResultsView();
      case 3:
        return const StudentNotificationsView();
      case 4:
        return const StudentTodoView();
      default:
        return _buildDashboard();
    }
  }
  
  Widget _buildDashboard() {
    final studentViewModel = Provider.of<StudentViewModel>(context);
    final authViewModel = Provider.of<AuthViewModel>(context);
    
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.blue.shade100,
                          child: Text(
                            authViewModel.currentUser!.name.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                authViewModel.currentUser!.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Student ID: ${authViewModel.currentUser!.studentId ?? "N/A"}',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                authViewModel.currentUser!.email,
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Active Attendance Sessions
            if (studentViewModel.activeAttendanceSessions.isNotEmpty) ...[
              const Text(
                'Active Attendance Sessions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: studentViewModel.activeAttendanceSessions.length,
                itemBuilder: (context, index) {
                  final session = studentViewModel.activeAttendanceSessions[index];
                  return Card(
                    color: Colors.green.shade50,
                    child: ListTile(
                      title: Text(session.className),
                      subtitle: Text('Started at: ${session.startTime.toString().substring(0, 16)}'),
                      trailing: ElevatedButton(
                        onPressed: () async {
                          await studentViewModel.markOwnAttendance(
                            session.id,
                            authViewModel.currentUser!.id,
                            authViewModel.currentUser!.name,
                          );
                          
                          if (!mounted) return;
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Attendance marked successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        child: const Text('Mark Present'),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
            
            // Enrolled Classes
            const Text(
              'Enrolled Classes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            studentViewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : studentViewModel.enrolledClasses.isEmpty
                    ? const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('You are not enrolled in any classes yet.'),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: studentViewModel.enrolledClasses.length,
                        itemBuilder: (context, index) {
                          final classModel = studentViewModel.enrolledClasses[index];
                          return Card(
                            child: ListTile(
                              title: Text(classModel.name),
                              subtitle: Text(classModel.subject),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.assignment_turned_in),
                                    onPressed: () {
                                      studentViewModel.selectClass(classModel);
                                      setState(() {
                                        _selectedIndex = 1; // Switch to Attendance tab
                                      });
                                    },
                                    tooltip: 'View Attendance',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.school),
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => StudentSubjectResultsView(
                                            classModel: classModel,
                                          ),
                                        ),
                                      );
                                    },
                                    tooltip: 'View Results',
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            
            const SizedBox(height: 16),
            
            // Recent Notifications
            const Text(
              'Recent Notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            studentViewModel.notifications.isEmpty
                ? const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No notifications yet.'),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: studentViewModel.notifications.length > 3
                        ? 3
                        : studentViewModel.notifications.length,
                    itemBuilder: (context, index) {
                      final notification = studentViewModel.notifications[index];
                      return Card(
                        color: notification.isRead ? null : Colors.blue.shade50,
                        child: ListTile(
                          title: Text(notification.title),
                          subtitle: Text(notification.message),
                          trailing: Text(
                            notification.createdAt.toString().substring(0, 16),
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 12,
                            ),
                          ),
                          onTap: () {
                            studentViewModel.markNotificationAsRead(notification.id);
                          },
                        ),
                      );
                    },
                  ),
            
            if (studentViewModel.notifications.length > 3) ...[
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 3; // Switch to Notifications tab
                    });
                  },
                  child: const Text('View All Notifications'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

