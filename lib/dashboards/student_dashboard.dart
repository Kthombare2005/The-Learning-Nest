import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:the_learning_nest/pages/profile_page.dart';
import 'package:the_learning_nest/pages/quiz_page.dart';
import 'package:the_learning_nest/pages/content_viewer_page.dart';
import 'package:the_learning_nest/pages/explore_page.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  String fullName = "Student";
  String selectedClass = "Class 1";
  int age = 0;
  int screenTimeLimit = 0;
  String? uid;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeDashboard();
  }

  Future<void> _initializeDashboard() async {
    await _fetchStudentInfo();
    await _assignAssignment1();
  }

  Future<void> _fetchStudentInfo() async {
    final prefs = await SharedPreferences.getInstance();
    uid = prefs.getString('uid');
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid!).get();
      final data = doc.data();
      if (data != null) {
        setState(() {
          fullName = data['fullName'] ?? 'Student';
          selectedClass = data['class'] ?? 'Class 1';
          age = int.tryParse(data['age'].toString()) ?? 0;
          screenTimeLimit = _getScreenTimeLimit(age);
        });
      }
    }
  }

  Future<void> _assignAssignment1() async {
    if (uid == null) return;
    final today = DateTime.now().toIso8601String().substring(0, 10);

    final existing = await FirebaseFirestore.instance
        .collection('tasks')
        .where('studentUid', isEqualTo: uid)
        .where('title', isEqualTo: 'Assignment 1')
        .where('date', isEqualTo: today)
        .limit(1)
        .get();

    if (existing.docs.isEmpty) {
      final materialQuery = await FirebaseFirestore.instance
          .collection('materials')
          .where('title', isEqualTo: 'Assignment 1')
          .limit(1)
          .get();

      if (materialQuery.docs.isNotEmpty) {
        final mat = materialQuery.docs.first;
        await FirebaseFirestore.instance.collection('tasks').add({
          'studentUid': uid,
          'title': mat['title'],
          'description': mat['description'] ?? 'Worksheet',
          'materialId': mat.id,
          'status': 'pending',
          'date': today,
        });
      }
    }
  }

  int _getScreenTimeLimit(int age) {
    if (age <= 5) return 1;
    if (age <= 10) return 2;
    if (age <= 15) return 3;
    return 4;
  }

  void _onTabTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().toIso8601String().substring(0, 10);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0
              ? 'Student Dashboard'
              : _selectedIndex == 1
              ? 'Explore'
              : _selectedIndex == 2
              ? 'Quiz'
              : 'Profile',
        ),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('uid');
              if (context.mounted) Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: _selectedIndex == 0
          ? _buildHome(today)
          : _selectedIndex == 1
          ? ExplorePage(selectedClass: selectedClass)
          : _selectedIndex == 2
          ? const QuizPage(taskId: 'preview')
          : const ProfilePage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black54,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: "Explore"),
          BottomNavigationBarItem(icon: Icon(Icons.quiz), label: "Quiz"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildHome(String today) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Welcome back, $fullName 👋", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: const [
              StatCard(title: "Progress", value: "42%", color: Colors.purple, icon: Icons.bar_chart),
              StatCard(title: "Completed", value: "12", color: Colors.green, icon: Icons.check_circle),
              StatCard(title: "Time Left", value: "1.5h", color: Colors.red, icon: Icons.timer),
            ],
          ),
          const SizedBox(height: 24),
          Text("Today's Screen Time Limit: $screenTimeLimit hours",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 24),
          const Text("Subject-wise Time Spent (Weekly)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                sections: [
                  PieChartSectionData(value: 3, color: Colors.blue, radius: 60),
                  PieChartSectionData(value: 2.5, color: Colors.orange, radius: 60),
                  PieChartSectionData(value: 1.5, color: Colors.green, radius: 60),
                  PieChartSectionData(value: 1, color: Colors.purple, radius: 60),
                  PieChartSectionData(value: 0.5, color: Colors.grey, radius: 60),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text("Legend", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              LegendItem(color: Colors.blue, label: "Science – 3h"),
              LegendItem(color: Colors.orange, label: "Math – 2.5h"),
              LegendItem(color: Colors.green, label: "English – 1.5h"),
              LegendItem(color: Colors.purple, label: "History – 1h"),
              LegendItem(color: Colors.grey, label: "Others – 0.5h"),
            ],
          ),
          const SizedBox(height: 30),
          const Text("Today's Tasks / Schedule", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          uid == null
              ? const Center(child: CircularProgressIndicator())
              : FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('tasks')
                .where('studentUid', isEqualTo: uid)
                .where('date', isEqualTo: today)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return const Text("No tasks scheduled for today.");
              }

              return Column(
                children: docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final isCompleted = data['status'] == 'completed';
                  final materialId = data['materialId'];

                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: Icon(
                        isCompleted ? Icons.check_circle : Icons.timelapse,
                        color: isCompleted ? Colors.green : Colors.grey,
                      ),
                      title: Text(data['title'] ?? 'Task'),
                      subtitle: Text(data['description'] ?? ''),
                      trailing: isCompleted
                          ? const Icon(Icons.verified, color: Colors.green)
                          : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_red_eye),
                            tooltip: "View Assignment",
                            onPressed: () async {
                              if (materialId != null) {
                                final materialDoc = await FirebaseFirestore.instance
                                    .collection('materials')
                                    .doc(materialId)
                                    .get();
                                final mat = materialDoc.data();
                                if (mat != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ContentViewerPage(
                                        title: mat['title'] ?? '',
                                        url: mat['url'] ?? '',
                                        type: mat['type'] ?? '',
                                        description: mat['description'] ?? '',
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => QuizPage(taskId: doc.id),
                                ),
                              );
                            },
                            child: const Text("Quiz"),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        color: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 30),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              Text(title, style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

class LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const LegendItem({super.key, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(width: 16, height: 16, color: color),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
