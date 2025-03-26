import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_management/models/attendance_session_model.dart';

class AttendanceSessionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Future<List<AttendanceSessionModel>> getActiveSessionsByTeacherId(String teacherId) async {
    try {
      final querySnapshot = await _firestore
          .collection('attendanceSessions')
          .where('teacherId', isEqualTo: teacherId)
          .where('isActive', isEqualTo: true)
          .get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return AttendanceSessionModel.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      rethrow;
    }
  }
  
  Future<AttendanceSessionModel?> getActiveSessionByClassId(String classId) async {
    try {
      final querySnapshot = await _firestore
          .collection('attendanceSessions')
          .where('classId', isEqualTo: classId)
          .where('isActive', isEqualTo: true)
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data();
        return AttendanceSessionModel.fromJson({...data, 'id': doc.id});
      }
      
      return null;
    } catch (e) {
      rethrow;
    }
  }
  
  Future<AttendanceSessionModel> createAttendanceSession(AttendanceSessionModel session) async {
    try {
      final docRef = await _firestore.collection('attendanceSessions').add(session.toJson());
      
      return session.copyWith(id: docRef.id);
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> updateAttendanceSession(AttendanceSessionModel session) async {
    try {
      await _firestore.collection('attendanceSessions').doc(session.id).update(session.toJson());
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> endAttendanceSession(String sessionId) async {
    try {
      await _firestore.collection('attendanceSessions').doc(sessionId).update({
        'isActive': false,
        'endTime': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      rethrow;
    }
  }
}

