import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/responsive_layout.dart';
import 'admin_dashboard_tab.dart';
import 'students_management_screen.dart';
import 'faculty_management_screen.dart';
import 'courses_departments_screen.dart';
import 'subjects_management_screen.dart';
import 'announcements_management_screen.dart';
import 'admin_reports_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _currentIndex = 0;

  final List<NavItem> _navItems = const [
    NavItem(title: 'Dashboard', icon: Icons.dashboard_outlined, selectedIcon: Icons.dashboard_rounded, index: 0),
    NavItem(title: 'Students', icon: Icons.people_outline_rounded, selectedIcon: Icons.people_alt_rounded, index: 1),
    NavItem(title: 'Faculty', icon: Icons.badge_outlined, selectedIcon: Icons.badge_rounded, index: 2),
    NavItem(title: 'Courses & Depts', icon: Icons.school_outlined, selectedIcon: Icons.school_rounded, index: 3),
    NavItem(title: 'Subjects', icon: Icons.menu_book_outlined, selectedIcon: Icons.menu_book_rounded, index: 4),
    NavItem(title: 'Announcements', icon: Icons.campaign_outlined, selectedIcon: Icons.campaign_rounded, index: 5),
    NavItem(title: 'Academic Records', icon: Icons.assessment_outlined, selectedIcon: Icons.assessment_rounded, index: 6),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    Widget body;
    switch (_currentIndex) {
      case 0:
        body = AdminDashboardTab(onNavigateToTab: (idx) => setState(() => _currentIndex = idx));
        break;
      case 1:
        body = const StudentsManagementScreen();
        break;
      case 2:
        body = const FacultyManagementScreen();
        break;
      case 3:
        body = const CoursesDepartmentsScreen();
        break;
      case 4:
        body = const SubjectsManagementScreen();
        break;
      case 5:
        body = const AnnouncementsManagementScreen();
        break;
      case 6:
        body = const AdminReportsScreen();
        break;
      default:
        body = AdminDashboardTab(onNavigateToTab: (idx) => setState(() => _currentIndex = idx));
    }

    return ResponsivePortalLayout(
      portalTitle: 'Apex University Portal',
      roleBadge: 'Administrator',
      userName: user?.name ?? 'Admin',
      userEmail: user?.email ?? 'admin@portal.edu',
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
