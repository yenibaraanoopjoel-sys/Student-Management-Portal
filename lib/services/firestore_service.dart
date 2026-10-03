import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/student_model.dart';
import '../models/faculty_model.dart';
import '../models/course_model.dart';
import '../models/department_model.dart';
import '../models/subject_model.dart';
import '../models/attendance_model.dart';
import '../models/marks_model.dart';
import '../models/timetable_model.dart';
import '../models/announcement_model.dart';
import 'mock_data_seeder.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal() {
    _initLocalStores();
  }

  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  // In-memory synced stores
  final List<StudentModel> _students = [];
  final List<FacultyModel> _faculty = [];
  final List<CourseModel> _courses = [];
  final List<DepartmentModel> _departments = [];
  final List<SubjectModel> _subjects = [];
  final List<AttendanceModel> _attendance = [];
  final List<MarksModel> _marks = [];
  final List<TimetableModel> _timetable = [];
  final List<AnnouncementModel> _announcements = [];
  final List<UserModel> _users = [];

  // Stream controllers for real-time reactivity
  final _studentStreamCtrl = StreamController<List<StudentModel>>.broadcast();
  final _facultyStreamCtrl = StreamController<List<FacultyModel>>.broadcast();
  final _courseStreamCtrl = StreamController<List<CourseModel>>.broadcast();
  final _departmentStreamCtrl = StreamController<List<DepartmentModel>>.broadcast();
  final _subjectStreamCtrl = StreamController<List<SubjectModel>>.broadcast();
  final _attendanceStreamCtrl = StreamController<List<AttendanceModel>>.broadcast();
  final _marksStreamCtrl = StreamController<List<MarksModel>>.broadcast();
  final _timetableStreamCtrl = StreamController<List<TimetableModel>>.broadcast();
  final _announcementStreamCtrl = StreamController<List<AnnouncementModel>>.broadcast();

  void _initLocalStores() {
    _students.addAll(MockDataSeeder.initialStudents);
    _faculty.addAll(MockDataSeeder.initialFaculty);
    _courses.addAll(MockDataSeeder.initialCourses);
    _departments.addAll(MockDataSeeder.initialDepartments);
    _subjects.addAll(MockDataSeeder.initialSubjects);
    _attendance.addAll(MockDataSeeder.initialAttendance);
    _marks.addAll(MockDataSeeder.initialMarks);
    _timetable.addAll(MockDataSeeder.initialTimetable);
    _announcements.addAll(MockDataSeeder.initialAnnouncements);
    _users.addAll(MockDataSeeder.initialUsers);

    _emitAll();
  }

  void _emitAll() {
    _studentStreamCtrl.add(List.unmodifiable(_students));
    _facultyStreamCtrl.add(List.unmodifiable(_faculty));
    _courseStreamCtrl.add(List.unmodifiable(_courses));
    _departmentStreamCtrl.add(List.unmodifiable(_departments));
    _subjectStreamCtrl.add(List.unmodifiable(_subjects));
    _attendanceStreamCtrl.add(List.unmodifiable(_attendance));
    _marksStreamCtrl.add(List.unmodifiable(_marks));
    _timetableStreamCtrl.add(List.unmodifiable(_timetable));
    _announcementStreamCtrl.add(List.unmodifiable(_announcements));
  }

  // ==================== USER OPERATIONS ====================
  Future<UserModel?> getUser(String uid) async {
    try {
      if (_firestore != null) {
        final doc = await _firestore!.collection('users').doc(uid).get();
        if (doc.exists && doc.data() != null) {
          return UserModel.fromMap(doc.data()!, doc.id);
        }
      }
    } catch (_) {}
    
    try {
      return _users.firstWhere((u) => u.uid == uid);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveUser(UserModel user) async {
    try {
      if (_firestore != null) {
        await _firestore!.collection('users').doc(user.uid).set(user.toMap(), SetOptions(merge: true));
      }
    } catch (_) {}

    final index = _users.indexWhere((u) => u.uid == user.uid);
    if (index >= 0) {
      _users[index] = user;
    } else {
      _users.add(user);
    }
  }

  // ==================== STUDENTS ====================
  Stream<List<StudentModel>> streamStudents() {
    try {
      if (_firestore != null) {
        return _firestore!.collection('students').snapshots().map((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            final list = snapshot.docs.map((doc) => StudentModel.fromMap(doc.data(), doc.id)).toList();
            _students.clear();
            _students.addAll(list);
            return list;
          }
          return _students;
        }).handleError((_) => _students);
      }
    } catch (_) {}
    return _studentStreamCtrl.stream;
  }

  List<StudentModel> get currentStudents => List.unmodifiable(_students);

  Future<void> addStudent(StudentModel student) async {
    try {
      if (_firestore != null) {
        final ref = await _firestore!.collection('students').add(student.toMap());
        final newStudent = student.copyWith(studentId: student.studentId);
        final withId = StudentModel.fromMap(student.toMap(), ref.id);
        _students.removeWhere((s) => s.id == ref.id);
        _students.insert(0, withId);
        _studentStreamCtrl.add(List.unmodifiable(_students));
        return;
      }
    } catch (_) {}

    final localId = 'stu_${DateTime.now().millisecondsSinceEpoch}';
    final created = StudentModel.fromMap(student.toMap(), localId);
    _students.insert(0, created);
    _studentStreamCtrl.add(List.unmodifiable(_students));
  }

  Future<void> updateStudent(StudentModel student) async {
    try {
      if (_firestore != null) {
        await _firestore!.collection('students').doc(student.id).update(student.toMap());
      }
    } catch (_) {}

    final index = _students.indexWhere((s) => s.id == student.id);
    if (index >= 0) {
      _students[index] = student;
      _studentStreamCtrl.add(List.unmodifiable(_students));
    }
  }

  Future<void> deleteStudent(String id) async {
    try {
      if (_firestore != null) {
        await _firestore!.collection('students').doc(id).delete();
      }
    } catch (_) {}

    _students.removeWhere((s) => s.id == id);
    _studentStreamCtrl.add(List.unmodifiable(_students));
  }

  // ==================== FACULTY ====================
  Stream<List<FacultyModel>> streamFaculty() {
    try {
      if (_firestore != null) {
        return _firestore!.collection('faculty').snapshots().map((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            final list = snapshot.docs.map((doc) => FacultyModel.fromMap(doc.data(), doc.id)).toList();
            _faculty.clear();
            _faculty.addAll(list);
            return list;
          }
          return _faculty;
        }).handleError((_) => _faculty);
      }
    } catch (_) {}
    return _facultyStreamCtrl.stream;
  }

  List<FacultyModel> get currentFaculty => List.unmodifiable(_faculty);

  Future<void> addFaculty(FacultyModel faculty) async {
    try {
      if (_firestore != null) {
        final ref = await _firestore!.collection('faculty').add(faculty.toMap());
        final withId = FacultyModel.fromMap(faculty.toMap(), ref.id);
        _faculty.insert(0, withId);
        _facultyStreamCtrl.add(List.unmodifiable(_faculty));
        return;
      }
    } catch (_) {}

    final localId = 'fac_${DateTime.now().millisecondsSinceEpoch}';
    final created = FacultyModel.fromMap(faculty.toMap(), localId);
    _faculty.insert(0, created);
    _facultyStreamCtrl.add(List.unmodifiable(_faculty));
  }

  Future<void> updateFaculty(FacultyModel faculty) async {
    try {
      if (_firestore != null) {
        await _firestore!.collection('faculty').doc(faculty.id).update(faculty.toMap());
      }
    } catch (_) {}

    final index = _faculty.indexWhere((f) => f.id == faculty.id);
    if (index >= 0) {
      _faculty[index] = faculty;
      _facultyStreamCtrl.add(List.unmodifiable(_faculty));
    }
  }

  Future<void> deleteFaculty(String id) async {
    try {
      if (_firestore != null) {
        await _firestore!.collection('faculty').doc(id).delete();
      }
    } catch (_) {}

    _faculty.removeWhere((f) => f.id == id);
    _facultyStreamCtrl.add(List.unmodifiable(_faculty));
  }

  // ==================== COURSES ====================
  Stream<List<CourseModel>> streamCourses() {
    try {
      if (_firestore != null) {
        return _firestore!.collection('courses').snapshots().map((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            final list = snapshot.docs.map((doc) => CourseModel.fromMap(doc.data(), doc.id)).toList();
            _courses.clear();
            _courses.addAll(list);
            return list;
          }
          return _courses;
        }).handleError((_) => _courses);
      }
    } catch (_) {}
    return _courseStreamCtrl.stream;
  }

  List<CourseModel> get currentCourses => List.unmodifiable(_courses);

  Future<void> addCourse(CourseModel course) async {
    try {
      if (_firestore != null) {
        final ref = await _firestore!.collection('courses').add(course.toMap());
        final withId = CourseModel.fromMap(course.toMap(), ref.id);
        _courses.insert(0, withId);
        _courseStreamCtrl.add(List.unmodifiable(_courses));
        return;
      }
    } catch (_) {}

    final localId = 'crs_${DateTime.now().millisecondsSinceEpoch}';
    final created = CourseModel.fromMap(course.toMap(), localId);
    _courses.insert(0, created);
    _courseStreamCtrl.add(List.unmodifiable(_courses));
  }

  Future<void> updateCourse(CourseModel course) async {
    try {
      if (_firestore != null) {
        await _firestore!.collection('courses').doc(course.id).update(course.toMap());
      }
    } catch (_) {}

    final index = _courses.indexWhere((c) => c.id == course.id);
    if (index >= 0) {
      _courses[index] = course;
      _courseStreamCtrl.add(List.unmodifiable(_courses));
    }
  }

  Future<void> deleteCourse(String id) async {
    try {
      if (_firestore != null) {
        await _firestore!.collection('courses').doc(id).delete();
      }
    } catch (_) {}

    _courses.removeWhere((c) => c.id == id);
    _courseStreamCtrl.add(List.unmodifiable(_courses));
  }

  // ==================== DEPARTMENTS ====================
  Stream<List<DepartmentModel>> streamDepartments() {
    try {
      if (_firestore != null) {
        return _firestore!.collection('departments').snapshots().map((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            final list = snapshot.docs.map((doc) => DepartmentModel.fromMap(doc.data(), doc.id)).toList();
            _departments.clear();
            _departments.addAll(list);
            return list;
          }
          return _departments;
        }).handleError((_) => _departments);
      }
    } catch (_) {}
    return _departmentStreamCtrl.stream;
  }

  List<DepartmentModel> get currentDepartments => List.unmodifiable(_departments);

  Future<void> addDepartment(DepartmentModel dept) async {
    try {
      if (_firestore != null) {
        final ref = await _firestore!.collection('departments').add(dept.toMap());
        final withId = DepartmentModel.fromMap(dept.toMap(), ref.id);
        _departments.insert(0, withId);
        _departmentStreamCtrl.add(List.unmodifiable(_departments));
        return;
      }
    } catch (_) {}

    final localId = 'dept_${DateTime.now().millisecondsSinceEpoch}';
    final created = DepartmentModel.fromMap(dept.toMap(), localId);
    _departments.insert(0, created);
    _departmentStreamCtrl.add(List.unmodifiable(_departments));
  }

  Future<void> updateDepartment(DepartmentModel dept) async {
    try {
      if (_firestore != null) {
        await _firestore!.collection('departments').doc(dept.id).update(dept.toMap());
      }
    } catch (_) {}

    final index = _departments.indexWhere((d) => d.id == dept.id);
    if (index >= 0) {
      _departments[index] = dept;
      _departmentStreamCtrl.add(List.unmodifiable(_departments));
    }
  }

  Future<void> deleteDepartment(String id) async {
    try {
      if (_firestore != null) {
        await _firestore!.collection('departments').doc(id).delete();
      }
    } catch (_) {}

    _departments.removeWhere((d) => d.id == id);
    _departmentStreamCtrl.add(List.unmodifiable(_departments));
  }

  // ==================== SUBJECTS ====================
  Stream<List<SubjectModel>> streamSubjects() {
    try {
      if (_firestore != null) {
        return _firestore!.collection('subjects').snapshots().map((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            final list = snapshot.docs.map((doc) => SubjectModel.fromMap(doc.data(), doc.id)).toList();
            _subjects.clear();
            _subjects.addAll(list);
            return list;
          }
          return _subjects;
        }).handleError((_) => _subjects);
      }
    } catch (_) {}
    return _subjectStreamCtrl.stream;
  }

  List<SubjectModel> get currentSubjects => List.unmodifiable(_subjects);

  Future<void> addSubject(SubjectModel subject) async {
    try {
      if (_firestore != null) {
        final ref = await _firestore!.collection('subjects').add(subject.toMap());
        final withId = SubjectModel.fromMap(subject.toMap(), ref.id);
        _subjects.insert(0, withId);
        _subjectStreamCtrl.add(List.unmodifiable(_subjects));
        return;
      }
    } catch (_) {}

    final localId = 'sub_${DateTime.now().millisecondsSinceEpoch}';
    final created = SubjectModel.fromMap(subject.toMap(), localId);
    _subjects.insert(0, created);
    _subjectStreamCtrl.add(List.unmodifiable(_subjects));
  }

  Future<void> updateSubject(SubjectModel subject) async {
    try {
      if (_firestore != null) {
        await _firestore!.collection('subjects').doc(subject.id).update(subject.toMap());
      }
    } catch (_) {}

    final index = _subjects.indexWhere((s) => s.id == subject.id);
    if (index >= 0) {
      _subjects[index] = subject;
      _subjectStreamCtrl.add(List.unmodifiable(_subjects));
    }
  }

  Future<void> deleteSubject(String id) async {
    try {
      if (_firestore != null) {
        await _firestore!.collection('subjects').doc(id).delete();
      }
    } catch (_) {}

    _subjects.removeWhere((s) => s.id == id);
    _subjectStreamCtrl.add(List.unmodifiable(_subjects));
  }

  // ==================== ATTENDANCE ====================
  Stream<List<AttendanceModel>> streamAttendance() {
    try {
      if (_firestore != null) {
        return _firestore!.collection('attendance').snapshots().map((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            final list = snapshot.docs.map((doc) => AttendanceModel.fromMap(doc.data(), doc.id)).toList();
            _attendance.clear();
            _attendance.addAll(list);
            return list;
          }
          return _attendance;
        }).handleError((_) => _attendance);
      }
    } catch (_) {}
    return _attendanceStreamCtrl.stream;
  }

  List<AttendanceModel> get currentAttendance => List.unmodifiable(_attendance);

  Future<void> recordBatchAttendance(List<AttendanceModel> records) async {
    for (final rec in records) {
      try {
        if (_firestore != null) {
          // Check if already exists for date + student + subject
          final q = await _firestore!.collection('attendance')
              .where('studentId', isEqualTo: rec.studentId)
              .where('subjectId', isEqualTo: rec.subjectId)
              .where('date', isEqualTo: rec.date)
              .limit(1)
              .get();
          if (q.docs.isNotEmpty) {
            await q.docs.first.reference.update(rec.toMap());
          } else {
            await _firestore!.collection('attendance').add(rec.toMap());
          }
        }
      } catch (_) {}

      final existingIndex = _attendance.indexWhere(
        (a) => a.studentId == rec.studentId && a.subjectId == rec.subjectId && a.date == rec.date,
      );
      if (existingIndex >= 0) {
        _attendance[existingIndex] = rec;
      } else {
        _attendance.add(rec);
      }
    }
    _attendanceStreamCtrl.add(List.unmodifiable(_attendance));
  }

  // ==================== MARKS ====================
  Stream<List<MarksModel>> streamMarks() {
    try {
      if (_firestore != null) {
        return _firestore!.collection('marks').snapshots().map((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            final list = snapshot.docs.map((doc) => MarksModel.fromMap(doc.data(), doc.id)).toList();
            _marks.clear();
            _marks.addAll(list);
            return list;
          }
          return _marks;
        }).handleError((_) => _marks);
      }
    } catch (_) {}
    return _marksStreamCtrl.stream;
  }

  List<MarksModel> get currentMarks => List.unmodifiable(_marks);

  Future<void> saveMark(MarksModel mark) async {
    try {
      if (_firestore != null) {
        final q = await _firestore!.collection('marks')
            .where('studentId', isEqualTo: mark.studentId)
            .where('subjectId', isEqualTo: mark.subjectId)
            .where('semester', isEqualTo: mark.semester)
            .limit(1)
            .get();
        if (q.docs.isNotEmpty) {
          await q.docs.first.reference.update(mark.toMap());
        } else {
          await _firestore!.collection('marks').add(mark.toMap());
        }
      }
    } catch (_) {}

    final index = _marks.indexWhere(
      (m) => m.studentId == mark.studentId && m.subjectId == mark.subjectId && m.semester == mark.semester,
    );
    if (index >= 0) {
      _marks[index] = mark;
    } else {
      _marks.add(mark);
    }
    _marksStreamCtrl.add(List.unmodifiable(_marks));
  }

  // ==================== TIMETABLE ====================
  Stream<List<TimetableModel>> streamTimetable() {
    try {
      if (_firestore != null) {
        return _firestore!.collection('timetable').snapshots().map((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            final list = snapshot.docs.map((doc) => TimetableModel.fromMap(doc.data(), doc.id)).toList();
            _timetable.clear();
            _timetable.addAll(list);
            return list;
          }
          return _timetable;
        }).handleError((_) => _timetable);
      }
    } catch (_) {}
    return _timetableStreamCtrl.stream;
  }

  List<TimetableModel> get currentTimetable => List.unmodifiable(_timetable);

  Future<void> addTimetableSlot(TimetableModel slot) async {
    try {
      if (_firestore != null) {
        final ref = await _firestore!.collection('timetable').add(slot.toMap());
        final withId = TimetableModel.fromMap(slot.toMap(), ref.id);
        _timetable.add(withId);
        _timetableStreamCtrl.add(List.unmodifiable(_timetable));
        return;
      }
    } catch (_) {}

    final localId = 'tt_${DateTime.now().millisecondsSinceEpoch}';
    final created = TimetableModel.fromMap(slot.toMap(), localId);
    _timetable.add(created);
    _timetableStreamCtrl.add(List.unmodifiable(_timetable));
  }

  Future<void> deleteTimetableSlot(String id) async {
    try {
      if (_firestore != null) {
        await _firestore!.collection('timetable').doc(id).delete();
      }
    } catch (_) {}

    _timetable.removeWhere((t) => t.id == id);
    _timetableStreamCtrl.add(List.unmodifiable(_timetable));
  }

  // ==================== ANNOUNCEMENTS ====================
  Stream<List<AnnouncementModel>> streamAnnouncements() {
    try {
      if (_firestore != null) {
        return _firestore!.collection('announcements').snapshots().map((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            final list = snapshot.docs.map((doc) => AnnouncementModel.fromMap(doc.data(), doc.id)).toList();
            _announcements.clear();
            _announcements.addAll(list);
            return list;
          }
          return _announcements;
        }).handleError((_) => _announcements);
      }
    } catch (_) {}
    return _announcementStreamCtrl.stream;
  }

  List<AnnouncementModel> get currentAnnouncements => List.unmodifiable(_announcements);

  Future<void> addAnnouncement(AnnouncementModel ann) async {
    try {
      if (_firestore != null) {
        final ref = await _firestore!.collection('announcements').add(ann.toMap());
        final withId = AnnouncementModel.fromMap(ann.toMap(), ref.id);
        _announcements.insert(0, withId);
        _announcementStreamCtrl.add(List.unmodifiable(_announcements));
        return;
      }
    } catch (_) {}

    final localId = 'ann_${DateTime.now().millisecondsSinceEpoch}';
    final created = AnnouncementModel.fromMap(ann.toMap(), localId);
    _announcements.insert(0, created);
    _announcementStreamCtrl.add(List.unmodifiable(_announcements));
  }

  Future<void> deleteAnnouncement(String id) async {
    try {
      if (_firestore != null) {
        await _firestore!.collection('announcements').doc(id).delete();
      }
    } catch (_) {}

    _announcements.removeWhere((a) => a.id == id);
    _announcementStreamCtrl.add(List.unmodifiable(_announcements));
  }

  // Seed sample data directly into Firestore
  Future<bool> seedFirestore() async {
    try {
      if (_firestore == null) return false;
      final batch = _firestore!.batch();

      for (final d in MockDataSeeder.initialDepartments) {
        batch.set(_firestore!.collection('departments').doc(d.id), d.toMap());
      }
      for (final c in MockDataSeeder.initialCourses) {
        batch.set(_firestore!.collection('courses').doc(c.id), c.toMap());
      }
      for (final s in MockDataSeeder.initialSubjects) {
        batch.set(_firestore!.collection('subjects').doc(s.id), s.toMap());
      }
      for (final f in MockDataSeeder.initialFaculty) {
        batch.set(_firestore!.collection('faculty').doc(f.id), f.toMap());
      }
      for (final st in MockDataSeeder.initialStudents) {
        batch.set(_firestore!.collection('students').doc(st.id), st.toMap());
      }
      for (final a in MockDataSeeder.initialAttendance) {
        batch.set(_firestore!.collection('attendance').doc(a.id), a.toMap());
      }
      for (final m in MockDataSeeder.initialMarks) {
        batch.set(_firestore!.collection('marks').doc(m.id), m.toMap());
      }
      for (final t in MockDataSeeder.initialTimetable) {
        batch.set(_firestore!.collection('timetable').doc(t.id), t.toMap());
      }
      for (final an in MockDataSeeder.initialAnnouncements) {
        batch.set(_firestore!.collection('announcements').doc(an.id), an.toMap());
      }

      await batch.commit();
      return true;
    } catch (_) {
      return false;
    }
  }
}
