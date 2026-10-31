import 'package:flutter/material.dart';
import 'database_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SQLite Student App',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const StudentPage(),
    );
  }
}

class StudentPage extends StatefulWidget {
  const StudentPage({super.key});

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  final nameController = TextEditingController();
  final courseController = TextEditingController();

  List<Map<String, dynamic>> students = [];

  @override
  void initState() {
    super.initState();
    loadStudents();
  }

  Future<void> loadStudents() async {
    final data = await DatabaseHelper.instance.getStudents();

    if (!mounted) return;

    setState(() {
      students = data;
    });
  }

  Future<void> addStudent() async {
    if (nameController.text.trim().isEmpty ||
        courseController.text.trim().isEmpty) {
      return;
    }

    await DatabaseHelper.instance.insertStudent({
      'name': nameController.text.trim(),
      'course': courseController.text.trim(),
    });

    nameController.clear();
    courseController.clear();

    await loadStudents();
  }

  Future<void> editStudent(Map<String, dynamic> student) async {
    final nameEdit = TextEditingController(text: student['name']);
    final courseEdit = TextEditingController(text: student['course']);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Student'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameEdit,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: courseEdit,
                decoration: const InputDecoration(labelText: 'Course'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameEdit.text.trim().isEmpty ||
                    courseEdit.text.trim().isEmpty) {
                  return;
                }

                await DatabaseHelper.instance.updateStudent(
                  student['id'],
                  {
                    'name': nameEdit.text.trim(),
                    'course': courseEdit.text.trim(),
                  },
                );

                if (!context.mounted) return;
                Navigator.pop(context);
                await loadStudents();
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );

    nameEdit.dispose();
    courseEdit.dispose();
  }

  Future<void> removeStudent(int id) async {
    await DatabaseHelper.instance.deleteStudent(id);
    await loadStudents();
  }

  @override
  void dispose() {
    nameController.dispose();
    courseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SQLite Student Database'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Student Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: courseController,
              decoration: const InputDecoration(
                labelText: 'Course',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: addStudent,
                child: const Text('Add Student'),
              ),
            ),
            const Divider(height: 30),
            const Text(
              'Stored Students',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: students.isEmpty
                  ? const Center(child: Text('No students found'))
                  : ListView.builder(
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        final student = students[index];

                        return Card(
                          child: ListTile(
                            title: Text(student['name']),
                            subtitle: Text(
                              '${student['course']} | ID: ${student['id']}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => editStudent(student),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () =>
                                      removeStudent(student['id']),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}