import 'dart:async';
import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../models/department_model.dart';
import '../models/subject_model.dart';
import '../models/timetable_model.dart';
import '../models/announcement_model.dart';
import '../services/firestore_service.dart';

class AcademicProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();
  final List<StreamSubscription> _subs = [];

  List<CourseModel> _courses = [];
  List<DepartmentModel> _departments = [];
  List<SubjectModel> _subjects = [];
  List<TimetableModel> _timetables = [];
  List<AnnouncementModel> _announcements = [];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<CourseModel> get courses => _courses;
  List<DepartmentModel> get departments => _departments;
  List<SubjectModel> get subjects => _subjects;
  List<TimetableModel> get timetables => _timetables;
  List<AnnouncementModel> get announcements => _announcements;

  AcademicProvider() {
    _courses = _service.currentCourses;
    _departments = _service.currentDepartments;
    _subjects = _service.currentSubjects;
    _timetables = _service.currentTimetable;
    _announcements = _service.currentAnnouncements;

    _subs.add(_service.streamCourses().listen((l) { _courses = l; notifyListeners(); }));
    _subs.add(_service.streamDepartments().listen((l) { _departments = l; notifyListeners(); }));
    _subs.add(_service.streamSubjects().listen((l) { _subjects = l; notifyListeners(); }));
    _subs.add(_service.streamTimetable().listen((l) { _timetables = l; notifyListeners(); }));
    _subs.add(_service.streamAnnouncements().listen((l) { _announcements = l; notifyListeners(); }));
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    super.dispose();
  }

  // Course methods
  Future<void> addCourse(CourseModel course) async {
    _isLoading = true; notifyListeners();
    await _service.addCourse(course);
    _isLoading = false; notifyListeners();
  }
  Future<void> updateCourse(CourseModel course) async {
    _isLoading = true; notifyListeners();
    await _service.updateCourse(course);
    _isLoading = false; notifyListeners();
  }
  Future<void> deleteCourse(String id) async {
    _isLoading = true; notifyListeners();
    await _service.deleteCourse(id);
    _isLoading = false; notifyListeners();
  }

  // Department methods
  Future<void> addDepartment(DepartmentModel dept) async {
    _isLoading = true; notifyListeners();
    await _service.addDepartment(dept);
    _isLoading = false; notifyListeners();
  }
  Future<void> updateDepartment(DepartmentModel dept) async {
    _isLoading = true; notifyListeners();
    await _service.updateDepartment(dept);
    _isLoading = false; notifyListeners();
  }
  Future<void> deleteDepartment(String id) async {
    _isLoading = true; notifyListeners();
    await _service.deleteDepartment(id);
    _isLoading = false; notifyListeners();
  }

  // Subject methods
  Future<void> addSubject(SubjectModel sub) async {
    _isLoading = true; notifyListeners();
    await _service.addSubject(sub);
    _isLoading = false; notifyListeners();
  }
  Future<void> updateSubject(SubjectModel sub) async {
    _isLoading = true; notifyListeners();
    await _service.updateSubject(sub);
    _isLoading = false; notifyListeners();
  }
  Future<void> deleteSubject(String id) async {
    _isLoading = true; notifyListeners();
    await _service.deleteSubject(id);
    _isLoading = false; notifyListeners();
  }

  // Timetable methods
  Future<void> addTimetableSlot(TimetableModel slot) async {
    _isLoading = true; notifyListeners();
    await _service.addTimetableSlot(slot);
    _isLoading = false; notifyListeners();
  }
  Future<void> deleteTimetableSlot(String id) async {
    _isLoading = true; notifyListeners();
    await _service.deleteTimetableSlot(id);
    _isLoading = false; notifyListeners();
  }

  // Announcement methods
  Future<void> addAnnouncement(AnnouncementModel ann) async {
    _isLoading = true; notifyListeners();
    await _service.addAnnouncement(ann);
    _isLoading = false; notifyListeners();
  }
  Future<void> deleteAnnouncement(String id) async {
    _isLoading = true; notifyListeners();
    await _service.deleteAnnouncement(id);
    _isLoading = false; notifyListeners();
  }

  // One-click Firestore Seeder for Admin
  Future<bool> seedFirestore() async {
    _isLoading = true; notifyListeners();
    final res = await _service.seedFirestore();
    _isLoading = false; notifyListeners();
    return res;
  }
}
