import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';

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

  final titleController = TextEditingController();
  final descController = TextEditingController();

  final classOptions = ['Nursery'] + List.generate(12, (i) => 'Class ${i + 1}');
  final typeOptions = ['Video Lecture', 'Worksheet', 'Notes'];

  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Study Material"),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, '/contributor-dashboard'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Title"),
                validator: (value) =>
                value!.isEmpty ? "Please enter a title" : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedClass,
                decoration: const InputDecoration(labelText: "Select Class"),
                items: classOptions
                    .map((cls) =>
                    DropdownMenuItem(value: cls, child: Text(cls)))
                    .toList(),
                onChanged: (val) => setState(() => selectedClass = val),
                validator: (value) =>
                value == null ? "Please select a class" : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(labelText: "Material Type"),
                items: typeOptions
                    .map((type) =>
                    DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (val) => setState(() => selectedType = val),
                validator: (value) =>
                value == null ? "Please select a type" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descController,
                maxLines: 3,
                decoration:
                const InputDecoration(labelText: "Description (optional)"),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.attach_file),
                label: Text(selectedFile != null
                    ? selectedFile!.name
                    : "Choose File"),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitUpload,
                child: const Text("Upload Material"),
              ),
            ],
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
          } else if (index == 1) {
            // already on upload
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/gallery');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/profile');
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

  Future<void> _pickFile() async {
    final typeGroup = XTypeGroup(
      label: 'any',
      extensions: ['pdf', 'docx', 'mp4', 'jpg', 'png', 'txt'],
    );

    final picked = await openFile(acceptedTypeGroups: [typeGroup]);

    if (picked != null) {
      setState(() {
        selectedFile = picked;
      });
    }
  }

  void _submitUpload() {
    if (_formKey.currentState!.validate() && selectedFile != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Uploading...")),
      );

      // TODO: Add Firebase Storage upload + Firestore write
    } else if (selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a file")),
      );
    }
  }
}
