class StudentModel {
  final String id; // Document ID
  final String studentId; // Unique Roll/Admission ID (e.g., STU-2024-001)
  final String fullName;
  final String email;
  final String phone;
  final String dob;
  final String gender;
  final String department;
  final String course;
  final String year;
  final String semester;
  final String section;
  final String address;
  final String profileImage;
  final String admissionDate;
  final String parentName;
  final String parentContact;
  final String status; // 'Active' | 'Inactive' | 'Graduated'

  StudentModel({
    required this.id,
    required this.studentId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.dob,
    required this.gender,
    required this.department,
    required this.course,
    required this.year,
    required this.semester,
    required this.section,
    required this.address,
    this.profileImage = '',
    required this.admissionDate,
    required this.parentName,
    required this.parentContact,
    this.status = 'Active',
  });

  factory StudentModel.fromMap(Map<String, dynamic> map, String docId) {
    return StudentModel(
      id: docId,
      studentId: map['studentId'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      dob: map['dob'] ?? '',
      gender: map['gender'] ?? 'Other',
      department: map['department'] ?? '',
      course: map['course'] ?? '',
      year: map['year']?.toString() ?? '1st Year',
      semester: map['semester']?.toString() ?? '1',
      section: map['section'] ?? 'A',
      address: map['address'] ?? '',
      profileImage: map['profileImage'] ?? '',
      admissionDate: map['admissionDate'] ?? '',
      parentName: map['parentName'] ?? '',
      parentContact: map['parentContact'] ?? '',
      status: map['status'] ?? 'Active',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'dob': dob,
      'gender': gender,
      'department': department,
      'course': course,
      'year': year,
      'semester': semester,
      'section': section,
      'address': address,
      'profileImage': profileImage,
      'admissionDate': admissionDate,
      'parentName': parentName,
      'parentContact': parentContact,
      'status': status,
    };
  }

  StudentModel copyWith({
    String? studentId,
    String? fullName,
    String? email,
    String? phone,
    String? dob,
    String? gender,
    String? department,
    String? course,
    String? year,
    String? semester,
    String? section,
    String? address,
    String? profileImage,
    String? admissionDate,
    String? parentName,
    String? parentContact,
    String? status,
  }) {
    return StudentModel(
      id: id,
      studentId: studentId ?? this.studentId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      department: department ?? this.department,
      course: course ?? this.course,
      year: year ?? this.year,
      semester: semester ?? this.semester,
      section: section ?? this.section,
      address: address ?? this.address,
      profileImage: profileImage ?? this.profileImage,
      admissionDate: admissionDate ?? this.admissionDate,
      parentName: parentName ?? this.parentName,
      parentContact: parentContact ?? this.parentContact,
      status: status ?? this.status,
    );
  }
}
