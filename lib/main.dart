import 'dart:math';
import 'package:flutter/material.dart';
import 'database/models/StudentModel.dart';
import 'database/database.dart';

void main () => runApp(MaterialApp(home: HomePage()));

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading;
  List<Student> students;

  final textController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    isLoading = true;
    fetchStudents();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Center(child: Text('SQLite Demo')),
      ),
      body: Column(
        children: <Widget>[
          form(),
          list(),
        ],
      ),
    );
  }

  form() {
    return Form(
      key: formKey,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextFormField(
              decoration: InputDecoration(
                labelText: 'Enter student full name'
              ),
              controller: textController,
              validator: (value) =>
              value.isEmpty ? "Field is empty" : null
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final words = textController.text.split(' ');
              if(formKey.currentState.validate()) {
                await DatabaseProvider.db.addStudent(
                  new Student(
                    firstName: words[0],
                    lastName: words[1],
                    grade: (Random().nextInt(4) + 1)
                  )
                );
                fetchStudents();
                textController.clear();
              }
            },
            child: Text("Add Student")
          )
        ]
      )
    );
  }

  list() {
    return Expanded(
      child: isLoading
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: students.length,
          itemBuilder: (context, index) {
            final student = students[index];
            return Dismissible(
              background: Container(color: Colors.red),
              key: Key(student.id.toString()),
              onDismissed: (direction) async {
                await DatabaseProvider.db.deleteStudent(student.id);
                fetchStudents();
              },
              child: ListTile(
                title: Text("${student.firstName} ${student.lastName}"),
                subtitle: Text('id: ${student.id} grade: ${student.grade}'),
              ),
            );
          }
        )
    );
  }

  void fetchStudents() async {
    setState(() => isLoading = true);
    final tmpList = await DatabaseProvider.db.getAllStudents();
    setState(() {
      isLoading = false;
      students = tmpList;
    });
  }
}
