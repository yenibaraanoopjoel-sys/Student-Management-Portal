# 🎓 Student Management Portal — Apex University

A modern, responsive, enterprise-grade **Student & Academic Management ERP** built with **Flutter** and powered by **Firebase**.

Designed for seamless administration, faculty workflows, and student engagement across Web, Desktop, and Mobile.

---

## 🌐 Live Deployment

- **🚀 Live Web Application**: [https://student-management-porta-932f1.web.app](https://student-management-porta-932f1.web.app)
- **🔥 Firebase Project Console**: [https://console.firebase.google.com/project/student-management-porta-932f1/overview](https://console.firebase.google.com/project/student-management-porta-932f1/overview)

---

## 🔑 Demo Quick-Login Credentials

The portal features instant **Demo Quick Login** chips on the login screen for testing each role with one click:

| Role | Email | Password | Primary Capabilities |
| :--- | :--- | :--- | :--- |
| **👑 Administrator** | `admin@portal.edu` | `admin123` | Institute analytics, student & faculty directories, courses, subjects, announcements, academic reports, Cloud Firestore synchronization |
| **👨‍🏫 Faculty** | `faculty@portal.edu` | `faculty123` | Daily schedule, lecture attendance marking, examination grades & GPA entry, faculty timetable, personal profile |
| **🎓 Student** | `student@portal.edu` | `student123` | Real-time attendance percentage & status, exam marks & grades breakdown, daily lecture schedule, student profile |

---

## ✨ Features by Role

### 👑 Administrator Portal
- **Executive Analytics Dashboard**: Real-time KPI statistics (Total Students, Active Faculty, Degree Programs, Average Attendance).
- **Student Directory Management**: Search, filter by department/course/semester, add new students, edit profiles, view comprehensive academic dossiers, and delete records.
- **Faculty Directory**: Manage faculty members, department assignments, designations, and contact profiles.
- **Academic Programs & Departments**: Manage undergraduate and postgraduate degree courses, duration, and academic departments.
- **Curriculum & Subjects**: Manage course modules, credit allocations, semesters, and assign faculty instructors.
- **Campus Announcements**: Publish notices with target audiences (*All, Students, Faculty*) and priority badges (*High, Medium, Normal*).
- **Academic Records & Reports**: Visual grade distributions, performance trends, and attendance summaries.
- **Cloud Firestore Synchronization**: One-click sync button in the dashboard to synchronize initial demonstration datasets directly to Cloud Firestore.

### 👨‍🏫 Faculty Portal
- **Faculty Dashboard**: Overview of assigned subjects, total students taught, today's lecture schedule, and pending tasks.
- **Mark Attendance**: Interactive attendance register with single-click Present / Absent / Late toggles, quick "Mark All Present" batch action, and real-time persistence.
- **Marks & Examination Grading**: Input marks for Internal Assessments, Midterms, and Final Examinations with automated percentage and letter-grade computation.
- **Weekly Timetable**: Interactive schedule grid covering periods and assigned classroom venues.
- **Faculty Profile**: Departmental information, specializations, office hours, and contact details.

### 🎓 Student Portal
- **Student Dashboard**: Overall attendance percentage meter with status alerts (*Safe ≥75%*, *Warning 65–75%*, *Low <65%*), current CGPA, upcoming lectures, and campus notices.
- **Attendance Breakdown**: Subject-wise breakdown of attended versus conducted sessions with progress indicators.
- **My Marks & Grades**: Comprehensive report card showing scores across subjects, assessments, max marks, and letter grades.
- **Student Dossier**: Enrollment details, roll number, course, semester, department, and contact information.

---

## 🛠️ Technology Stack

- **Frontend / Cross-Platform**: [Flutter](https://flutter.dev/) (Channel Stable, Flutter 3.47+) & [Dart](https://dart.dev/) (SDK 3.13+)
- **Backend / Cloud**: [Firebase](https://firebase.google.com/)
  - **Firebase Authentication**: Secure user credentials & session management
  - **Cloud Firestore**: Real-time NoSQL cloud database with declarative security rules
  - **Firebase Hosting**: High-performance global CDN delivery with SSL
- **State Management**: [Provider](https://pub.dev/packages/provider) architecture with reactive stream controllers
- **Data Visualization**: [FL Chart](https://pub.dev/packages/fl_chart) for academic charts & performance graphs
- **Design System & Typography**: Google Fonts (*Inter* & *Outfit*), Material 3 styling, and fully responsive adaptive layouts

---

## 📁 Project Architecture

```
lib/
├── core/
│   ├── constants/       # Color palettes, theme tokens, and typography
│   ├── theme/           # Material 3 light theme and card theme configurations
│   └── utils/           # Input validation rules and formatting helpers
├── models/              # Immutable data models (User, Student, Faculty, Course, Attendance, Marks, Timetable, Announcement)
├── providers/           # ChangeNotifier state providers (Auth, Student, Faculty, Attendance, Marks, Academic)
├── screens/
│   ├── admin/           # Admin dashboard, students, faculty, courses, subjects, announcements, reports
│   ├── auth/            # Sign-in portal with quick demo access chips and password reset
│   ├── faculty/         # Faculty dashboard, attendance entry, marks entry, timetable, profile
│   └── student/         # Student dashboard, attendance view, marks view, profile
├── services/            # Firebase Auth & Cloud Firestore services with offline/local fallback stores
└── widgets/             # Reusable UI components (StatCards, ResponsivePortalLayout, CustomButtons, Badges)
```

---

## 🚀 Local Development Setup

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed and added to `PATH`
- [Firebase CLI](https://firebase.google.com/docs/cli) installed (`npm install -g firebase-tools`)

### Clone & Run

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yenibaraanoopjoel-sys/Student-Management-Portal.git
   cd Student-Management-Portal
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run locally on Chrome / Web:**
   ```bash
   flutter run -d chrome
   ```

4. **Run on Android / Windows / Desktop:**
   ```bash
   flutter run
   ```

---

## 📦 Building & Deploying to Firebase

1. **Build the production Web bundle:**
   ```bash
   flutter build web --release
   ```

2. **Deploy to Firebase Hosting and Firestore:**
   ```bash
   firebase deploy --only hosting,firestore
   ```

---

## 📄 License

This project is licensed under the MIT License.
