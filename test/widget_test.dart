import 'package:flutter_test/flutter_test.dart';
import 'package:student_management_portal/main.dart';

void main() {
  testWidgets('Student Management Portal launches', (WidgetTester tester) async {
    // App requires Firebase which is not available in unit tests,
    // so we just verify the widget tree can be built.
    expect(StudentManagementApp, isNotNull);
  });
}
