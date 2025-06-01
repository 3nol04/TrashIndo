import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen(
      {super.key,
      required this.id,
      required this.email,
      required this.user,
      required this.image}); // Constructor

  final String user,
      image,
      email,
      id; // Fields to receive the user and image data

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  File? _imageStorage; // Used to store the image file picked by the user
  String? _profileImageUrl; // Holds the base64 string of the compressed image

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user);
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker imagePicker = ImagePicker();
    final XFile? image = await imagePicker.pickImage(
      source: source,
      maxWidth: 600,
      maxHeight: 600,
    );
    if (image != null) {
      setState(() {
        _imageStorage = File(image.path); // Update the profile image file
      });
      await _compressImage(_imageStorage!); // Compress the image
    }
  }

  Future<void> _compressImage(File image) async {
    if (image == null) {
      return;
    }
    var compressedImage = await FlutterImageCompress.compressWithFile(
      image.path,
      minWidth: 800,
      minHeight: 600,
      quality: 80,
    );
    setState(() {
      _profileImageUrl =
          base64Encode(compressedImage!); // Save the compressed image as base64
    });
  }

  void _showImagePickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () async {
                  await _pickImage(ImageSource.gallery);
                  Navigator.pop(
                    context,
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Camera'),
                onTap: () async {
                  await _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: widget.email)
        .get()
        .then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final userDoc = snapshot.docs.first;
        userDoc.reference.update({
          'name': _nameController.text,
          'image': _profileImageUrl ??
              widget.image, // Use the new image or the old one
        });
        print('Saved successfully!');
      } else {
        print('User not found!');
      }
    });
    // After saving, you can navigate back or show a success message
    Navigator.pop(context); // Go back after saving
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Picture (editable)
            GestureDetector(
              onTap: () {
                _showImagePickerOptions(context);
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.35,
                height: MediaQuery.of(context).size.height * 0.15,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: _imageStorage == null
                      ? widget.image.isEmpty
                          ? const Icon(Icons.account_circle, size: 60)
                          : Image.memory(
                              base64Decode(widget.image),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(Icons.error, color: Colors.red),
                                );
                              },
                            )
                      : Image.file(
                          _imageStorage!,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Form for editing Name
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            // Save Button
            GestureDetector(
                onTap: _saveProfile,
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  // Button to save changes (with a tap gesture detector
                )),
          ],
        ),
      ),
    );
  }
}
