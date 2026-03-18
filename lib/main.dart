import 'package:flutter/material.dart';
import 'travel_screen.dart';
import 'home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 LOAD ENV BEFORE APP STARTS
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  bool? isLoggedIn;

  @override
  void initState() {
    super.initState(); // 🔥 LOAD ENV FIRST
    checkLogin();   // 🔥 THEN CHECK LOGIN
  }

  /// 🔥 LOAD ENV FILE
  Future<void> loadEnv() async {
    try {
      await dotenv.load(fileName: ".env");
      print("✅ ENV LOADED SUCCESSFULLY");
    } catch (e) {
      print("❌ ENV LOAD ERROR: $e");
    }
  }

  /// 🔥 CHECK LOGIN
  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {

    // 🔄 Loading screen
    if (isLoggedIn == null) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PlanMyTrip AI',

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),

      home: isLoggedIn! ? const TravelScreen() : const HomeScreen(),
    );
  }
}