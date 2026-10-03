class SubjectModel {
  final String id;
  final String subjectName;
  final String subjectCode;
  final String course;
  final String department;
  final String semester;
  final int credits;
  final String facultyId;
  final String facultyName;
  final String description;

  SubjectModel({
    required this.id,
    required this.subjectName,
    required this.subjectCode,
    required this.course,
    required this.department,
    required this.semester,
    this.credits = 3,
    this.facultyId = '',
    this.facultyName = 'Unassigned',
    this.description = '',
  });

  factory SubjectModel.fromMap(Map<String, dynamic> map, String docId) {
    return SubjectModel(
      id: docId,
      subjectName: map['subjectName'] ?? '',
      subjectCode: map['subjectCode'] ?? '',
      course: map['course'] ?? '',
      department: map['department'] ?? '',
      semester: map['semester']?.toString() ?? '1',
      credits: (map['credits'] is int)
          ? map['credits']
          : int.tryParse(map['credits']?.toString() ?? '3') ?? 3,
      facultyId: map['facultyId'] ?? '',
      facultyName: map['facultyName'] ?? 'Unassigned',
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'subjectName': subjectName,
      'subjectCode': subjectCode,
      'course': course,
      'department': department,
      'semester': semester,
      'credits': credits,
      'facultyId': facultyId,
      'facultyName': facultyName,
      'description': description,
    };
  }

  SubjectModel copyWith({
    String? subjectName,
    String? subjectCode,
    String? course,
    String? department,
    String? semester,
    int? credits,
    String? facultyId,
    String? facultyName,
    String? description,
  }) {
    return SubjectModel(
      id: id,
      subjectName: subjectName ?? this.subjectName,
      subjectCode: subjectCode ?? this.subjectCode,
      course: course ?? this.course,
      department: department ?? this.department,
      semester: semester ?? this.semester,
      credits: credits ?? this.credits,
      facultyId: facultyId ?? this.facultyId,
      facultyName: facultyName ?? this.facultyName,
      description: description ?? this.description,
    );
  }
}
