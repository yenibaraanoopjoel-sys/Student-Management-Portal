class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // 'admin' | 'faculty' | 'student'
  final String profileImage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? studentId; // If student
  final String? facultyId; // If faculty

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.profileImage = '',
    DateTime? createdAt,
    DateTime? updatedAt,
    this.studentId,
    this.facultyId,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: (map['role'] ?? 'student').toString().toLowerCase(),
      profileImage: map['profileImage'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      studentId: map['studentId'],
      facultyId: map['facultyId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role.toLowerCase(),
      'profileImage': profileImage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (studentId != null) 'studentId': studentId,
      if (facultyId != null) 'facultyId': facultyId,
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? role,
    String? profileImage,
    String? studentId,
    String? facultyId,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      studentId: studentId ?? this.studentId,
      facultyId: facultyId ?? this.facultyId,
    );
  }
}
