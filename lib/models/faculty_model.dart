class FacultyModel {
  final String id; // Document ID
  final String facultyId; // e.g. FAC-101
  final String fullName;
  final String email;
  final String phone;
  final String department;
  final String designation; // Professor, Associate Professor, Asst Professor, etc.
  final List<String> subjects; // Assigned subject IDs / names
  final String joiningDate;
  final String profileImage;
  final String status; // 'Active' | 'Inactive'

  FacultyModel({
    required this.id,
    required this.facultyId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.department,
    required this.designation,
    this.subjects = const [],
    required this.joiningDate,
    this.profileImage = '',
    this.status = 'Active',
  });

  factory FacultyModel.fromMap(Map<String, dynamic> map, String docId) {
    return FacultyModel(
      id: docId,
      facultyId: map['facultyId'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      department: map['department'] ?? '',
      designation: map['designation'] ?? 'Lecturer',
      subjects: List<String>.from(map['subjects'] ?? []),
      joiningDate: map['joiningDate'] ?? '',
      profileImage: map['profileImage'] ?? '',
      status: map['status'] ?? 'Active',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'facultyId': facultyId,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'department': department,
      'designation': designation,
      'subjects': subjects,
      'joiningDate': joiningDate,
      'profileImage': profileImage,
      'status': status,
    };
  }

  FacultyModel copyWith({
    String? facultyId,
    String? fullName,
    String? email,
    String? phone,
    String? department,
    String? designation,
    List<String>? subjects,
    String? joiningDate,
    String? profileImage,
    String? status,
  }) {
    return FacultyModel(
      id: id,
      facultyId: facultyId ?? this.facultyId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      department: department ?? this.department,
      designation: designation ?? this.designation,
      subjects: subjects ?? this.subjects,
      joiningDate: joiningDate ?? this.joiningDate,
      profileImage: profileImage ?? this.profileImage,
      status: status ?? this.status,
    );
  }
}
