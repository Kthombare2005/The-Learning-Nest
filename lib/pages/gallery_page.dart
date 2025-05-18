import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_learning_nest/dashboards/contributor_dashboard.dart';
import 'package:the_learning_nest/pages/content_viewer_page.dart';
import 'upload_page.dart';

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  Future<String?> getStoredUID() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('uid');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Uploads"),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<String?>(
        future: getStoredUID(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final uid = userSnapshot.data;
          if (uid == null || uid.isEmpty) {
            return const Center(child: Text("User not logged in"));
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('materials')
                .where('uploader', isEqualTo: uid)
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("You haven't uploaded anything yet."));
              }

              final materials = snapshot.data!.docs;

              return Padding(
                padding: const EdgeInsets.all(12),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.folder_special_rounded, color: Colors.deepPurple, size: 28),
                          SizedBox(width: 8),
                          Text(
                            "Your Contributions",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 4, top: 4, bottom: 12),
                        child: Text(
                          "Explore your uploaded content and share more knowledge!",
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 300,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          mainAxisExtent: 360,
                        ),
                        itemCount: materials.length,
                        itemBuilder: (context, index) {
                          final data = materials[index].data() as Map<String, dynamic>;
                          final title = data['title'] ?? 'Untitled';
                          final type = data['type'] ?? 'Material';
                          final materialClass = data['class'] ?? 'N/A';
                          final description = data['description'] ?? '';
                          final thumbnail = data['thumbnail'];
                          final url = data['url'];
                          final timestamp = (data['timestamp'] as Timestamp?)?.toDate();

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ContentViewerPage(
                                    url: url,
                                    type: type,
                                    title: title,
                                    description: description, // ✅ passed
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: thumbnail != null
                                        ? Image.network(
                                      thumbnail,
                                      height: 130,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    )
                                        : Container(
                                      height: 130,
                                      width: double.infinity,
                                      color: Colors.grey.shade300,
                                      child: const Icon(Icons.insert_drive_file, size: 40, color: Colors.orange),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    title,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        const TextSpan(
                                          text: "Description: ",
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87),
                                        ),
                                        TextSpan(
                                          text: description,
                                          style: const TextStyle(fontSize: 12, color: Colors.black87),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: -8,
                                    children: [
                                      Chip(
                                        label: Text(type, style: const TextStyle(fontSize: 11)),
                                        backgroundColor: Colors.blue.shade50,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                      Chip(
                                        label: Text(materialClass, style: const TextStyle(fontSize: 11)),
                                        backgroundColor: Colors.green.shade50,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        DateFormat('d MMM yyyy').format(timestamp ?? DateTime.now()),
                                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                                      ),
                                      TextButton.icon(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => ContentViewerPage(
                                                url: url,
                                                type: type,
                                                title: title,
                                                description: description, // ✅ passed
                                              ),
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.open_in_new, size: 16),
                                        label: const Text("View", style: TextStyle(fontSize: 12)),
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          foregroundColor: Colors.blue,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black54,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ContributorDashboard()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const UploadPage()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.upload), label: "Upload"),
          BottomNavigationBarItem(icon: Icon(Icons.image), label: "Gallery"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
