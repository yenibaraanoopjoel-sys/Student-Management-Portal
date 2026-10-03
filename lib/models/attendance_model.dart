class AttendanceModel {
  final String id;
  final String studentId; // Document ID of student
  final String studentRoll; // e.g. STU-2024-001
  final String studentName;
  final String subjectId;
  final String subjectName;
  final String facultyId;
  final String date; // YYYY-MM-DD
  final String status; // 'present' | 'absent'
  final DateTime createdAt;

  AttendanceModel({
    required this.id,
    required this.studentId,
    required this.studentRoll,
    required this.studentName,
    required this.subjectId,
    required this.subjectName,
    required this.facultyId,
    required this.date,
    required this.status,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AttendanceModel.fromMap(Map<String, dynamic> map, String docId) {
    return AttendanceModel(
      id: docId,
      studentId: map['studentId'] ?? '',
      studentRoll: map['studentRoll'] ?? map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      subjectId: map['subjectId'] ?? '',
      subjectName: map['subjectName'] ?? '',
      facultyId: map['facultyId'] ?? '',
      date: map['date'] ?? '',
      status: (map['status'] ?? 'present').toString().toLowerCase(),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentRoll': studentRoll,
      'studentName': studentName,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'facultyId': facultyId,
      'date': date,
      'status': status.toLowerCase(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
