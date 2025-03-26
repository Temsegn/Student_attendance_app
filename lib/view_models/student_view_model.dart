import 'package:flutter/material.dart';
import 'package:student_management/models/class_model.dart';
import 'package:student_management/models/attendance_model.dart';
import 'package:student_management/models/result_model.dart';
import 'package:student_management/models/notification_model.dart';
import 'package:student_management/models/attendance_session_model.dart';
import 'package:student_management/services/class_service.dart';
import 'package:student_management/services/attendance_service.dart';
import 'package:student_management/services/result_service.dart';
import 'package:student_management/services/notification_service.dart';
import 'package:student_management/services/attendance_session_service.dart';

class StudentViewModel with ChangeNotifier {
  final ClassService _classService = ClassService();
  final AttendanceService _attendanceService = AttendanceService();
  final ResultService _resultService = ResultService();
  final NotificationService _notificationService = NotificationService();
  final AttendanceSessionService _attendanceSessionService = AttendanceSessionService();
  
  List<ClassModel> _enrolledClasses = [];
  ClassModel? _selectedClass;
  List<AttendanceModel> _attendanceRecords = [];
  List<ResultModel> _resultRecords = [];
  List<NotificationModel> _notifications = [];
  List<AttendanceSessionModel> _activeAttendanceSessions = [];
  
  bool _isLoading = false;
  String? _errorMessage;
  
  List<ClassModel> get enrolledClasses => _enrolledClasses;
  ClassModel? get selectedClass => _selectedClass;
  List<AttendanceModel> get attendanceRecords => _attendanceRecords;
  List<ResultModel> get resultRecords => _resultRecords;
  List<NotificationModel> get notifications => _notifications;
  List<AttendanceSessionModel> get activeAttendanceSessions => _activeAttendanceSessions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  Future<void> loadEnrolledClasses(String studentId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _enrolledClasses = await _classService.getClassesByStudentId(studentId);
      
      // Check for active attendance sessions
      _activeAttendanceSessions = [];
      for (ClassModel classModel in _enrolledClasses) {
        final session = await _attendanceSessionService.getActiveSessionByClassId(classModel.id);
        if (session != null) {
          _activeAttendanceSessions.add(session);
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  void selectClass(ClassModel classModel) {
    _selectedClass = classModel;
    notifyListeners();
    
    // Load attendance records for this class
    loadAttendanceRecords(classModel.id);
    
    // Load result records for this class
    loadResultRecords(classModel.id);
  }
  
  Future<void> loadAttendanceRecords(String classId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _attendanceRecords = await _attendanceService.getAttendanceByClassIdAndStudentId(
        classId,
        _selectedClass!.enrolledStudents.first,
      );
    } catch (e) {
      _errorMessage = e.toString();
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<void> loadResultRecords(String classId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _resultRecords = await _resultService.getResultsByClassIdAndStudentId(
        classId,
        _selectedClass!.enrolledStudents.first,
      );
    } catch (e) {
      _errorMessage = e.toString();
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<void> loadNotifications(String studentId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _notifications = await _notificationService.getNotificationsByRecipientId(studentId);
      
      // Sort notifications by date (newest first)
      _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      _errorMessage = e.toString();
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<bool> markNotificationAsRead(String notificationId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final notification = _notifications.firstWhere((n) => n.id == notificationId);
      
      final updatedNotification = notification.copyWith(isRead: true);
      
      await _notificationService.updateNotification(updatedNotification);
      
      // Update notification in the list
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      _notifications[index] = updatedNotification;
      
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
  
  // Calculate attendance statistics
  Map<String, dynamic> getAttendanceStatistics() {
    if (_attendanceRecords.isEmpty) {
      return {
        'totalClasses': 0,
        'present': 0,
        'absent': 0,
        'late': 0,
        'presentPercentage': 0.0,
      };
    }
    
    int present = _attendanceRecords.where((a) => a.status == AttendanceStatus.present).length;
    int absent = _attendanceRecords.where((a) => a.status == AttendanceStatus.absent).length;
    int late = _attendanceRecords.where((a) => a.status == AttendanceStatus.late).length;
    int total = _attendanceRecords.length;
    
    double presentPercentage = (present + (late * 0.5)) / total * 100;
    
    return {
      'totalClasses': total,
      'present': present,
      'absent': absent,
      'late': late,
      'presentPercentage': presentPercentage,
    };
  }
  
  // Get results for a specific subject
  ResultModel? getResultForSubject(String subjectName) {
    if (_resultRecords.isEmpty) return null;
    
    try {
      return _resultRecords.firstWhere(
        (result) => result.className.toLowerCase().contains(subjectName.toLowerCase()),
      );
    } catch (e) {
      return null;
    }
  }
  
  // Mark attendance for active session
  Future<bool> markOwnAttendance(String sessionId, String studentId, String studentName) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Find the session
      final session = _activeAttendanceSessions.firstWhere((s) => s.id == sessionId);
      
      // Create attendance record
      final attendance = AttendanceModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        classId: session.classId,
        className: session.className,
        studentId: studentId,
        studentName: studentName,
        status: AttendanceStatus.present, // Student marks themselves as present
        date: DateTime.now(),
        teacherId: session.teacherId,
      );
      
      await _attendanceService.createAttendance(attendance);
      
      // Reload attendance records if this is the selected class
      if (_selectedClass != null && _selectedClass!.id == session.classId) {
        await loadAttendanceRecords(session.classId);
      }
      
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
}

