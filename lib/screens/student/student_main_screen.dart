import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/responsive_layout.dart';
import 'student_dashboard_tab.dart';
import 'student_attendance_screen.dart';
import 'student_marks_screen.dart';
import 'student_profile_screen.dart';

class StudentMainScreen extends StatefulWidget {
  const StudentMainScreen({super.key});

  @override
  State<StudentMainScreen> createState() => _StudentMainScreenState();
}

class _StudentMainScreenState extends State<StudentMainScreen> {
  int _currentIndex = 0;

  final List<NavItem> _navItems = const [
    NavItem(title: 'Dashboard', icon: Icons.dashboard_outlined, selectedIcon: Icons.dashboard_rounded, index: 0),
    NavItem(title: 'Attendance', icon: Icons.fact_check_outlined, selectedIcon: Icons.fact_check_rounded, index: 1),
    NavItem(title: 'My Marks', icon: Icons.grade_outlined, selectedIcon: Icons.grade_rounded, index: 2),
    NavItem(title: 'My Profile', icon: Icons.person_outline_rounded, selectedIcon: Icons.person_rounded, index: 3),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    Widget body;
    switch (_currentIndex) {
      case 0:
        body = StudentDashboardTab(onNavigateToTab: (idx) => setState(() => _currentIndex = idx));
        break;
      case 1:
        body = const StudentAttendanceScreen();
        break;
      case 2:
        body = const StudentMarksScreen();
        break;
      case 3:
        body = const StudentProfileScreen();
        break;
      default:
        body = StudentDashboardTab(onNavigateToTab: (idx) => setState(() => _currentIndex = idx));
    }

    return ResponsivePortalLayout(
      portalTitle: 'Student Portal',
      roleBadge: 'Student',
      userName: user?.name ?? 'Student',
      userEmail: user?.email ?? 'student@portal.edu',
      navItems: _navItems,
      currentIndex: _currentIndex,
      onNavItemSelected: (index) => setState(() => _currentIndex = index),
      onLogout: () async {
        await auth.signOut();
      },
      body: body,
    );
  }
}
