class MarksModel {
  final String id;
  final String studentId;
  final String studentRoll;
  final String studentName;
  final String subjectId;
  final String subjectName;
  final String facultyId;
  final double internalMarks;
  final double assignmentMarks;
  final double examMarks;
  final double totalMarks;
  final String grade;
  final String semester;
  final DateTime updatedAt;

  MarksModel({
    required this.id,
    required this.studentId,
    required this.studentRoll,
    required this.studentName,
    required this.subjectId,
    required this.subjectName,
    required this.facultyId,
    required this.internalMarks,
    required this.assignmentMarks,
    required this.examMarks,
    required this.totalMarks,
    required this.grade,
    required this.semester,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  static String calculateGrade(double total) {
    if (total >= 90) return 'O';
    if (total >= 80) return 'A+';
    if (total >= 70) return 'A';
    if (total >= 60) return 'B+';
    if (total >= 50) return 'B';
    if (total >= 40) return 'C';
    return 'F';
  }

  factory MarksModel.fromMap(Map<String, dynamic> map, String docId) {
    final internal = (map['internalMarks'] is num) ? (map['internalMarks'] as num).toDouble() : 0.0;
    final assignment = (map['assignmentMarks'] is num) ? (map['assignmentMarks'] as num).toDouble() : 0.0;
    final exam = (map['examMarks'] is num) ? (map['examMarks'] as num).toDouble() : 0.0;
    final total = (map['totalMarks'] is num) ? (map['totalMarks'] as num).toDouble() : (internal + assignment + exam);
    final calculatedGrade = map['grade'] ?? calculateGrade(total);

    return MarksModel(
      id: docId,
      studentId: map['studentId'] ?? '',
      studentRoll: map['studentRoll'] ?? '',
      studentName: map['studentName'] ?? '',
      subjectId: map['subjectId'] ?? '',
      subjectName: map['subjectName'] ?? '',
      facultyId: map['facultyId'] ?? '',
      internalMarks: internal,
      assignmentMarks: assignment,
      examMarks: exam,
      totalMarks: total,
      grade: calculatedGrade,
      semester: map['semester']?.toString() ?? '1',
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString()) ?? DateTime.now()
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
      'internalMarks': internalMarks,
      'assignmentMarks': assignmentMarks,
      'examMarks': examMarks,
      'totalMarks': totalMarks,
      'grade': grade,
      'semester': semester,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
