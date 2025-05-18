import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:the_learning_nest/pages/content_viewer_page.dart';

class ExplorePage extends StatefulWidget {
  final String selectedClass;
  const ExplorePage({super.key, required this.selectedClass});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  String searchQuery = '';
  String? selectedType;
  final List<String> typeOptions = [
    'All',
    'Video Lecture',
    'Worksheet',
    'PDF',
    'Presentation',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchAndFilter(),
        Expanded(
          child: FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('materials')
                .where('class', isEqualTo: widget.selectedClass)
                .orderBy('timestamp', descending: true)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data?.docs ?? [];
              final filteredDocs = docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final title = data['title']?.toString().toLowerCase() ?? '';
                final subject = data['subject']?.toString().toLowerCase() ?? '';
                final type = data['type']?.toString();

                final matchesSearch = searchQuery.isEmpty ||
                    title.contains(searchQuery.toLowerCase()) ||
                    subject.contains(searchQuery.toLowerCase());

                final matchesType = selectedType == null ||
                    selectedType == 'All' ||
                    type == selectedType;

                return matchesSearch && matchesType;
              }).toList();

              if (filteredDocs.isEmpty) {
                return const Center(child: Text("No matching content found."));
              }

              return Padding(
                padding: const EdgeInsets.all(12),
                child: GridView.builder(
                  itemCount: filteredDocs.length,
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 300,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    mainAxisExtent: 400,
                  ),
                  itemBuilder: (context, index) {
                    final data = filteredDocs[index].data() as Map<String, dynamic>;
                    final title = data['title'] ?? 'Untitled';
                    final type = data['type'] ?? 'Material';
                    final materialClass = data['class'] ?? 'N/A';
                    final subject = data['subject'] ?? '';
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
                              description: description,
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
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
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
                                if (subject.isNotEmpty)
                                  Chip(
                                    label: Text(subject, style: const TextStyle(fontSize: 11)),
                                    backgroundColor: Colors.purple.shade50,
                                    visualDensity: VisualDensity.compact,
                                  ),
                              ],
                            ),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  timestamp != null
                                      ? DateFormat('d MMM yyyy').format(timestamp)
                                      : '',
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
                                          description: description,
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
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (val) => setState(() => searchQuery = val),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Search by title or subject",
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          DropdownButton<String>(
            value: selectedType ?? 'All',
            items: typeOptions
                .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                .toList(),
            onChanged: (value) {
              setState(() => selectedType = value);
            },
            underline: const SizedBox(),
          ),
        ],
      ),
    );
  }
}
