import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trashindo/screens/log_in_screen.dart';
import 'package:trashindo/services/userServices.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserServices userServices = UserServices();
  String? _name, _profileImage, _email;

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreens()),
    );
  }

  Future<void> _getUser() async {
    final curretUser = await FirebaseAuth.instance.currentUser;
    if (curretUser != null) {
      final userData = await userServices.getUser(curretUser.uid);
      if (mounted) {
        if (userData != null) {
          setState(() {
            _email = userData.email;
            _name = userData.name;
            _profileImage =
                'https://wallpapers.com/images/hd/cool-profile-picture-ld8f4n1qemczkrig.jpg';
          });
        }
      }
    }
  }

  @override
  void initState() {
    _getUser();
    super.initState();
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
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(
                    _profileImage ??
                        'https://wallpapers.com/images/hd/cool-profile-picture-ld8f4n1qemczkrig.jpg', // Replace with actual image URL
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

              // Divider
              const Divider(),

              // List of Profile Options
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Account'),
                onTap: () {
                  // Navigate to Account Screen
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  // Navigate to Settings Screen
                },
              ),
              ListTile(
                leading: const Icon(Icons.help),
                title: const Text('Help & Support'),
                onTap: () {
                  // Navigate to Help & Support Screen
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                  // Implement logout functionality
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
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  imageUrl,
                  width: 250,
                  height: 250,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.error,
                        size: 100, color: Colors.red);
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const CircularProgressIndicator();
                  },
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
