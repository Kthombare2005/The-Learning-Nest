import 'package:flutter/material.dart';

class QuizPage extends StatelessWidget {
  final String taskId;

  const QuizPage({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("Quiz"),
      //   backgroundColor: Colors.blue,
      // ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Handle quiz submission using taskId if needed
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Quiz submitted!")),
            );
            Navigator.pop(context);
          },
          child: const Text("Submit Quiz"),
        ),
      ),
    );
  }
}
