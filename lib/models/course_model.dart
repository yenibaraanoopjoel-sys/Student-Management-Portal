class CourseModel {
  final String id;
  final String courseName; // e.g. B.Tech Software Product Engineering
  final String courseCode; // e.g. SPE
  final String department; // e.g. Computer Science & Engineering
  final String duration; // e.g. 4 Years
  final String description;
  final String status; // 'Active' | 'Inactive'

  CourseModel({
    required this.id,
    required this.courseName,
    required this.courseCode,
    required this.department,
    required this.duration,
    this.description = '',
    this.status = 'Active',
  });

  factory CourseModel.fromMap(Map<String, dynamic> map, String docId) {
    return CourseModel(
      id: docId,
      courseName: map['courseName'] ?? '',
      courseCode: map['courseCode'] ?? '',
      department: map['department'] ?? '',
      duration: map['duration'] ?? '4 Years',
      description: map['description'] ?? '',
      status: map['status'] ?? 'Active',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'courseName': courseName,
      'courseCode': courseCode,
      'department': department,
      'duration': duration,
      'description': description,
      'status': status,
    };
  }
}
