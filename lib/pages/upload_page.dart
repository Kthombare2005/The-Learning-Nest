// (same imports)
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_selector/file_selector.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_learning_nest/pages/gallery_page.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final _formKey = GlobalKey<FormState>();
  String? selectedClass;
  String? selectedType;
  XFile? selectedFile;
  XFile? thumbnailFile;
  bool isUploading = false;

  final titleController = TextEditingController();
  final subjectController = TextEditingController();
  final descController = TextEditingController();
  final int _maxDescriptionLength = 100;

  final classOptions = ['Nursery'] + List.generate(12, (i) => 'Class ${i + 1}');
  final typeOptions = ['Video Lecture', 'Worksheet', 'Notes'];

  int _selectedIndex = 1;

  List<String> getAllowedExtensions() {
    if (selectedType == "Video Lecture") {
      return ['mp4', 'avi', 'mov', 'mkv'];
    } else if (selectedType == "Worksheet" || selectedType == "Notes") {
      return ['pdf', 'docx', 'pptx', 'ppt', 'doc'];
    }
    return [];
  }

  Future<String?> _getStoredUid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('uid');
  }

  @override
  Widget build(BuildContext context) {
    if (isUploading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Uploading file...", style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF1F3FA),
      appBar: AppBar(
        title: const Text("Upload Study Material"),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, '/contributor-dashboard'),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: 10,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_upload, size: 80, color: Colors.blueAccent),
                  const SizedBox(height: 16),
                  const Text("Upload Your Content", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text(
                    "Share notes, videos or worksheets with the community. Let's help students learn better!",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildInput(Icons.title, "Title", controller: titleController),
                        const SizedBox(height: 16),
                        _buildInput(Icons.book, "Subject", controller: subjectController),
                        const SizedBox(height: 16),
                        _buildDropdown(Icons.school, "Select Class", selectedClass, classOptions,
                                (val) => setState(() => selectedClass = val)),
                        const SizedBox(height: 16),
                        _buildDropdown(Icons.category, "Material Type", selectedType, typeOptions, (val) {
                          setState(() {
                            selectedType = val;
                            selectedFile = null;
                          });
                        }),
                        const SizedBox(height: 16),
                        _buildDescriptionField(),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _pickFile,
                          icon: const Icon(Icons.attach_file),
                          label: Text(selectedFile != null ? selectedFile!.name : "Choose File"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _pickThumbnail,
                          icon: const Icon(Icons.image),
                          label: Text(thumbnailFile != null ? thumbnailFile!.name : "Optional: Choose Thumbnail",
                              overflow: TextOverflow.ellipsis),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade200,
                            foregroundColor: Colors.blue,
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _submitUpload,
                          icon: const Icon(Icons.upload),
                          label: const Text("Upload Material"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black54,
        onTap: (index) {
          if (_selectedIndex == index) return;
          setState(() => _selectedIndex = index);
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/contributor-dashboard');
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const GalleryPage()));
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

  Widget _buildInput(IconData icon, String label, {required TextEditingController controller, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: (value) => (value == null || value.trim().isEmpty) ? "Please enter $label" : null,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildDropdown(IconData icon, String label, String? value, List<String> items, void Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
      validator: (val) => val == null ? "Please select $label" : null,
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: descController,
      maxLength: _maxDescriptionLength,
      maxLines: 3,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.description),
        labelText: "Description (max 100 characters)",
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _pickFile() async {
    if (selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select Material Type first")),
      );
      return;
    }

    final typeGroup = XTypeGroup(label: 'custom', extensions: getAllowedExtensions());
    final picked = await openFile(acceptedTypeGroups: [typeGroup]);
    if (picked != null) {
      setState(() {
        selectedFile = picked;
      });
    }
  }

  Future<void> _pickThumbnail() async {
    final imageGroup = XTypeGroup(label: 'images', extensions: ['jpg', 'png', 'jpeg']);
    final picked = await openFile(acceptedTypeGroups: [imageGroup]);
    if (picked != null) {
      setState(() {
        thumbnailFile = picked;
      });
    }
  }

  Future<void> _submitUpload() async {
    if (_formKey.currentState!.validate()) {
      if (selectedType == null || selectedFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please choose a valid file after selecting material type")),
        );
        return;
      }

      setState(() {
        isUploading = true;
      });

      try {
        final uid = await _getStoredUid();
        if (uid == null || uid.isEmpty) throw Exception("User not logged in.");

        final filename = const Uuid().v4() + "_" + selectedFile!.name;
        final storageRef = FirebaseStorage.instance.ref().child('materials/$filename');
        final fileBytes = await selectedFile!.readAsBytes();
        await storageRef.putData(fileBytes);
        final downloadUrl = await storageRef.getDownloadURL();

        String? thumbnailUrl;
        if (thumbnailFile != null) {
          final thumbName = const Uuid().v4() + "_" + thumbnailFile!.name;
          final thumbRef = FirebaseStorage.instance.ref().child('thumbnails/$thumbName');
          final thumbBytes = await thumbnailFile!.readAsBytes();
          await thumbRef.putData(thumbBytes);
          thumbnailUrl = await thumbRef.getDownloadURL();
        }

        await FirebaseFirestore.instance.collection('materials').add({
          'title': titleController.text.trim(),
          'subject': subjectController.text.trim(),
          'description': descController.text.trim(),
          'class': selectedClass,
          'type': selectedType,
          'url': downloadUrl,
          'filename': filename,
          'thumbnail': thumbnailUrl,
          'uploader': uid,
          'views': 0,
          'revenue': 0,
          'timestamp': FieldValue.serverTimestamp(),
        });

        setState(() {
          selectedFile = null;
          thumbnailFile = null;
          titleController.clear();
          subjectController.clear();
          descController.clear();
          selectedClass = null;
          selectedType = null;
          isUploading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Upload successful!")),
        );
      } catch (e) {
        setState(() {
          isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Upload failed: $e")));
      }
    }
  }
}
