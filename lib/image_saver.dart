import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageSaveFromGallaryToDatabase extends StatefulWidget {
  const ImageSaveFromGallaryToDatabase({super.key});

  @override
  State<ImageSaveFromGallaryToDatabase> createState() =>
      _ImageSaveFromGallaryToDatabaseState();
}

class _ImageSaveFromGallaryToDatabaseState
    extends State<ImageSaveFromGallaryToDatabase> {
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  List<String> _imgUrls = [];

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    try{
      ListResult result = await _storage.ref('movies/').listAll();
      _imgUrls = [];
      for(int i = 0; i < result.items.length ; i++){
          Reference ref = result.items[i];
          String downloadUrl = await ref.getDownloadURL();
          setState(() {
            _imgUrls.add(downloadUrl);
          });
      }
    }catch(e){
      print('Error loading images: $e');
    }
  }

  Future<void> _uploadImage(File file) async {
    try {
      final DateTime now = DateTime.now();
      final String filePath = 'movies/${now.microsecondsSinceEpoch}_${file.path.split('/').last}';

      final SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg', // Specify the content type explicitly
        contentDisposition: 'inline', // Set the content disposition to inline
      );

      await _storage.ref(filePath).putFile(
        file,
        metadata,
      );
      print('File Uploaded');
      _loadImages();
    } catch (e) {
      print('Error uploading file: $e');
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _uploadImage(File(pickedFile.path));
    } else {
      print('No image selected.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Center(
              child: Text(
                'Image Gallery',
                style: TextStyle(color: Colors.red, fontSize: 24),
              ),
            ),
            ElevatedButton(
              onPressed: pickImage,
              child: const Text('upload image'),
            ),
            Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12.0,right: 8.0,left: 8.0),
                  child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 4.0,
                          mainAxisSpacing: 4.0),
                      itemCount: _imgUrls.length,
                      itemBuilder: (context, index) {
                        return Image.network(
                          _imgUrls[index],
                          fit: BoxFit.cover,
                        );
                      }),
                ))
          ],
        ),
      ),
    );
  }
}
