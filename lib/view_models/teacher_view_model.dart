import 'package:flutter/material.dart';
import 'package:student_management/models/class_model.dart';
import 'package:student_management/models/user_model.dart';
import 'package:student_management/models/attendance_model.dart';
import 'package:student_management/models/result_model.dart';
import 'package:student_management/models/notification_model.dart';
import 'package:student_management/models/attendance_session_model.dart';
import 'package:student_management/services/class_service.dart';
import 'package:student_management/services/user_service.dart';
import 'package:student_management/services/attendance_service.dart';
import 'package:student_management/services/result_service.dart';
import 'package:student_management/services/notification_service.dart';
import 'package:student_management/services/excel_service.dart';
import 'package:student_management/services/attendance_session_service.dart';

class TeacherViewModel with ChangeNotifier {
  final ClassService _classService = ClassService();
  final UserService _userService = UserService();
  final AttendanceService _attendanceService = AttendanceService();
  final ResultService _resultService = ResultService();
  final NotificationService _notificationService = NotificationService();
  final ExcelService _excelService = ExcelService();
  final AttendanceSessionService _attendanceSessionService = AttendanceSessionService();
  
  List<ClassModel> _classes = [];
  ClassModel? _selectedClass;
  List<UserModel> _studentsInClass = [];
  List<AttendanceModel> _attendanceRecords = [];
  List<ResultModel> _resultRecords = [];
  AttendanceSessionModel? _activeAttendanceSession;
  
  bool _isLoading = false;
  String? _errorMessage;
  
  List<ClassModel> get classes => _classes;
  ClassModel? get selectedClass => _selectedClass;
  List<UserModel> get studentsInClass => _studentsInClass;
  List<AttendanceModel> get attendanceRecords => _attendanceRecords;
  List<ResultModel> get resultRecords => _resultRecords;
  AttendanceSessionModel? get activeAttendanceSession => _activeAttendanceSession;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  Future<void> loadTeacherClasses(String teacherId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _classes = await _classService.getClassesByTeacherId(teacherId);
      
      // Check for active attendance sessions
      final activeSessions = await _attendanceSessionService.getActiveSessionsByTeacherId(teacherId);
      if (activeSessions.isNotEmpty) {
        _activeAttendanceSession = activeSessions.first;
        
        // Find the class for this session
        final sessionClass = _classes.firstWhere(
          (cls) => cls.id == _activeAttendanceSession!.classId,
          orElse: () => _classes.first,
        );
        
        _selectedClass = sessionClass;
        
        // Load students in this class
        await loadStudentsInClass(sessionClass.id);
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
    
    // Load students in this class
    loadStudentsInClass(classModel.id);
    
    // Load attendance records for this class
    loadAttendanceRecords(classModel.id);
    
    // Load result records for this class
    loadResultRecords(classModel.id);
    
    // Check if there's an active attendance session for this class
    checkActiveAttendanceSession(classModel.id);
  }
  
  Future<void> loadStudentsInClass(String classId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      if (_selectedClass != null) {
        _studentsInClass = [];
        
        for (String studentId in _selectedClass!.enrolledStudents) {
          final student = await _userService.getUserById(studentId);
          if (student != null) {
            _studentsInClass.add(student);
          }
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<bool> createClass({
    required String name,
    required String subject,
    required String teacherId,
    required String teacherName,
    required String schedule,
    required String description,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final newClass = ClassModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        subject: subject,
        teacherId: teacherId,
        teacherName: teacherName,
        schedule: schedule,
        description: description,
        enrolledStudents: [],
        createdAt: DateTime.now(),
      );
      
      await _classService.createClass(newClass);
      
      // Reload classes
      await loadTeacherClasses(teacherId);
      
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
  
  Future<bool> enrollStudent(String studentId) async {
    if (_selectedClass == null) return false;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Check if student exists
      final student = await _userService.getUserById(studentId);
      
      if (student == null) {
        _errorMessage = 'Student not found.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      // Check if student is already enrolled
      if (_selectedClass!.enrolledStudents.contains(studentId)) {
        _errorMessage = 'Student is already enrolled in this class.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      // Add student to class
      final updatedEnrolledStudents = [..._selectedClass!.enrolledStudents, studentId];
      
      final updatedClass = ClassModel(
        id: _selectedClass!.id,
        name: _selectedClass!.name,
        subject: _selectedClass!.subject,
        teacherId: _selectedClass!.teacherId,
        teacherName: _selectedClass!.teacherName,
        schedule: _selectedClass!.schedule,
        description: _selectedClass!.description,
        enrolledStudents: updatedEnrolledStudents,
        createdAt: _selectedClass!.createdAt,
      );
      
      await _classService.updateClass(updatedClass);
      
      // Update selected class
      _selectedClass = updatedClass;
      
      // Reload students in class
      await loadStudentsInClass(_selectedClass!.id);
      
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
  
  Future<void> loadAttendanceRecords(String classId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _attendanceRecords = await _attendanceService.getAttendanceByClassId(classId);
    } catch (e) {
      _errorMessage = e.toString();
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<bool> markAttendance({
    required String studentId,
    required String studentName,
    required AttendanceStatus status,
  }) async {
    if (_selectedClass == null || _activeAttendanceSession == null) return false;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final attendance = AttendanceModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        classId: _selectedClass!.id,
        className: _selectedClass!.name,
        studentId: studentId,
        studentName: studentName,
        status: status,
        date: DateTime.now(),
        teacherId: _selectedClass!.teacherId,
      );
      
      await _attendanceService.createAttendance(attendance);
      
      // Send notification to student
      final notification = NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Attendance Updated',
        message: 'Your attendance for ${_selectedClass!.name} has been marked as ${status.toString().split('.').last}.',
        type: NotificationType.attendance,
        classId: _selectedClass!.id,
        senderId: _selectedClass!.teacherId,
        recipientId: studentId,
        createdAt: DateTime.now(),
      );
      
      await _notificationService.sendNotification(notification);
      
      // Reload attendance records
      await loadAttendanceRecords(_selectedClass!.id);
      
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
  
  Future<void> loadResultRecords(String classId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _resultRecords = await _resultService.getResultsByClassId(classId);
    } catch (e) {
      _errorMessage = e.toString();
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<bool> updateStudentResult({
    required String studentId,
    required String studentName,
    double? midtermScore,
    double? finalScore,
    double? groupWorkScore,
    double? participationScore,
    String? feedback,
  }) async {
    if (_selectedClass == null) return false;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Calculate overall score
      double overallScore = 0;
      int countScores = 0;
      
      if (midtermScore != null) {
        overallScore += midtermScore * 0.3; // 30% weight
        countScores++;
      }
      
      if (finalScore != null) {
        overallScore += finalScore * 0.4; // 40% weight
        countScores++;
      }
      
      if (groupWorkScore != null) {
        overallScore += groupWorkScore * 0.2; // 20% weight
        countScores++;
      }
      
      if (participationScore != null) {
        overallScore += participationScore * 0.1; // 10% weight
        countScores++;
      }
      
      // Check if result already exists for this student
      final existingResult = _resultRecords.firstWhere(
        (result) => result.studentId == studentId,
        orElse: () => ResultModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          classId: _selectedClass!.id,
          className: _selectedClass!.name,
          studentId: studentId,
          studentName: studentName,
          updatedAt: DateTime.now(),
          teacherId: _selectedClass!.teacherId,
        ),
      );
      
      final updatedResult = existingResult.copyWith(
        midtermScore: midtermScore ?? existingResult.midtermScore,
        finalScore: finalScore ?? existingResult.finalScore,
        groupWorkScore: groupWorkScore ?? existingResult.groupWorkScore,
        participationScore: participationScore ?? existingResult.participationScore,
        overallScore: countScores > 0 ? overallScore : existingResult.overallScore,
        feedback: feedback ?? existingResult.feedback,
        updatedAt: DateTime.now(),
      );
      
      if (existingResult.id == updatedResult.id) {
        await _resultService.createResult(updatedResult);
      } else {
        await _resultService.updateResult(updatedResult);
      }
      
      // Send notification to student
      final notification = NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Results Updated',
        message: 'Your results for ${_selectedClass!.name} have been updated.',
        type: NotificationType.result,
        classId: _selectedClass!.id,
        senderId: _selectedClass!.teacherId,
        recipientId: studentId,
        createdAt: DateTime.now(),
      );
      
      await _notificationService.sendNotification(notification);
      
      // Reload result records
      await loadResultRecords(_selectedClass!.id);
      
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
  
  Future<String?> generateAttendanceExcel() async {
    if (_selectedClass == null || _studentsInClass.isEmpty) return null;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final filePath = await _excelService.generateAttendanceExcel(
        className: _selectedClass!.name,
        students: _studentsInClass,
        attendanceRecords: _attendanceRecords,
      );
      
      _isLoading = false;
      notifyListeners();
      return filePath;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
  
  Future<String?> generateResultsExcel() async {
    if (_selectedClass == null || _studentsInClass.isEmpty) return null;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final filePath = await _excelService.generateResultsExcel(
        className: _selectedClass!.name,
        students: _studentsInClass,
        resultRecords: _resultRecords,
      );
      
      _isLoading = false;
      notifyListeners();
      return filePath;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
  
  // Attendance Session Management
  Future<void> checkActiveAttendanceSession(String classId) async {
    try {
      _activeAttendanceSession = await _attendanceSessionService.getActiveSessionByClassId(classId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
  
  Future<bool> startAttendanceSession() async {
    if (_selectedClass == null) return false;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Check if there's already an active session
      final existingSession = await _attendanceSessionService.getActiveSessionByClassId(_selectedClass!.id);
      
      if (existingSession != null) {
        _errorMessage = 'There is already an active attendance session for this class.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      // Create new attendance session
      final newSession = AttendanceSessionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        classId: _selectedClass!.id,
        className: _selectedClass!.name,
        teacherId: _selectedClass!.teacherId,
        startTime: DateTime.now(),
        isActive: true,
      );
      
      _activeAttendanceSession = await _attendanceSessionService.createAttendanceSession(newSession);
      
      // Send notifications to all students in the class
      for (UserModel student in _studentsInClass) {
        final notification = NotificationModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'Attendance Open',
          message: 'Attendance for ${_selectedClass!.name} is now open. Please mark your attendance.',
          type: NotificationType.attendance,
          classId: _selectedClass!.id,
          senderId: _selectedClass!.teacherId,
          recipientId: student.id,
          createdAt: DateTime.now(),
        );
        
        await _notificationService.sendNotification(notification);
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
  
  Future<bool> endAttendanceSession() async {
    if (_activeAttendanceSession == null) return false;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      await _attendanceSessionService.endAttendanceSession(_activeAttendanceSession!.id);
      
      // Send notifications to all students in the class
      for (UserModel student in _studentsInClass) {
        final notification = NotificationModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'Attendance Closed',
          message: 'Attendance for ${_selectedClass!.name} is now closed.',
          type: NotificationType.attendance,
          classId: _selectedClass!.id,
          senderId: _selectedClass!.teacherId,
          recipientId: student.id,
          createdAt: DateTime.now(),
        );
        
        await _notificationService.sendNotification(notification);
      }
      
      _activeAttendanceSession = null;
      
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

