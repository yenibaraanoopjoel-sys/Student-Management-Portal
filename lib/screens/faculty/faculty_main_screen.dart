import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/responsive_layout.dart';
import 'faculty_dashboard_tab.dart';
import 'mark_attendance_screen.dart';
import 'enter_marks_screen.dart';
import 'faculty_timetable_screen.dart';
import 'faculty_profile_screen.dart';

class FacultyMainScreen extends StatefulWidget {
  const FacultyMainScreen({super.key});

  @override
  State<FacultyMainScreen> createState() => _FacultyMainScreenState();
}

class _FacultyMainScreenState extends State<FacultyMainScreen> {
  int _currentIndex = 0;

  final List<NavItem> _navItems = const [
    NavItem(title: 'Dashboard', icon: Icons.dashboard_outlined, selectedIcon: Icons.dashboard_rounded, index: 0),
    NavItem(title: 'Attendance', icon: Icons.how_to_reg_outlined, selectedIcon: Icons.how_to_reg_rounded, index: 1),
    NavItem(title: 'Marks & Results', icon: Icons.grade_outlined, selectedIcon: Icons.grade_rounded, index: 2),
    NavItem(title: 'My Timetable', icon: Icons.calendar_today_outlined, selectedIcon: Icons.calendar_today_rounded, index: 3),
    NavItem(title: 'Faculty Profile', icon: Icons.person_outline_rounded, selectedIcon: Icons.person_rounded, index: 4),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    Widget body;
    switch (_currentIndex) {
      case 0:
        body = FacultyDashboardTab(onNavigateToTab: (idx) => setState(() => _currentIndex = idx));
        break;
      case 1:
        body = const MarkAttendanceScreen();
        break;
      case 2:
        body = const EnterMarksScreen();
        break;
      case 3:
        body = const FacultyTimetableScreen();
        break;
      case 4:
        body = const FacultyProfileScreen();
        break;
      default:
        body = FacultyDashboardTab(onNavigateToTab: (idx) => setState(() => _currentIndex = idx));
    }

    return ResponsivePortalLayout(
      portalTitle: 'Faculty Portal',
      roleBadge: 'Faculty Member',
      userName: user?.name ?? 'Faculty Member',
      userEmail: user?.email ?? 'faculty@portal.edu',
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
