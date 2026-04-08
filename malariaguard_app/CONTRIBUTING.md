# Contributing to MalariaGuard

Thank you for your interest in contributing to the **MalariaGuard** Clinical Decision Support Tool! Every contribution helps improve patient care for communities.

## Code Quality Standards

Before submitting a Pull Request, please ensure your changes pass our local quality checks:

1.  **Format**: Ensure your code is properly formatted.
    ```bash
    flutter format .
    ```
2.  **Analysis**: Check for linting errors and technical debt.
    ```bash
    flutter analyze
    ```
3.  **Tests**: All unit and widget tests must pass.
    ```bash
    flutter test
    ```

## CI/CD Pipeline

We use GitHub Actions to enforce high standards:
- **Quality Gate**: Every PR triggers an automated run of the format, analysis, and test suites.
- **Android Build**: Every push to the `main` branch triggers an automated release build of the APK.

## Reporting Issues

If you find a bug or have a feature request, please open an issue in the repository. Provide as much detail as possible, including your device model and Android version.

## Proposing Changes

1.  Fork the repository.
2.  Create a feature branch (`git checkout -b feature/amazing-feature`).
3.  Commit your changes.
4.  Push to your fork and open a Pull Request.

Together, we can build tools that save lives! 🩺✨
