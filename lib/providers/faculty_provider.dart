import 'dart:async';
import 'package:flutter/material.dart';
import '../models/faculty_model.dart';
import '../services/firestore_service.dart';

class FacultyProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();
  StreamSubscription? _sub;

  List<FacultyModel> _faculty = [];
  String _searchQuery = '';
  String _selectedDepartment = 'All';
  bool _isLoading = false;

  List<FacultyModel> get allFaculty => _faculty;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedDepartment => _selectedDepartment;

  List<FacultyModel> get filteredFaculty {
    return _faculty.where((f) {
      final matchesQuery = _searchQuery.isEmpty ||
          f.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          f.facultyId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          f.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          f.department.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesDept = _selectedDepartment == 'All' || f.department == _selectedDepartment;
      return matchesQuery && matchesDept;
    }).toList();
  }

  FacultyProvider() {
    _faculty = _service.currentFaculty;
    _sub = _service.streamFaculty().listen((list) {
      _faculty = list;
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

  FacultyModel? getFacultyById(String id) {
    try {
      return _faculty.firstWhere((f) => f.id == id || f.facultyId == id || f.email == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addFaculty(FacultyModel faculty) async {
    _isLoading = true;
    notifyListeners();
    await _service.addFaculty(faculty);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateFaculty(FacultyModel faculty) async {
    _isLoading = true;
    notifyListeners();
    await _service.updateFaculty(faculty);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteFaculty(String id) async {
    _isLoading = true;
    notifyListeners();
    await _service.deleteFaculty(id);
    _isLoading = false;
    notifyListeners();
  }
}
