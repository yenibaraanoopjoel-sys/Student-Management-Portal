import 'dart:async';
import 'package:flutter/material.dart';
import '../models/marks_model.dart';
import '../services/firestore_service.dart';

class MarksProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();
  StreamSubscription? _sub;

  List<MarksModel> _marks = [];
  bool _isLoading = false;

  List<MarksModel> get allMarks => _marks;
  bool get isLoading => _isLoading;

  MarksProvider() {
    _marks = _service.currentMarks;
    _sub = _service.streamMarks().listen((list) {
      _marks = list;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  List<MarksModel> getMarksForStudent(String studentIdOrRoll) {
    return _marks.where((m) =>
      m.studentId == studentIdOrRoll || m.studentRoll == studentIdOrRoll
    ).toList();
  }

  double calculateGpa(String studentIdOrRoll) {
    final list = getMarksForStudent(studentIdOrRoll);
    if (list.isEmpty) return 9.2; // Baseline
    double totalPoints = 0;
    for (final m in list) {
      if (m.grade == 'O') {
        totalPoints += 10.0;
      } else if (m.grade == 'A+') {
        totalPoints += 9.0;
      } else if (m.grade == 'A') {
        totalPoints += 8.0;
      } else if (m.grade == 'B+') {
        totalPoints += 7.0;
      } else if (m.grade == 'B') {
        totalPoints += 6.0;
      } else if (m.grade == 'C') {
        totalPoints += 5.0;
      } else {
        totalPoints += 0.0;
      }
    }
    return double.parse((totalPoints / list.length).toStringAsFixed(2));
  }

  Future<void> saveMarks(MarksModel mark) async {
    _isLoading = true;
    notifyListeners();
    await _service.saveMark(mark);
    _isLoading = false;
    notifyListeners();
  }
}
