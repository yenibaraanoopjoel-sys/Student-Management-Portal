import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/marks_model.dart';
import '../../models/student_model.dart';
import '../../providers/academic_provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/marks_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_badge.dart';

class EnterMarksScreen extends StatefulWidget {
  const EnterMarksScreen({super.key});

  @override
  State<EnterMarksScreen> createState() => _EnterMarksScreenState();
}

class _EnterMarksScreenState extends State<EnterMarksScreen> {
  String? _selectedSubjectId;
  String _selectedSemester = '5';

  final Map<String, TextEditingController> _internalCtrls = {};
  final Map<String, TextEditingController> _assignCtrls = {};
  final Map<String, TextEditingController> _examCtrls = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final academic = Provider.of<AcademicProvider>(context, listen: false);
      if (academic.subjects.isNotEmpty) {
        setState(() {
          _selectedSubjectId = academic.subjects.first.id;
        });
      }
    });
  }

  @override
  void dispose() {
    for (final c in _internalCtrls.values) {
      c.dispose();
    }
    for (final c in _assignCtrls.values) {
      c.dispose();
    }
    for (final c in _examCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _initStudentControllers(StudentModel st, MarksProvider marksProvider) {
    if (_internalCtrls.containsKey(st.id)) return;

    final existing = marksProvider.allMarks.cast<MarksModel?>().firstWhere(
      (m) => m?.studentId == st.id && m?.subjectId == _selectedSubjectId,
      orElse: () => null,
    );

    _internalCtrls[st.id] = TextEditingController(text: existing != null ? existing.internalMarks.toStringAsFixed(0) : '18');
    _assignCtrls[st.id] = TextEditingController(text: existing != null ? existing.assignmentMarks.toStringAsFixed(0) : '9');
    _examCtrls[st.id] = TextEditingController(text: existing != null ? existing.examMarks.toStringAsFixed(0) : '60');
  }

  Future<void> _saveStudentMark(StudentModel st) async {
    if (_selectedSubjectId == null) return;
    final academic = Provider.of<AcademicProvider>(context, listen: false);
    final marksProvider = Provider.of<MarksProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    final sub = academic.subjects.firstWhere((s) => s.id == _selectedSubjectId);

    final internal = double.tryParse(_internalCtrls[st.id]?.text.trim() ?? '0') ?? 0.0;
    final assignment = double.tryParse(_assignCtrls[st.id]?.text.trim() ?? '0') ?? 0.0;
    final exam = double.tryParse(_examCtrls[st.id]?.text.trim() ?? '0') ?? 0.0;
    final total = internal + assignment + exam;
    final grade = MarksModel.calculateGrade(total);

    final markModel = MarksModel(
      id: '',
      studentId: st.id,
      studentRoll: st.studentId,
      studentName: st.fullName,
      subjectId: sub.id,
      subjectName: sub.subjectName,
      facultyId: auth.user?.uid ?? 'fac_2',
      internalMarks: internal,
      assignmentMarks: assignment,
      examMarks: exam,
      totalMarks: total,
      grade: grade,
      semester: _selectedSemester,
    );

    await marksProvider.saveMarks(markModel);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Marks saved for ${st.fullName}: $total/100 (Grade $grade)'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final academic = context.watch<AcademicProvider>();
    final studentProvider = context.watch<StudentProvider>();
    final marksProvider = context.watch<MarksProvider>();
    final students = studentProvider.allStudents;

    for (final st in students) {
      _initStudentControllers(st, marksProvider);
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Filter card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Select Subject *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: _selectedSubjectId,
                          items: academic.subjects.map((s) {
                            return DropdownMenuItem(value: s.id, child: Text('${s.subjectName} (${s.subjectCode})'));
                          }).toList(),
                          onChanged: (v) => setState(() => _selectedSubjectId = v),
                          decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Semester', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: _selectedSemester,
                          items: ['1', '2', '3', '4', '5', '6', '7', '8'].map((sm) => DropdownMenuItem(value: sm, child: Text('Semester $sm'))).toList(),
                          onChanged: (v) => setState(() => _selectedSemester = v ?? '5'),
                          decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Marks Input Table
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Student Examination Scores & Grades', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.separated(
                        itemCount: students.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, idx) {
                          final st = students[idx];
                          final intCtrl = _internalCtrls[st.id]!;
                          final assCtrl = _assignCtrls[st.id]!;
                          final exmCtrl = _examCtrls[st.id]!;

                          final internal = double.tryParse(intCtrl.text) ?? 0;
                          final assign = double.tryParse(assCtrl.text) ?? 0;
                          final exam = double.tryParse(exmCtrl.text) ?? 0;
                          final total = internal + assign + exam;
                          final grade = MarksModel.calculateGrade(total);

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: AppColors.secondary.withOpacity(0.15),
                                  child: Text(
                                    st.fullName[0].toUpperCase(),
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(st.fullName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                      Text(st.studentId, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Internal
                                SizedBox(
                                  width: 80,
                                  child: TextFormField(
                                    controller: intCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Int (20)',
                                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    ),
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                // Assignment
                                SizedBox(
                                  width: 80,
                                  child: TextFormField(
                                    controller: assCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Ass (10)',
                                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    ),
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                // Exam
                                SizedBox(
                                  width: 85,
                                  child: TextFormField(
                                    controller: exmCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Exam (70)',
                                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    ),
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                // Total & Grade
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Total: ${total.toStringAsFixed(0)}/100', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    const SizedBox(height: 2),
                                    AppBadge.grade(grade),
                                  ],
                                ),
                                const SizedBox(width: 14),
                                IconButton(
                                  icon: const Icon(Icons.check_circle_rounded, color: AppColors.success),
                                  tooltip: 'Save Mark',
                                  onPressed: () => _saveStudentMark(st),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
