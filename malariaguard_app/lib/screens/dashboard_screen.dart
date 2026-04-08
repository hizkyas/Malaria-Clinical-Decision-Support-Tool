import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import '../services/dosage_service.dart';
import '../services/database_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final DosageService _dosageService = DosageService();
  final DatabaseService _dbService = DatabaseService();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  String _rdtResult = 'Positive';
  String _dosageMarkdown = "";
  bool _isLoading = false;
  bool _showResult = false;
  bool _isListening = false;
  
  // Safety Checklist
  bool _isUnconscious = false;
  bool _isVomiting = false;
  bool _isConvulsions = false;

  @override
  void initState() {
    super.initState();
    _initServices();
    _initAnimation();
  }

  void _initAnimation() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initServices() async {
    try {
      await _dosageService.init();
      await _tts.setLanguage("am-ET");
      await _tts.setSpeechRate(0.5);
      
      // Check if Amharic voice is available
      dynamic isAvailable = await _tts.isLanguageAvailable("am-ET");
      if (isAvailable == null || isAvailable == false) {
        _showTtsFallbackDialog();
      }
      
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Service initialization error: $e");
    }
  }

  void _showTtsFallbackDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Language Data Missing | የቋንቋ ዳታ አልተገኘም"),
        content: const Text(
          "Amharic voice data is not installed on this device. "
          "To enable the audio guide:\n\n"
          "1. Go to Settings > Accessibility\n"
          "2. Select Text-to-speech output\n"
          "3. Install Voice Data for Amharic (Ethiopia)."
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
        ],
      ),
    );
  }

  void _listen(TextEditingController controller) async {
    try {
      if (!_isListening) {
        bool available = await _speech.initialize(
          onStatus: (val) => debugPrint('STT Status: $val'),
          onError: (val) => debugPrint('STT Error: $val'),
        );
        
        if (available) {
          setState(() => _isListening = true);
          _speech.listen(
            localeId: "am-ET",
            onResult: (val) => setState(() {
              controller.text = val.recognizedWords;
              if (val.hasConfidenceRating && val.confidence > 0) {
                _isListening = false;
                _speech.stop();
              }
            }),
          );
        } else {
          debugPrint("Speech recognition not available on this device.");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Speech recognition not available.")),
          );
        }
      } else {
        setState(() => _isListening = false);
        _speech.stop();
      }
    } catch (e) {
      debugPrint("STT Exception: $e");
      setState(() => _isListening = false);
    }
  }

  void _calculateDosage() async {
    final double? weight = double.tryParse(_weightController.text);
    if (weight == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid weight.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _showResult = false;
    });

    try {
      String finalResult = "";
      if (!mounted) return;
      bool isEmergency = _isUnconscious || _isVomiting || _isConvulsions;

      if (isEmergency) {
        finalResult = "# 🚨 REFER TO HOSPITAL IMMEDIATELY\n\n"
            "**Emergency Condition Detected:**\n"
            "The patient shows severe symptoms. Refer to the nearest hospital at once.\n\n"
            "**ክሊኒካዊ ማስጠንቀቂያ:**\n"
            "በሽተኛው አስቸኳይ እርዳታ ይፈልጋል። እባክዎን ወዲያውኑ ወደ ሆስፒታል ይላኩ።";
      } else {
        finalResult = await _dosageService.getDosageRecommendation(
          name: _nameController.text.isEmpty ? "Anonymous" : _nameController.text,
          weight: weight,
          rdtResult: _rdtResult,
        );
      }

      setState(() {
        _dosageMarkdown = finalResult;
        _showResult = true;
      });

      await _dbService.saveDiagnosis({
        'patientName': _nameController.text.isEmpty ? "Anonymous" : _nameController.text,
        'weight': weight,
        'rdtResult': _rdtResult,
        'dosage': finalResult,
        'isEmergency': isEmergency ? 1 : 0,
        'timestamp': DateTime.now().toIso8601String(),
      });

    } catch (e) {
      debugPrint("Calculation error: $e");
      setState(() {
        _dosageMarkdown = "Error: $e";
        _showResult = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _playInstructions() async {
    try {
      String plainText = _dosageMarkdown.replaceAll("#", "").replaceAll("*", "");
      await _tts.speak(plainText);
    } catch (e) {
      debugPrint("TTS Playback error: $e");
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const emeraldGreen = Color(0xFF008F6B);
    final bool isReady = _dosageService.isModelReady;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text("MalariaGuard", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(width: 8),
            Tooltip(
              message: isReady ? "Google AI Core Active: ${_dosageService.modelVersion}" : "AI Core Inactive (Manual Fallback)",
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: isReady ? Colors.lightGreenAccent : Colors.redAccent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: emeraldGreen,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/history'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel("Patient Name | የታካሚ ስም", emeraldGreen),
              const SizedBox(height: 8),
              _buildInputField(
                controller: _nameController,
                hint: "Enter name...",
                icon: Icons.person_outline,
                onMicPressed: () => _listen(_nameController),
              ),

              const SizedBox(height: 20),

              _buildLabel("Weight (kg) | ክብደት", emeraldGreen),
              const SizedBox(height: 8),
              _buildInputField(
                controller: _weightController,
                hint: "e.g. 15",
                icon: Icons.monitor_weight_outlined,
                keyboardType: TextInputType.number,
                onMicPressed: () => _listen(_weightController),
              ),

              const SizedBox(height: 20),

              _buildLabel("RDT Result | የምርመራ ውጤት", emeraldGreen),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _rdtResult,
                      decoration: _inputDecoration(Icons.biotech_outlined, emeraldGreen),
                      items: ['Positive', 'Negative'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                      onChanged: (v) => setState(() => _rdtResult = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () async {
                        final result = await Navigator.pushNamed(context, '/scan') as String?;
                        if (!mounted) return;
                        if (result != null && result != "Invalid") {
                          setState(() {
                            _rdtResult = result;
                            _showResult = false;
                          });
                          if (result == "Positive") {
                            _calculateDosage();
                          }
                        } else if (result == "Invalid") {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Scan Failed: Could not detect lines. Please try again.")),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: emeraldGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Icon(Icons.qr_code_scanner, color: Colors.white),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Text("Safety Check | የደህንነት ፍተሻ (Danger Signs)", 
                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
              const SizedBox(height: 8),
              _buildCheckbox("Unconscious | ራሱን የሳተ", _isUnconscious, (v) => setState(() => _isUnconscious = v!)),
              _buildCheckbox("Vomiting | ማስመለስ", _isVomiting, (v) => setState(() => _isVomiting = v!)),
              _buildCheckbox("Convulsions | መንቀጥቀጥ", _isConvulsions, (v) => setState(() => _isConvulsions = v!)),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _calculateDosage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: emeraldGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                            const SizedBox(width: 12),
                            Text("Gemma is thinking...", style: GoogleFonts.outfit(fontSize: 16, color: Colors.white)),
                          ],
                        )
                      : Text("Calculate | አስላ", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),

              const SizedBox(height: 32),

              if (_showResult)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: emeraldGreen.withValues(alpha: 0.2)),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Result | ውጤት", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: emeraldGreen)),
                          IconButton(icon: const Icon(Icons.volume_up, color: emeraldGreen), onPressed: _playInstructions),
                        ],
                      ),
                      const Divider(),
                      MarkdownBody(data: _dosageMarkdown, styleSheet: MarkdownStyleSheet(p: GoogleFonts.outfit(fontSize: 15))),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, Color color) {
    return Text(text, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: color));
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    required VoidCallback onMicPressed,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: _inputDecoration(icon, const Color(0xFF008F6B)).copyWith(
        hintText: hint,
        suffixIcon: ScaleTransition(
          scale: _isListening ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
          child: IconButton(
            icon: Icon(_isListening ? Icons.mic : Icons.mic_none, color: _isListening ? Colors.red : Colors.grey),
            onPressed: onMicPressed,
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(IconData icon, Color color) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: color),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _buildCheckbox(String title, bool value, ValueChanged<bool?> onChanged) {
    return CheckboxListTile(
      title: Text(title, style: GoogleFonts.outfit(fontSize: 14)),
      value: value,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      dense: true,
      activeColor: Colors.red,
    );
  }
}
