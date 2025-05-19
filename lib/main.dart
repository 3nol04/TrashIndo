import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:trashindo/screens/detail_screen.dart';
import 'package:trashindo/screens/home_screen.dart';
import 'package:trashindo/screens/log_in_screen.dart';
import 'package:trashindo/screens/on_boarding_screen.dart';
import 'package:trashindo/screens/splash_screen.dart';
import 'package:trashindo/screens/upload_screens.dart';

void main() {
  _setUp();
  runApp(const MainApp());
}

Future<void> _setUp() async {
  await dotenv.load(
    fileName: ".env",
  );
  MapboxOptions.setAccessToken(dotenv.env['MAPBOX_ACCESS_TOKEN']!);
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            //body: Splashscreen(),
            //body: OnboardingScreen()
            //body: LoginScreens(),
            //body: HomeScreens(),
            //body: HomeScreens(),
            body: UploadScreends()
           //body: DetailScreens()
           ));
  }
}
