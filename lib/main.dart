import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/student_provider.dart';
import 'providers/faculty_provider.dart';
import 'providers/attendance_provider.dart';
import 'providers/marks_provider.dart';
import 'providers/academic_provider.dart';

import 'screens/auth/login_screen.dart';
import 'screens/admin/admin_main_screen.dart';
import 'screens/faculty/faculty_main_screen.dart';
import 'screens/student/student_main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Firebase may already be initialized
    debugPrint('Firebase init: $e');
  }
  runApp(const StudentManagementApp());
}

class StudentManagementApp extends StatelessWidget {
  const StudentManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StudentProvider()),
        ChangeNotifierProvider(create: (_) => FacultyProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => MarksProvider()),
        ChangeNotifierProvider(create: (_) => AcademicProvider()),
      ],
      child: MaterialApp(
        title: 'Student Management Portal',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AppRouter(),
      ),
    );
  }
}

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // Show loading while checking auth state
    if (auth.isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading Student Management Portal...'),
            ],
          ),
        ),
      );
    }

    // Not logged in – show login screen
    if (!auth.isAuthenticated) {
      return const LoginScreen();
    }

    // Route by role
    if (auth.isAdmin) {
      return const _DataInitWrapper(child: AdminMainScreen());
    } else if (auth.isFaculty) {
      return const _DataInitWrapper(child: FacultyMainScreen());
    } else {
      return const _DataInitWrapper(child: StudentMainScreen());
    }
  }
}

/// Wrapper that ensures all data providers are initialized when a user logs in.
/// Providers auto-load via Firestore streams in their constructors.
class _DataInitWrapper extends StatelessWidget {
  final Widget child;
  const _DataInitWrapper({required this.child});

  @override
  Widget build(BuildContext context) => child;
}
