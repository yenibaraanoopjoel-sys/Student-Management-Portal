// File generated for student-management-porta-932f1
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyABD5p4i_rouGd_9rZBaD7wAkJUDqL9lb0',
    appId: '1:298731468271:web:fa7c5f54357319211ab21a',
    messagingSenderId: '298731468271',
    projectId: 'student-management-porta-932f1',
    authDomain: 'student-management-porta-932f1.firebaseapp.com',
    storageBucket: 'student-management-porta-932f1.firebasestorage.app',
    measurementId: 'G-T95QQNXL9L',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBXub1Uzsn5dx5NZiIEHJF2X00zGhAkAbo',
    appId: '1:298731468271:android:37a4d6d49ad38be81ab21a',
    messagingSenderId: '298731468271',
    projectId: 'student-management-porta-932f1',
    storageBucket: 'student-management-porta-932f1.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyABD5p4i_rouGd_9rZBaD7wAkJUDqL9lb0',
    appId: '1:298731468271:web:fa7c5f54357319211ab21a',
    messagingSenderId: '298731468271',
    projectId: 'student-management-porta-932f1',
    authDomain: 'student-management-porta-932f1.firebaseapp.com',
    storageBucket: 'student-management-porta-932f1.firebasestorage.app',
    measurementId: 'G-T95QQNXL9L',
  );
}
