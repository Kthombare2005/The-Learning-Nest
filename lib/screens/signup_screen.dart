import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  String selectedRole = "Student";
  bool showPassword = false;
  bool showConfirmPassword = false;

  final fullName = TextEditingController();
  final email = TextEditingController();
  final contact = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  final age = TextEditingController();
  final guardianName = TextEditingController();
  final guardianContact = TextEditingController();
  final schoolName = TextEditingController();
  String selectedClass = "Class 1";

  final studentName = TextEditingController();

  final experienceYears = TextEditingController();
  final description = TextEditingController();
  String fieldOfExpertise = "Science";

  Future<void> signUpUser() async {
    final firebaseApiKey = dotenv.env['FIREBASE_API_KEY'];
    if (firebaseApiKey == null || firebaseApiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("API key not found. Check .env setup.")),
      );
      return;
    }

    try {
      final authUrl = Uri.parse("https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$firebaseApiKey");

      final authResponse = await http.post(
        authUrl,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email.text.trim(),
          "password": password.text.trim(),
          "returnSecureToken": true,
        }),
      );

      final authData = json.decode(authResponse.body);

      if (authResponse.statusCode != 200) {
        throw Exception(authData["error"]["message"]);
      }

      final uid = authData["localId"];

      final userData = {
        "fullName": fullName.text.trim(),
        "email": email.text.trim(),
        "contact": contact.text.trim(),
        "role": selectedRole,
        "createdAt": FieldValue.serverTimestamp(),
      };

      if (selectedRole == "Student") {
        userData.addAll({
          "age": age.text.trim(),
          "class": selectedClass,
          "guardianName": guardianName.text.trim(),
          "guardianContact": "+91 ${guardianContact.text.trim()}",
          "schoolName": schoolName.text.trim(),
        });
      } else if (selectedRole == "Parent") {
        userData["studentName"] = studentName.text.trim();
      } else if (selectedRole == "Contributor") {
        userData.addAll({
          "fieldOfExpertise": fieldOfExpertise,
          "experienceYears": int.tryParse(experienceYears.text.trim()) ?? 0,
          "description": description.text.trim(),
        });
      }

      await FirebaseFirestore.instance.collection("users").doc(uid).set(userData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Signed up successfully!")),
      );

      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacementNamed(context, '/');
      });
    } catch (e) {
      print("❌ Signup error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Learning Nest - Sign Up"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField2(
              isExpanded: true,
              value: selectedRole,
              decoration: inputDecoration("Select Role").copyWith(
                prefixIcon: const Icon(Icons.person),
              ),
              items: const [
                DropdownMenuItem(value: "Student", child: Text("Student")),
                DropdownMenuItem(value: "Parent", child: Text("Parent")),
                DropdownMenuItem(value: "Contributor", child: Text("Contributor")),
              ],
              onChanged: (value) => setState(() => selectedRole = value!),
            ),
            const SizedBox(height: 16),
            TextFormField(controller: fullName, decoration: inputDecoration("Full Name")),
            const SizedBox(height: 16),
            TextFormField(controller: email, decoration: inputDecoration("Email ID")),
            const SizedBox(height: 16),
            TextFormField(
              controller: contact,
              keyboardType: TextInputType.number,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: inputDecoration("Contact Number").copyWith(prefixText: "+91 ", counterText: ""),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: password,
              obscureText: !showPassword,
              decoration: inputDecoration("Create Password").copyWith(
                suffixIcon: IconButton(
                  icon: Icon(showPassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => showPassword = !showPassword),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: confirmPassword,
              obscureText: !showConfirmPassword,
              decoration: inputDecoration("Confirm Password").copyWith(
                suffixIcon: IconButton(
                  icon: Icon(showConfirmPassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => showConfirmPassword = !showConfirmPassword),
                ),
              ),
            ),
            const SizedBox(height: 16),

            if (selectedRole == "Student") ...[
              TextFormField(
                controller: age,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
                decoration: inputDecoration("Age"),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField(
                value: selectedClass,
                decoration: inputDecoration("Select Class").copyWith(prefixIcon: const Icon(Icons.school)),
                items: [
                  "Class 1", "Class 2", "Class 3", "Class 4", "Class 5",
                  "Class 6", "Class 7", "Class 8", "Class 9", "Class 10", "Class 11", "Class 12"
                ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (value) => setState(() => selectedClass = value!),
              ),
              const SizedBox(height: 16),
              TextFormField(controller: guardianName, decoration: inputDecoration("Guardian Name")),
              const SizedBox(height: 16),
              TextFormField(
                controller: guardianContact,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: inputDecoration("Guardian Contact").copyWith(prefixText: "+91 "),
              ),
              const SizedBox(height: 16),
              TextFormField(controller: schoolName, decoration: inputDecoration("School Name")),
            ],

            if (selectedRole == "Parent") ...[
              TextFormField(controller: studentName, decoration: inputDecoration("Student Name")),
            ],

            if (selectedRole == "Contributor") ...[
              DropdownButtonFormField(
                value: fieldOfExpertise,
                decoration: inputDecoration("Field of Expertise").copyWith(prefixIcon: const Icon(Icons.work_outline)),
                items: [
                  "Science", "Mathematics", "English", "Computer Science", "Other"
                ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (value) => setState(() => fieldOfExpertise = value!),
              ),
              const SizedBox(height: 16),
              TextFormField(controller: experienceYears, keyboardType: TextInputType.number, decoration: inputDecoration("Years of Experience")),
              const SizedBox(height: 16),
              TextFormField(controller: description, maxLines: 3, decoration: inputDecoration("Description")),
            ],

            const SizedBox(height: 28),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: signUpUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Sign Up", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
