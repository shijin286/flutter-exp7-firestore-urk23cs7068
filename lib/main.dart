// Experiment 7: Data Persistence using Google Cloud Firestore
// Stores and retrieves student information in a Firestore collection.
// Data lives in the cloud, so it is still there after the app is closed
// and reopened.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const StudentApp());
}

// App colour palette
const kPrimary = Color(0xFFDC2626); // red
const kSecondary = Color(0xFF9F1239); // deep rose
const kAccent = Color(0xFFF97316); // orange
const kBackground = Color(0xFFFFF5F5);

const kHeaderGradient = LinearGradient(
  colors: [kPrimary, kSecondary],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// Distinct colour per department for avatars and chips
const _deptColors = [
  Color(0xFFDC2626),
  Color(0xFFBE123C),
  Color(0xFFEA580C),
  Color(0xFFB91C1C),
  Color(0xFFDB2777),
  Color(0xFF9A3412),
];

Color deptColor(String dept) =>
    _deptColors[dept.toUpperCase().hashCode.abs() % _deptColors.length];

class StudentApp extends StatelessWidget {
  const StudentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Records - Firestore',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimary,
          primary: kPrimary,
          secondary: kSecondary,
        ),
        scaffoldBackgroundColor: kBackground,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: kPrimary, width: 2),
          ),
        ),
      ),
      home: const StudentListPage(),
    );
  }
}

/// Model class for a student record.
class Student {
  final String? id;
  final String name;
  final String regNo;
  final String department;
  final String email;
  final String phone;

  Student({
    this.id,
    required this.name,
    required this.regNo,
    required this.department,
    required this.email,
    required this.phone,
  });

  factory Student.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Student(
      id: doc.id,
      name: data['name'] ?? '',
      regNo: data['regNo'] ?? '',
      department: data['department'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'regNo': regNo,
        'department': department,
        'email': email,
        'phone': phone,
        'updatedAt': FieldValue.serverTimestamp(),
      };
}

/// All Firestore operations (CRUD) for the "students" collection.
class StudentService {
  final CollectionReference<Map<String, dynamic>> _students =
      FirebaseFirestore.instance.collection('students');

  Stream<List<Student>> getStudents() {
    return _students
        .orderBy('regNo')
        .snapshots()
        .map((snap) => snap.docs.map(Student.fromDoc).toList());
  }

  Future<void> addStudent(Student s) => _students.add(s.toMap());

  Future<void> updateStudent(Student s) =>
      _students.doc(s.id).update(s.toMap());

  Future<void> deleteStudent(String id) => _students.doc(id).delete();
}

/// Gradient app bar used on every page.
PreferredSizeWidget gradientAppBar(String title, {String? subtitle}) {
  return AppBar(
    toolbarHeight: subtitle == null ? 64 : 76,
    foregroundColor: Colors.white,
    flexibleSpace: Container(
        decoration: const BoxDecoration(gradient: kHeaderGradient)),
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 21)),
        if (subtitle != null)
          Text(subtitle,
              style: const TextStyle(fontSize: 13, color: Colors.white70)),
      ],
    ),
  );
}

class StudentListPage extends StatelessWidget {
  const StudentListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = StudentService();
    return Scaffold(
      appBar: gradientAppBar('Student Records',
          subtitle: 'Cloud Firestore  •  Data Persistence'),
      body: StreamBuilder<List<Student>>(
        stream: service.getStudents(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final students = snapshot.data!;
          final departments = students.map((s) => s.department).toSet();
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.groups_rounded,
                          label: 'Total Students',
                          value: '${students.length}',
                          colors: const [kPrimary, Color(0xFFEF4444)],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.apartment_rounded,
                          label: 'Departments',
                          value: '${departments.length}',
                          colors: const [kSecondary, Color(0xFFE11D48)],
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: _StatCard(
                          icon: Icons.cloud_done_rounded,
                          label: 'Storage',
                          value: 'Firestore',
                          colors: [kAccent, Color(0xFFFB923C)],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('All Records',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF7F1D1D))),
                  const SizedBox(height: 8),
                  if (students.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(40),
                      child: Text('No records yet.\nTap "Add Student" to begin.',
                          textAlign: TextAlign.center),
                    ),
                  for (final s in students)
                    _StudentCard(student: s, service: service),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: _GradientButton(
        icon: Icons.person_add_alt_1_rounded,
        label: 'Add Student',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const StudentFormPage()),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final List<Color> colors;

  const _StatCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: colors.first.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 10),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  final Student student;
  final StudentService service;

  const _StudentCard({required this.student, required this.service});

  @override
  Widget build(BuildContext context) {
    final s = student;
    final color = deptColor(s.department);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: color, width: 5)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: color,
              child: Text(
                s.name.isNotEmpty ? s.name[0].toUpperCase() : '?',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(s.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(s.department,
                            style: TextStyle(
                                color: color,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(s.regNo,
                      style: const TextStyle(
                          color: kPrimary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 14,
                    children: [
                      _info(Icons.email_outlined, s.email),
                      _info(Icons.phone_outlined, s.phone),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Edit',
              style: IconButton.styleFrom(
                  backgroundColor: kPrimary.withValues(alpha: 0.1)),
              icon: const Icon(Icons.edit_rounded, color: kPrimary),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => StudentFormPage(student: s)),
              ),
            ),
            const SizedBox(width: 6),
            IconButton(
              tooltip: 'Delete',
              style: IconButton.styleFrom(
                  backgroundColor: Colors.red.withValues(alpha: 0.1)),
              icon: const Icon(Icons.delete_rounded, color: Colors.redAccent),
              onPressed: () async {
                await service.deleteStudent(s.id!);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${s.name} deleted')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(IconData icon, String text) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(color: Colors.grey.shade700)),
        ],
      );
}

class _GradientButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _GradientButton({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          gradient: kHeaderGradient,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
                color: kPrimary.withValues(alpha: 0.4),
                blurRadius: 14,
                offset: const Offset(0, 6)),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 10),
                Text(label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StudentFormPage extends StatefulWidget {
  final Student? student;
  const StudentFormPage({super.key, this.student});

  @override
  State<StudentFormPage> createState() => _StudentFormPageState();
}

class _StudentFormPageState extends State<StudentFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _service = StudentService();
  late final TextEditingController _name, _regNo, _dept, _email, _phone;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final s = widget.student;
    _name = TextEditingController(text: s?.name);
    _regNo = TextEditingController(text: s?.regNo);
    _dept = TextEditingController(text: s?.department);
    _email = TextEditingController(text: s?.email);
    _phone = TextEditingController(text: s?.phone);
  }

  @override
  void dispose() {
    for (final c in [_name, _regNo, _dept, _email, _phone]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final student = Student(
      id: widget.student?.id,
      name: _name.text.trim(),
      regNo: _regNo.text.trim(),
      department: _dept.text.trim(),
      email: _email.text.trim(),
      phone: _phone.text.trim(),
    );
    if (widget.student == null) {
      await _service.addStudent(student);
    } else {
      await _service.updateStudent(student);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF059669),
        content: Text('${student.name} saved to Firestore'),
      ),
    );
    Navigator.pop(context);
  }

  Widget _field(TextEditingController c, String label, IconData icon,
      {TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: c,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: kPrimary),
        ),
        validator: (v) =>
            (v == null || v.trim().isEmpty) ? 'Please enter $label' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.student != null;
    return Scaffold(
      appBar: gradientAppBar(editing ? 'Edit Student' : 'Add Student',
          subtitle: 'Details are stored in Cloud Firestore'),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: kPrimary.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8)),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Color(0xFFFFE4E6),
                            child: Icon(Icons.badge_rounded, color: kSecondary),
                          ),
                          SizedBox(width: 12),
                          Text('Student Information',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _field(_name, 'Name', Icons.person_rounded),
                      _field(_regNo, 'Register Number', Icons.numbers_rounded),
                      _field(_dept, 'Department', Icons.school_rounded),
                      _field(_email, 'Email', Icons.email_rounded,
                          type: TextInputType.emailAddress),
                      _field(_phone, 'Phone', Icons.phone_rounded,
                          type: TextInputType.phone),
                      const SizedBox(height: 8),
                      Align(
                        child: _GradientButton(
                          icon: Icons.cloud_upload_rounded,
                          label: _saving
                              ? 'Saving...'
                              : (editing ? 'Update Record' : 'Save to Firestore'),
                          onTap: _saving ? null : _save,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
