// Firebase configuration for the web app registered in the Firebase project.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => web;

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB-818_4MtmcxngOCeeBEpOk1EQBuVs6F0',
    appId: '1:678763751841:web:4aeb3d2b1b9dc253a803e0',
    messagingSenderId: '678763751841',
    projectId: 'flutterexperiment7-yb26',
    authDomain: 'flutterexperiment7-yb26.firebaseapp.com',
    storageBucket: 'flutterexperiment7-yb26.firebasestorage.app',
  );
}
