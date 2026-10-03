import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/marks_provider.dart';
import '../../providers/academic_provider.dart';
import '../../widgets/app_badge.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final attendance = context.watch<AttendanceProvider>();
    final marks = context.watch<MarksProvider>();
    final academic = context.watch<AcademicProvider>();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            controller: _tabCtrl,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'Attendance Log (${attendance.allAttendance.length})'),
              Tab(text: 'Marks & Results Registry (${marks.allMarks.length})'),
              Tab(text: 'Master Timetable (${academic.timetables.length})'),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                // Attendance Registry
                Card(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SingleChildScrollView(
                      child: DataTable(
                        columnSpacing: 24,
                        headingRowColor: WidgetStateProperty.all(AppColors.surfaceMuted),
                        columns: const [
                          DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Student', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Roll No.', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Subject', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: attendance.allAttendance.map((a) {
                          return DataRow(
                            cells: [
                              DataCell(Text(a.date, style: const TextStyle(fontWeight: FontWeight.w500))),
                              DataCell(Text(a.studentName, style: const TextStyle(fontWeight: FontWeight.w600))),
                              DataCell(Text(a.studentRoll)),
                              DataCell(Text(a.subjectName)),
                              DataCell(AppBadge.status(a.status)),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),

                // Marks Registry
                Card(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SingleChildScrollView(
                      child: DataTable(
                        columnSpacing: 20,
                        headingRowColor: WidgetStateProperty.all(AppColors.surfaceMuted),
                        columns: const [
                          DataColumn(label: Text('Student', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Subject', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Internal (20)', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Assignment (10)', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Exam (70)', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Grade', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: marks.allMarks.map((m) {
                          return DataRow(
                            cells: [
                              DataCell(Text('${m.studentName} (${m.studentRoll})', style: const TextStyle(fontWeight: FontWeight.w600))),
                              DataCell(Text(m.subjectName)),
                              DataCell(Text(m.internalMarks.toStringAsFixed(1))),
                              DataCell(Text(m.assignmentMarks.toStringAsFixed(1))),
                              DataCell(Text(m.examMarks.toStringAsFixed(1))),
                              DataCell(Text(m.totalMarks.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold))),
                              DataCell(AppBadge.grade(m.grade)),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),

                // Master Timetable
                Card(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SingleChildScrollView(
                      child: DataTable(
                        columnSpacing: 24,
                        headingRowColor: WidgetStateProperty.all(AppColors.surfaceMuted),
                        columns: const [
                          DataColumn(label: Text('Day', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Time', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Subject', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Faculty', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Room / Section', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: academic.timetables.map((t) {
                          return DataRow(
                            cells: [
                              DataCell(Text(t.day, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))),
                              DataCell(Text(t.timeSlot)),
                              DataCell(Text(t.subjectName, style: const TextStyle(fontWeight: FontWeight.w600))),
                              DataCell(Text(t.facultyName)),
                              DataCell(Text('${t.room} • Sec ${t.section}')),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
