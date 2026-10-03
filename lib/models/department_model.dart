class DepartmentModel {
  final String id;
  final String departmentName; // e.g. Computer Science & Engineering
  final String departmentCode; // e.g. CSE
  final String headOfDepartment; // e.g. Dr. Alan Turing
  final String description;

  DepartmentModel({
    required this.id,
    required this.departmentName,
    required this.departmentCode,
    required this.headOfDepartment,
    this.description = '',
  });

  factory DepartmentModel.fromMap(Map<String, dynamic> map, String docId) {
    return DepartmentModel(
      id: docId,
      departmentName: map['departmentName'] ?? '',
      departmentCode: map['departmentCode'] ?? '',
      headOfDepartment: map['headOfDepartment'] ?? '',
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'departmentName': departmentName,
      'departmentCode': departmentCode,
      'headOfDepartment': headOfDepartment,
      'description': description,
    };
  }
}
