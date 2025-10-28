import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const PhotoGalleryApp());
}

class PhotoGalleryApp extends StatelessWidget {
  const PhotoGalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Gallery',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const GalleryPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  final ImagePicker _picker = ImagePicker();
  List<File> _images = [];

  @override
  void initState() {
    super.initState();
    _loadSavedImages();
  }

  // 📂 Lấy thư mục lưu ảnh
  Future<Directory> _getAppDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${dir.path}/photos');
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    return imagesDir;
  }

  // 📥 Load ảnh đã lưu
  Future<void> _loadSavedImages() async {
    final dir = await _getAppDirectory();
    final files = dir.listSync().whereType<File>().toList();
    setState(() {
      _images = files;
    });
  }

  // 📸 Chụp ảnh và lưu vào thư mục app
  Future<void> _takePhoto() async {
    final cameraPermission = await Permission.camera.request();
    if (!cameraPermission.isGranted) return;

    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      final dir = await _getAppDirectory();
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final savedImage = await File(
        picked.path,
      ).copy('${dir.path}/$fileName.jpg');

      setState(() {
        _images.add(savedImage);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📸 My Photo Gallery'),
        centerTitle: true,
      ),
      body: _images.isEmpty
          ? const Center(child: Text('Chưa có ảnh nào, hãy chụp thử nhé!'))
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
              ),
              itemCount: _images.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullScreenImage(image: _images[index]),
                    ),
                  ),
                  child: Hero(
                    tag: _images[index].path,
                    child: Image.file(_images[index], fit: BoxFit.cover),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _takePhoto,
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final File image;
  const FullScreenImage({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: Hero(tag: image.path, child: Image.file(image)),
        ),
      ),
    );
  }
}
