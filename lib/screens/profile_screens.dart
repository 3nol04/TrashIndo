import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trashindo/screens/helpandsupport.dart';
import 'package:trashindo/screens/log_in_screen.dart';
import 'package:trashindo/screens/edit_profile.dart';
import 'package:trashindo/services/userServices.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserServices userServices = UserServices();
  String? _name, _profileImage, _email, _userId;

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreens()),
      (route) => false,
    );
  }

  Future<void> _getUser() async {
    final idUser = await FirebaseAuth.instance.currentUser;
    if (idUser != null) {
      final userData = await userServices.getUser(idUser.uid);
      if (mounted) {
        setState(() {
          _email = userData?.email;
          _name = userData?.name;
          _userId = userData?.id;
          _profileImage = userData?.image;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getUser(); // Fetch user data only once when the widget is first created
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Profile Picture
              GestureDetector(
                onTap: () {
                  showDialogImageProfile(_profileImage ?? '');
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
                    child: _profileImage == ""
                        ? const Icon(Icons.account_circle, size: 60)
                        : Image.memory(
                            base64Decode(_profileImage ?? ''),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(Icons.account_circle, size: 60),
                              );
                            },
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // User Information
              Text(
                _name ?? "Guest",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _email ?? "",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Account'),
                onTap: () async {
                  // Tunggu hasil dari EditProfileScreen dan perbarui data profil
                  final updatedData = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfileScreen(
                        id: _userId ?? "",
                        user: _name ?? "",
                        email: _email ?? "",
                        image: _profileImage ?? '',
                      ),
                    ),
                  );

                  // Cek jika data diperbarui dan lakukan pembaruan status
                  if (updatedData != null) {
                    setState(() {
                      _name = updatedData['name'];
                      _email = updatedData['email'];
                      _profileImage = updatedData['image'];
                    });
                    // Memperbarui data terbaru dari Firebase setelah perubahan
                    await _getUser();
                  }
                },
              ),

              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Coming Soon!'),
                        content: Text('This feature is coming soon!'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('Close'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.help),
                title: const Text('Help & Support'),
                onTap: () {
                  // Navigate to Help & Support Screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HelpSupportScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                  _showLogoutDialog();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () {
                _signOut(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  void showDialogImageProfile(String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.35,
                height: MediaQuery.of(context).size.height * 0.15,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: imageUrl == ""
                      ? const Icon(Icons.account_circle, size: 60)
                      : Image.memory(
                          base64Decode(imageUrl ?? ''),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(Icons.error, color: Colors.red),
                            );
                          },
                        ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Tutup'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
