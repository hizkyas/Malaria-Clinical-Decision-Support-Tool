import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
import '../main.dart'; // To access the global 'cameras' list

class ScanRdtScreen extends StatefulWidget {
  const ScanRdtScreen({super.key});

  @override
  State<ScanRdtScreen> createState() => _ScanRdtScreenState();
}

class _ScanRdtScreenState extends State<ScanRdtScreen>
    with SingleTickerProviderStateMixin {
  CameraController? _controller;
  late AnimationController _laserController;
  late Animation<double> _laserAnimation;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _initLaser();
  }

  Future<void> _initCamera() async {
    if (cameras.isEmpty) return;
    _controller = CameraController(cameras[0], ResolutionPreset.high);
    await _controller!.initialize();
    if (mounted) setState(() {});
  }

  void _initLaser() {
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _laserAnimation = Tween<double>(
      begin: 0.1,
      end: 0.9,
    ).animate(_laserController);
  }

  Future<void> _captureAndScan() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    setState(() => _isProcessing = true);

    try {
      final XFile imageFile = await _controller!.takePicture();
      final String result = await _processImage(imageFile.path);

      if (mounted) {
        Navigator.pop(context, result);
      }
    } catch (e) {
      debugPrint("Scan error: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Processing failed: $e")));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  /// Simple CV Logic for Line Detection
  Future<String> _processImage(String path) async {
    final bytes = await File(path).readAsBytes();
    img.Image? image = img.decodeImage(bytes);

    if (image == null) return "Invalid";

    // 1. Crop to the center (representing the Green Rectangle)
    int cropW = (image.width * 0.4).toInt();
    int cropH = (image.height * 0.1).toInt();
    int cropX = (image.width - cropW) ~/ 2;
    int cropY = (image.height - cropH) ~/ 2;

    img.Image cropped = img.copyCrop(
      image,
      x: cropX,
      y: cropY,
      width: cropW,
      height: cropH,
    );

    // 2. Grayscale & Analyze column intensity
    img.Image gray = img.grayscale(cropped);

    List<int> colIntensity = List.filled(gray.width, 0);
    for (int x = 0; x < gray.width; x++) {
      int sum = 0;
      for (int y = 0; y < gray.height; y++) {
        // img.getPixel returns a Pixel object in newer versions of the image package
        final pixel = gray.getPixel(x, y);
        // For grayscale, r=g=b
        sum += pixel.r.toInt();
      }
      colIntensity[x] = sum ~/ gray.height;
    }

    // 3. Find Dips (Dark Lines)
    // We look for significant drops compared to local average
    int linesDetected = 0;
    int threshold = 20; // Intensity drop threshold
    bool inLine = false;

    // Smoothing/Moving average could go here, but keep it simple for now
    for (int i = 5; i < colIntensity.length - 5; i++) {
      int localAvg = (colIntensity[i - 5] + colIntensity[i + 5]) ~/ 2;
      if (colIntensity[i] < localAvg - threshold) {
        if (!inLine) {
          linesDetected++;
          inLine = true;
          // Skip ahead to avoid multiple counts for one thick line
          i += 10;
        }
      } else {
        inLine = false;
      }
    }

    if (linesDetected == 2) return "Positive";
    if (linesDetected == 1) return "Negative";
    return "Invalid";
  }

  @override
  void dispose() {
    _controller?.dispose();
    _laserController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    const emeraldGreen = Color(0xFF008F6B);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera feed
          Center(child: CameraPreview(_controller!)),

          // Overlay: Green Rectangle
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.greenAccent, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          // Animation: Laser
          AnimatedBuilder(
            animation: _laserAnimation,
            builder: (context, child) {
              return Positioned(
                top:
                    (MediaQuery.of(context).size.height / 2 - 60) +
                    (120 * _laserAnimation.value),
                left: MediaQuery.of(context).size.width * 0.1,
                width: MediaQuery.of(context).size.width * 0.8,
                child: Container(
                  height: 2,
                  color: Colors.redAccent.withValues(alpha: 0.8),
                ),
              );
            },
          ),

          // Instructions
          Positioned(
            top: 60,
            left: 20,
            right: 20,
            child: Text(
              "Align RDT strip inside the rectangle\nየምርመራውን ካርታ በሳጥኑ ውስጥ ያስገቡ",
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Bottom Controls
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: _isProcessing
                  ? Column(
                      children: [
                        const CircularProgressIndicator(color: Colors.white),
                        const SizedBox(height: 16),
                        Text(
                          "Analyzing... | በመተንተን ላይ...",
                          style: GoogleFonts.outfit(color: Colors.white),
                        ),
                      ],
                    )
                  : FloatingActionButton.large(
                      backgroundColor: emeraldGreen,
                      onPressed: _captureAndScan,
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
            ),
          ),

          // Back button
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
