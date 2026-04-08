# MalariaGuard 🩺
[![Quality Gate](https://github.com/hizkyas/Malaria-Clinical-Decision-Support-Tool/actions/workflows/quality_gate.yml/badge.svg)](https://github.com/hizkyas/Malaria-Clinical-Decision-Support-Tool/actions/workflows/quality_gate.yml)
[![Android Build](https://github.com/hizkyas/Malaria-Clinical-Decision-Support-Tool/actions/workflows/build_android.yml/badge.svg)](https://github.com/hizkyas/Malaria-Clinical-Decision-Support-Tool/actions/workflows/build_android.yml)

MalariaGuard is a clinical decision support tool designed for **Ethiopian Health Extension Workers**. It combines local AI (Gemma 4), computer vision for RDT scanning, and voice-assisted workflows to provide accurate, protocol-based malaria treatment in rural communities.

## ✨ Key Features

- **Local AI Guidance**: Uses on-device Gemma 4 for clinical recommendations.
- **Auto-RDT Scanning**: Computer vision logic to detect malaria test results.
- **Voice Assistant**: Speech-to-Text and Amharic TTS instructions.
- **Patient History**: Persistent SQLite storage for diagnosis tracking.

## 🚀 CI/CD Pipeline

This repository is equipped with a professional CI/CD pipeline using **GitHub Actions**:

- **Quality Gate**: Automatically lint, format, and test every pull request.
- **Android Release**: Automatically builds and uploads a release APK on every push to `main`.
- **Dependency Audit**: Weekly automated security checks for outdated packages.

## 🛠️ Development

For instructions on how to contribute and run local quality checks, please see [CONTRIBUTING.md](./CONTRIBUTING.md).

---
*Built with ❤️ for Health Tech in Ethiopia.*
