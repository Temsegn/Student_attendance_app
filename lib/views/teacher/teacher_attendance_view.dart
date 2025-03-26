import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_management/models/attendance_model.dart';
import 'package:student_management/view_models/auth_view_model.dart';
import 'package:student_management/view_models/teacher_view_model.dart';
import 'package:intl/intl.dart';

class TeacherAttendanceView extends StatefulWidget {
  const TeacherAttendanceView({Key? key}) : super(key: key);

  @override
  State<TeacherAttendanceView> createState() => _TeacherAttendanceViewState();
}

class _TeacherAttendanceViewState extends State<TeacherAttendanceView> {
  @override
  Widget build(BuildContext context) {
    final teacherViewModel = Provider.of<TeacherViewModel>(context);
    final authViewModel = Provider.of<AuthViewModel>(context);
    
    return Scaffold(
      body: teacherViewModel.selectedClass == null
          ? const Center(
              child: Text('Please select a class first.'),
            )
          : Column(
              children: [
                // Class Info Card
                Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          teacherViewModel.selectedClass!.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Subject: ${teacherViewModel.selectedClass!.subject}',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Schedule: ${teacherViewModel.selectedClass!.schedule}',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: teacherViewModel.activeAttendanceSession != null
                                    ? null
                                    : () async {
                                        final success = await teacherViewModel.startAttendanceSession();
                                        
                                        if (!mounted) return;
                                        
                                        if (success) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Attendance session started successfully!'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(teacherViewModel.errorMessage ?? 'Failed to start attendance session.'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                                child: const Text('Start Attendance'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: teacherViewModel.activeAttendanceSession == null
                                    ? null
                                    : () async {
                                        final success = await teacherViewModel.endAttendanceSession();
                                        
                                        if (!mounted) return;
                                        
                                        if (success) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Attendance session ended successfully!'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(teacherViewModel.errorMessage ?? 'Failed to end attendance session.'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('End Attendance'),
                              ),
                            ),
                          ],
                        ),
                        if (teacherViewModel.activeAttendanceSession != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.timer,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Attendance session active since ${DateFormat('MMM dd, yyyy HH:mm').format(teacherViewModel.activeAttendanceSession!.startTime)}',
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                
                // Students List
                Expanded(
                  child: teacherViewModel.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : teacherViewModel.studentsInClass.isEmpty
                          ? const Center(
                              child: Text('No students enrolled in this class.'),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: teacherViewModel.studentsInClass.length,
                              itemBuilder: (context, index) {
                                final student = teacherViewModel.studentsInClass[index];
                                
                                // Find the latest attendance record for this student
                                final attendanceRecords = teacherViewModel.attendanceRecords
                                    .where((record) => record.studentId == student.id)
                                    .toList();
                                
                                attendanceRecords.sort((a, b) => b.date.compareTo(a.date));
                                
                                final latestAttendance = attendanceRecords.isNotEmpty
                                    ? attendanceRecords.first
                                    : null;
                                
                                return Card(
                                  child: ListTile(
                                    title: Text(student.name),
                                    subtitle: Text('Student ID: ${student.studentId ?? "N/A"}'),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (latestAttendance != null) ...[
                                          _buildAttendanceStatusChip(latestAttendance.status),
                                          const SizedBox(width: 8),
                                        ],
                                        PopupMenuButton<AttendanceStatus>(
                                          onSelected: (status) async {
                                            if (teacherViewModel.activeAttendanceSession == null) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Please start an attendance session first.'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                              return;
                                            }
                                            
                                            final success = await teacherViewModel.markAttendance(
                                              studentId: student.id,
                                              studentName: student.name,
                                              status: status,
                                            );
                                            
                                            if (!mounted) return;
                                            
                                            if (success) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Marked ${student.name} as ${status.toString().split('.').last}'),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(teacherViewModel.errorMessage ?? 'Failed to mark attendance.'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          },
                                          itemBuilder: (context) => [
                                            const PopupMenuItem(
                                              value: AttendanceStatus.present,
                                              child: Text('Present'),
                                            ),
                                            const PopupMenuItem(
                                              value: AttendanceStatus.absent,
                                              child: Text('Absent'),
                                            ),
                                            const PopupMenuItem(
                                              value: AttendanceStatus.late,
                                              child: Text('Late'),
                                            ),
                                          ],
                                          icon: const Icon(Icons.more_vert),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
    );
  }

  
  Widget _buildAttendanceStatusChip(AttendanceStatus status) {
    Color color;
    String label;
    
    switch (status) {
      case AttendanceStatus.present:
        color = Colors.green;
        label = 'Present';
        break;
      case AttendanceStatus.absent:
        color = Colors.red;
        label = 'Absent';
        break;
      case AttendanceStatus.late:
        color = Colors.orange;
        label = 'Late';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

