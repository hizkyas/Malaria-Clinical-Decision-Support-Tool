import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:camera/camera.dart';
import 'screens/dashboard_screen.dart';
import 'screens/history_screen.dart';
import 'screens/scan_rdt_screen.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MalariaGuardApp());
}

class MalariaGuardApp extends StatelessWidget {
  const MalariaGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MalariaGuard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF008F6B),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF008F6B),
          surface: const Color(0xFFF5F7F8),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7F8),
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const DashboardScreen(),
        '/history': (context) => const HistoryScreen(),
        '/scan': (context) => const ScanRdtScreen(),
      },
    );
  }
}
