import 'dart:io';
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ContentViewerPage extends StatefulWidget {
  final String url;
  final String type;
  final String title;
  final String? description;

  const ContentViewerPage({
    super.key,
    required this.url,
    required this.type,
    required this.title,
    this.description,
  });

  @override
  State<ContentViewerPage> createState() => _ContentViewerPageState();
}

class _ContentViewerPageState extends State<ContentViewerPage> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  String? localPath;
  bool isLoading = true;
  bool isError = false;
  double _rating = 0.0;
  int _totalPages = 0;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    try {
      final cleanUrlPath = Uri.parse(widget.url).path;
      final ext = cleanUrlPath.split('.').last.toLowerCase();

      if (widget.type == 'Video Lecture' || ext == 'mp4') {
        _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.url));
        await _videoController!.initialize();
        _chewieController = ChewieController(videoPlayerController: _videoController!);
        setState(() => isLoading = false);
      } else if (ext == 'pdf') {
        final file = await _downloadFile(widget.url, 'preview.pdf');
        setState(() {
          localPath = file.path;
          isLoading = false;
        });
      } else if (['doc', 'docx', 'ppt', 'pptx'].contains(ext)) {
        final file = await _downloadFile(widget.url, 'temp.$ext');
        setState(() => isLoading = false);
        await OpenFilex.open(file.path);
        Navigator.pop(context);
      } else {
        setState(() {
          isLoading = false;
          isError = true;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
  }

  Future<File> _downloadFile(String url, String filename) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) throw Exception('Download failed: ${response.statusCode}');
    await file.writeAsBytes(response.bodyBytes);
    return file;
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isError
          ? const Center(child: Text("❌ Failed to load content."))
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    final ext = Uri.parse(widget.url).path.split('.').last.toLowerCase();

    if ((widget.type == 'Video Lecture' || ext == 'mp4') && _chewieController != null) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Chewie(controller: _chewieController!),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(widget.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 6),
            if (widget.description != null && widget.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(widget.description!, style: const TextStyle(fontSize: 14)),
              ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(thickness: 1),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text("Now playing in The Learning Nest player", style: TextStyle(fontSize: 13, color: Colors.grey)),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: RatingBar.builder(
                initialRating: _rating,
                minRating: 1,
                direction: Axis.horizontal,
                itemCount: 5,
                itemSize: 30,
                itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                onRatingUpdate: (rating) => setState(() => _rating = rating),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      );
    } else if (ext == 'pdf' && localPath != null) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Stack(
            children: [
              Positioned.fill(
                child: PDFView(
                  filePath: localPath!,
                  enableSwipe: true,
                  swipeHorizontal: true,
                  autoSpacing: false,
                  pageSnap: true,
                  fitEachPage: true,
                  onRender: (_pages) => setState(() => _totalPages = _pages ?? 0),
                  onViewCreated: (controller) => controller.setPage(_currentPage),
                  onPageChanged: (int? page, int? total) {
                    setState(() => _currentPage = page ?? 0);
                  },
                ),
              ),
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Page ${_currentPage + 1} of $_totalPages",
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ),
              )
            ],
          );
        },
      );
    } else {
      return const Center(child: Text("📂 Opening this file externally..."));
    }
  }
}
