# MalariaGuard: Malaria Clinical Decision Support Tool 🩺✨

[![Quality Gate](https://github.com/hizkyas/Malaria-Clinical-Decision-Support-Tool/actions/workflows/quality_gate.yml/badge.svg)](https://github.com/hizkyas/Malaria-Clinical-Decision-Support-Tool/actions/workflows/quality_gate.yml)
[![Android Build](https://github.com/hizkyas/Malaria-Clinical-Decision-Support-Tool/actions/workflows/build_android.yml/badge.svg)](https://github.com/hizkyas/Malaria-Clinical-Decision-Support-Tool/actions/workflows/build_android.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-emerald.svg)](https://opensource.org/licenses/MIT)

**MalariaGuard** is an advanced, AI-powered diagnostic and treatment support tool specifically engineered for **Ethiopian Health Extension Workers (HEWs)**. It focuses on decentralized healthcare, operating fully offline to provide protocol-based guidance in rural and low-resource environments.

---

## 🌟 Vision & Key Features

MalariaGuard transforms a standard smartphone into a life-saving clinical assistant by integrating four core technologies:

### 1. Local AI Intelligence (Gemma 4)
- **Clinical Reasoning**: Uses a specialized on-device LLM to process patient data.
- **Protocol Adherence**: Strictly follows the **2022 Ethiopian National Malaria Guidelines**.
- **100% Offline**: No internet required for AI inference, ensuring reliability in the field.

### 2. Automatic RDT Scanning (Computer Vision)
- **Visual Diagnostics**: Uses the device camera to analyze Rapid Diagnostic Test (RDT) strips.
- **Auto-result**: Instantly identifies "Positive" (2 bands) or "Negative" (1 band) results and feeds them into the clinical workflow.

### 3. Voice-Assisted Workflow
- **Speech-to-Text**: Hands-free data entry for patient names and symptoms in **Amharic**.
- **Audio Guard (TTS)**: Reads dosage instructions and clinical warnings aloud in the local language to double-check safety.

### 4. Safety-First Infrastructure
- **Emergency Detectors**: Constant monitoring for "Danger Signs" (Unconscious, Convulsions) to trigger immediate hospital referral alerts.
- **Persistent Logs**: Local SQLite history to track community health trends and patient follow-ups.

---

## 📂 Project Structure

```bash
malariaguard/
├── .github/workflows/    # CI/CD Automation (Quality Gates & APK Builds)
├── malariaguard_app/     # Core Flutter Mobile Application
│   ├── assets/           # Medical protocols & assets
│   ├── lib/              # Feature-rich clinical code
│   └── android/          # Optimized Android configuration (API 34)
├── test_logic.py         # Root-level clinical logic validation scripts
└── .gitignore            # Multi-language project ignore settings
```

## 🚀 CI/CD Pipeline

This project utilizes a professional DevOps pipeline:
- **Quality Gate**: Automated formatting, static analysis, and testing on every Pull Request.
- **Continuous Delivery**: Automated Android APK generation on every push to `main`.
- **Dependency Audit**: Weekly automated security scans for third-party libraries.

---

## 🛠️ Setup & Contribution

We welcome contributions from health workers, AI researchers, and developers!

1.  **Clone the Repo**: `git clone https://github.com/hizkyas/Malaria-Clinical-Decision-Support-Tool.git`
2.  **Flutter Setup**: Ensure Flutter 3.4+ is installed.
3.  **Read Guidelines**: See [CONTRIBUTING.md](./malariaguard_app/CONTRIBUTING.md) for code quality standards.

---
*Empowering community health workers with AI for a malaria-free Ethiopia. 🇪🇹*
