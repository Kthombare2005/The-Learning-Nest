// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
//
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();
//   bool showPassword = false;
//
//   Future<void> loginUser() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     try {
//       final firebaseApiKey = dotenv.env['FIREBASE_API_KEY'];
//       final response = await http.post(
//         Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$firebaseApiKey'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'email': _emailController.text.trim(),
//           'password': _passwordController.text.trim(),
//           'returnSecureToken': true,
//         }),
//       );
//
//       final data = jsonDecode(response.body);
//       if (response.statusCode != 200) {
//         final error = data['error']['message'];
//         String msg = switch (error) {
//           'EMAIL_NOT_FOUND' => 'Email not found. Please sign up.',
//           'INVALID_PASSWORD' => 'Invalid password.',
//           _ => 'Login failed. $error',
//         };
//         throw Exception(msg);
//       }
//
//       final uid = data['localId'];
//       final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
//       final role = userDoc.data()?['role'];
//
//       if (role == 'Student') {
//         Navigator.pushReplacementNamed(context, '/student-dashboard');
//       } else if (role == 'Contributor') {
//         Navigator.pushReplacementNamed(context, '/contributor-dashboard');
//       } else if (role == 'Parent') {
//         Navigator.pushReplacementNamed(context, '/parent-dashboard');
//       } else {
//         throw Exception("Unknown user role.");
//       }
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Login successful!")),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("❌ $e")),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(horizontal: 24),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   const SizedBox(height: 50),
//                   CircleAvatar(
//                     radius: 60,
//                     backgroundColor: Colors.blue.shade50,
//                     child: const Icon(Icons.school, size: 50, color: Colors.blue),
//                   ),
//                   const SizedBox(height: 36),
//                   const Text(
//                     "Welcome to Learning Nest",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.black87),
//                   ),
//                   const SizedBox(height: 10),
//                   const Text(
//                     "Log in to continue your learning journey",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(fontSize: 15, color: Colors.black54, fontWeight: FontWeight.w500),
//                   ),
//                   const SizedBox(height: 32),
//                   Container(
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade100,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: TextFormField(
//                       controller: _emailController,
//                       validator: (value) => value == null || value.isEmpty ? "Enter email" : null,
//                       keyboardType: TextInputType.emailAddress,
//                       decoration: const InputDecoration(
//                         hintText: "Email",
//                         hintStyle: TextStyle(fontSize: 15),
//                         prefixIcon: Icon(Icons.email, color: Colors.blue),
//                         border: InputBorder.none,
//                         contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Container(
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade100,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: TextFormField(
//                       controller: _passwordController,
//                       validator: (value) => value == null || value.isEmpty ? "Enter password" : null,
//                       obscureText: !showPassword,
//                       decoration: InputDecoration(
//                         hintText: "Password",
//                         hintStyle: const TextStyle(fontSize: 15),
//                         prefixIcon: const Icon(Icons.lock, color: Colors.blue),
//                         suffixIcon: IconButton(
//                           icon: Icon(showPassword ? Icons.visibility : Icons.visibility_off),
//                           onPressed: () => setState(() => showPassword = !showPassword),
//                         ),
//                         border: InputBorder.none,
//                         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Align(
//                     alignment: Alignment.centerRight,
//                     child: TextButton(
//                       onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
//                       child: const Text(
//                         "Forgot Password?",
//                         style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   SizedBox(
//                     height: 50,
//                     child: ElevatedButton(
//                       onPressed: loginUser,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.blue,
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                         elevation: 0,
//                       ),
//                       child: const Text(
//                         "Login",
//                         style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   SizedBox(
//                     height: 48,
//                     child: OutlinedButton.icon(
//                       icon: const Icon(Icons.sms, color: Colors.blue),
//                       label: const Text(
//                         "Login with OTP",
//                         style: TextStyle(fontSize: 15, color: Colors.blue, fontWeight: FontWeight.w600),
//                       ),
//                       onPressed: () => Navigator.pushNamed(context, '/login-otp'),
//                       style: OutlinedButton.styleFrom(
//                         side: const BorderSide(color: Colors.blue),
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                   GestureDetector(
//                     onTap: () => Navigator.pushNamed(context, '/signup'),
//                     child: const Center(
//                       child: Text.rich(
//                         TextSpan(
//                           text: "Don't have an account? ",
//                           style: TextStyle(fontSize: 14, color: Colors.black54),
//                           children: [
//                             TextSpan(
//                               text: "Sign Up",
//                               style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 30),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool showPassword = false;

  Future<void> loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final firebaseApiKey = dotenv.env['FIREBASE_API_KEY'];
      final response = await http.post(
        Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$firebaseApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
          'returnSecureToken': true,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode != 200) {
        final error = data['error']['message'];
        String msg = switch (error) {
          'EMAIL_NOT_FOUND' => 'Email not found. Please sign up.',
          'INVALID_PASSWORD' => 'Invalid password.',
          _ => 'Login failed. $error',
        };
        throw Exception(msg);
      }

      final uid = data['localId'];

      // ✅ Save UID to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('uid', uid);

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final role = userDoc.data()?['role'];

      if (role == 'Student') {
        Navigator.pushReplacementNamed(context, '/student-dashboard');
      } else if (role == 'Contributor') {
        Navigator.pushReplacementNamed(context, '/contributor-dashboard');
      } else if (role == 'Parent') {
        Navigator.pushReplacementNamed(context, '/parent-dashboard');
      } else {
        throw Exception("Unknown user role.");
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login successful!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 50),
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.blue.shade50,
                    child: const Icon(Icons.school, size: 50, color: Colors.blue),
                  ),
                  const SizedBox(height: 36),
                  const Text(
                    "Welcome to Learning Nest",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.black87),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Log in to continue your learning journey",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.black54, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextFormField(
                      controller: _emailController,
                      validator: (value) => value == null || value.isEmpty ? "Enter email" : null,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: "Email",
                        hintStyle: TextStyle(fontSize: 15),
                        prefixIcon: Icon(Icons.email, color: Colors.blue),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextFormField(
                      controller: _passwordController,
                      validator: (value) => value == null || value.isEmpty ? "Enter password" : null,
                      obscureText: !showPassword,
                      decoration: InputDecoration(
                        hintText: "Password",
                        hintStyle: const TextStyle(fontSize: 15),
                        prefixIcon: const Icon(Icons.lock, color: Colors.blue),
                        suffixIcon: IconButton(
                          icon: Icon(showPassword ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => showPassword = !showPassword),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: loginUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Login",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.sms, color: Colors.blue),
                      label: const Text(
                        "Login with OTP",
                        style: TextStyle(fontSize: 15, color: Colors.blue, fontWeight: FontWeight.w600),
                      ),
                      onPressed: () => Navigator.pushNamed(context, '/login-otp'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.blue),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/signup'),
                    child: const Center(
                      child: Text.rich(
                        TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                          children: [
                            TextSpan(
                              text: "Sign Up",
                              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
