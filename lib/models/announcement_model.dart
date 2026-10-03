class AnnouncementModel {
  final String id;
  final String title;
  final String description;
  final String createdBy;
  final String createdByName;
  final String date;
  final String priority; // 'Low' | 'Medium' | 'High' | 'Urgent'
  final String targetAudience; // 'Everyone' | 'Students' | 'Faculty' | 'Department' | 'Course'
  final String? department;
  final String? course;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdBy,
    required this.createdByName,
    required this.date,
    this.priority = 'Medium',
    this.targetAudience = 'Everyone',
    this.department,
    this.course,
  });

  factory AnnouncementModel.fromMap(Map<String, dynamic> map, String docId) {
    return AnnouncementModel(
      id: docId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      createdBy: map['createdBy'] ?? '',
      createdByName: map['createdByName'] ?? 'Admin',
      date: map['date'] ?? '',
      priority: map['priority'] ?? 'Medium',
      targetAudience: map['targetAudience'] ?? 'Everyone',
      department: map['department'],
      course: map['course'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'date': date,
      'priority': priority,
      'targetAudience': targetAudience,
      if (department != null) 'department': department,
      if (course != null) 'course': course,
    };
  }
}
