import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';

class ContributorDashboard extends StatelessWidget {
  const ContributorDashboard({super.key});

  Future<String> _getContributorName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return 'Contributor';

    final snapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return snapshot.data()?['fullName'] ?? 'Contributor';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getContributorName(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final name = snapshot.data!;
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blue,
            title: const Text("Contributor Dashboard"),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacementNamed(context, '/');
                },
              )
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome back, $name 👋",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    StatCard(title: "Uploads", value: "0", color: Colors.blue, icon: Icons.cloud_upload),
                    StatCard(title: "Views", value: "0", color: Colors.orange, icon: Icons.visibility),
                    StatCard(title: "Revenue", value: "₹0", color: Colors.green, icon: Icons.currency_rupee),
                  ],
                ),
                const SizedBox(height: 30),
                const Text("Uploads vs Revenue", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                const SizedBox(height: 10),
                AspectRatio(
                  aspectRatio: 1.6,
                  child: BarChart(
                    BarChartData(
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
                              return Text(days[value.toInt() % days.length]);
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      barGroups: [
                        BarChartGroupData(x: 0, barRods: [
                          BarChartRodData(toY: 5, color: Colors.blue, width: 8),
                          BarChartRodData(toY: 300, color: Colors.green, width: 8),
                        ]),
                        BarChartGroupData(x: 1, barRods: [
                          BarChartRodData(toY: 3, color: Colors.blue, width: 8),
                          BarChartRodData(toY: 250, color: Colors.green, width: 8),
                        ]),
                        BarChartGroupData(x: 2, barRods: [
                          BarChartRodData(toY: 6, color: Colors.blue, width: 8),
                          BarChartRodData(toY: 400, color: Colors.green, width: 8),
                        ]),
                      ],
                      groupsSpace: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: 0,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.black54,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
              BottomNavigationBarItem(icon: Icon(Icons.upload), label: "Upload"),
              BottomNavigationBarItem(icon: Icon(Icons.image), label: "Gallery"),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
            ],
          ),
        );
      },
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
        margin: const EdgeInsets.symmetric(horizontal: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(
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
