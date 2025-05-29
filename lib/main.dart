import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:trashindo/firebase_options.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:trashindo/screens/books_marks_screens.dart';
import 'package:trashindo/screens/detail_screen.dart';
import 'package:trashindo/screens/home_screen.dart';
import 'package:trashindo/screens/log_in_screen.dart';
import 'package:trashindo/screens/on_boarding_screen.dart';
import 'package:trashindo/screens/profile_screens.dart';
import 'package:trashindo/screens/search_screens.dart';
import 'package:trashindo/screens/splash_screen.dart';
import 'package:trashindo/screens/upload_screens.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  MapboxOptions.setAccessToken(dotenv.env['MAPBOX_ACCESS_TOKEN']!);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeScreens(),
    const SeacrchScreens(),
    const UploadScreens(),
    const MarkScreens(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        backgroundColor: const Color(0x002C7C7D), // Transparan
        buttonBackgroundColor: const Color(0xFF2C7C7D),
        color: const Color(0xFF2C7C7D),
        animationCurve: Curves.fastEaseInToSlowEaseOut,
        height: 45,
        animationDuration: const Duration(milliseconds: 800),
        items: const <Widget>[
          Icon(Icons.home, size: 30, color: Colors.white),
          Icon(Icons.search, size: 30, color: Colors.white),
          Icon(Icons.add_a_photo, size: 30, color: Colors.white),
          Icon(Icons.bookmark_add, size: 30, color: Colors.white),
          Icon(Icons.person, size: 30, color: Colors.white),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
