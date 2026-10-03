import 'dart:async';
import 'package:flutter/material.dart';
import '../models/student_model.dart';
import '../services/firestore_service.dart';

class StudentProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();
  StreamSubscription? _sub;

  List<StudentModel> _students = [];
  String _searchQuery = '';
  String _selectedDepartment = 'All';
  String _selectedStatus = 'All';
  bool _isLoading = false;

  List<StudentModel> get allStudents => _students;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedDepartment => _selectedDepartment;
  String get selectedStatus => _selectedStatus;

  List<StudentModel> get filteredStudents {
    return _students.where((s) {
      final matchesQuery = _searchQuery.isEmpty ||
          s.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.studentId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.department.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesDept = _selectedDepartment == 'All' || s.department == _selectedDepartment;
      final matchesStatus = _selectedStatus == 'All' || s.status == _selectedStatus;

      return matchesQuery && matchesDept && matchesStatus;
    }).toList();
  }

  StudentProvider() {
    _students = _service.currentStudents;
    _sub = _service.streamStudents().listen((list) {
      _students = list;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setDepartmentFilter(String dept) {
    _selectedDepartment = dept;
    notifyListeners();
  }

  void setStatusFilter(String status) {
    _selectedStatus = status;
    notifyListeners();
  }

  StudentModel? getStudentById(String id) {
    try {
      return _students.firstWhere((s) => s.id == id || s.studentId == id || s.email == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addStudent(StudentModel student) async {
    _isLoading = true;
    notifyListeners();
    await _service.addStudent(student);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateStudent(StudentModel student) async {
    _isLoading = true;
    notifyListeners();
    await _service.updateStudent(student);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteStudent(String id) async {
    _isLoading = true;
    notifyListeners();
    await _service.deleteStudent(id);
    _isLoading = false;
    notifyListeners();
  }
}
