class TimetableModel {
  final String id;
  final String day; // Monday, Tuesday, etc.
  final String timeSlot; // e.g. 09:00 AM - 10:00 AM
  final String subjectId;
  final String subjectName;
  final String facultyId;
  final String facultyName;
  final String room; // e.g. Room 302, Lab 4
  final String section;
  final String department;
  final String semester;

  TimetableModel({
    required this.id,
    required this.day,
    required this.timeSlot,
    required this.subjectId,
    required this.subjectName,
    required this.facultyId,
    required this.facultyName,
    required this.room,
    required this.section,
    required this.department,
    required this.semester,
  });

  factory TimetableModel.fromMap(Map<String, dynamic> map, String docId) {
    return TimetableModel(
      id: docId,
      day: map['day'] ?? 'Monday',
      timeSlot: map['timeSlot'] ?? '',
      subjectId: map['subjectId'] ?? '',
      subjectName: map['subjectName'] ?? '',
      facultyId: map['facultyId'] ?? '',
      facultyName: map['facultyName'] ?? '',
      room: map['room'] ?? '',
      section: map['section'] ?? 'A',
      department: map['department'] ?? '',
      semester: map['semester']?.toString() ?? '1',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'timeSlot': timeSlot,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'facultyId': facultyId,
      'facultyName': facultyName,
      'room': room,
      'section': section,
      'department': department,
      'semester': semester,
    };
  }
}
