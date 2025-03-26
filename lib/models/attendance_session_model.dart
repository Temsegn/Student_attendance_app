class AttendanceSessionModel {
  final String id;
  final String classId;
  final String className;
  final String teacherId;
  final DateTime startTime;
  final DateTime? endTime;
  final bool isActive;
  
  AttendanceSessionModel({
    required this.id,
    required this.classId,
    required this.className,
    required this.teacherId,
    required this.startTime,
    this.endTime,
    required this.isActive,
  });
  
  factory AttendanceSessionModel.fromJson(Map<String, dynamic> json) {
    return AttendanceSessionModel(
      id: json['id'],
      classId: json['classId'],
      className: json['className'],
      teacherId: json['teacherId'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      isActive: json['isActive'] ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'classId': classId,
      'className': className,
      'teacherId': teacherId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'isActive': isActive,
    };
  }
  
  AttendanceSessionModel copyWith({
    String? id,
    String? classId,
    String? className,
    String? teacherId,
    DateTime? startTime,
    DateTime? endTime,
    bool? isActive,
  }) {
    return AttendanceSessionModel(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      className: className ?? this.className,
      teacherId: teacherId ?? this.teacherId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isActive: isActive ?? this.isActive,
    );
  }
}

