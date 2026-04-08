import 'package:gemini_nano_android/gemini_nano_android.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';

class DosageService {
  final GeminiNanoAndroid _nano = GeminiNanoAndroid();
  bool _isAvailable = false;
  String _modelVersion = "Unknown";

  bool get isModelReady => _isAvailable;
  String get modelVersion => _modelVersion;

  /// Initializes the Gemini Nano plugin and logs the model version.
  Future<void> init() async {
    try {
      _isAvailable = await _nano.isAvailable();
      if (_isAvailable) {
        _modelVersion = await _nano.getModelVersion() ?? "Gemma 4 (Local)";
      } else {
        // AI Core Inactive
      }
    } catch (e) {
      _isAvailable = false;
    }
  }

  Future<String> getDosageRecommendation({
    required String name,
    required double weight,
    required String rdtResult,
  }) async {
    try {
      // 1. Load the protocol from assets
      final String protocol = await rootBundle.loadString(
        'assets/malaria_protocol.md',
      );

      // 2. Hardware/Availability Check
      if (!_isAvailable) {
        return _getFallbackDosage(name, weight, rdtResult);
      }

      // 3. Prepare the prompt with System Instruction
      final String prompt =
          """
SYSTEM INSTRUCTION:
You are a medical assistant following the Ethiopian National Malaria Protocol. 
Use the following protocol as your absolute source of truth:

$protocol

USER CASE:
Patient Name: $name
Weight: ${weight}kg
RDT Result: $rdtResult

TASK:
Based on the attached protocol, provide the exact dosage and any clinical warnings. 
Return the response in a clear, bulleted Markdown format.
""";

      // 4. Generate with Timeout handling
      final response = await _nano
          .generate(prompt: prompt)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw TimeoutException("Inference timed out"),
          );

      return response.isNotEmpty
          ? response.first
          : "Error: Model returned an empty recommendation. Switching to fallback...\n\n${_getFallbackDosage(name, weight, rdtResult)}";
    } catch (e) {
      return "⚠️ **Local AI Error:** Using safety fallback logic.\n\n${_getFallbackDosage(name, weight, rdtResult)}";
    }
  }

  /// Rule-based fallback derived from the 2022 Guidelines
  String _getFallbackDosage(String name, double weight, String rdtResult) {
    if (rdtResult.toLowerCase() == 'negative') {
      return "**Recommendation for $name:**\n- No malaria medication required.\n- Investigate other causes of fever.";
    }

    String tableLine = "";
    if (weight < 5) {
      tableLine = "Refer to specialist (weight below 5kg).";
    } else if (weight < 15) {
      tableLine = "1 tablet per dose (Total: 6 tablets over 3 days).";
    } else if (weight < 25) {
      tableLine = "2 tablets per dose (Total: 12 tablets over 3 days).";
    } else if (weight < 35) {
      tableLine = "3 tablets per dose (Total: 18 tablets over 3 days).";
    } else {
      tableLine = "4 tablets per dose (Total: 24 tablets over 3 days).";
    }

    return "**Fallback Recommendation for $name (${weight}kg):**\n"
        "- **Drug:** Artemether-Lumefantrine (20/120mg)\n"
        "- **Dosage:** $tableLine\n"
        "- **Frequency:** Twice Daily (BID)\n"
        "- **Duration:** 3 Days";
  }
}
