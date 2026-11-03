# Experiment 7: Data Persistence using Google Cloud Firestore

**24CS2016 - Building Applications using Flutter**
**Reg. No:** URK23CS7068

A Flutter application that stores and retrieves student information using
Google Cloud Firestore. Records are kept in the cloud, so they are still
available after the application is closed and reopened.

## Features
- Add, view, edit and delete student records (name, register number,
  department, email, phone)
- Real-time list using a Firestore `snapshots()` stream
- Summary cards for total students and departments
- Form validation for every field

## Firestore structure
```
students (collection)
 └── <auto-id> (document)
      ├── name
      ├── regNo
      ├── department
      ├── email
      ├── phone
      └── updatedAt (server timestamp)
```

## Run
```bash
flutter pub get
flutter run -d chrome
```
