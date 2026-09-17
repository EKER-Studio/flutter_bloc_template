# Security Policy

## Supported Versions

Only the latest released version of the application receives security updates.

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

We take the security and privacy of our users very seriously.

If you believe you have discovered a security vulnerability in this project, please do NOT create a public issue on GitHub. Instead, report it privately:

1. Send an email to **security@example.com** (or open a private security advisory on GitHub).
2. Include a detailed description of the vulnerability, steps to reproduce, and potential impact.
3. Allow up to 48 hours for an initial response from the development team.
4. We will coordinate a fix and release before any public disclosure.

## Security Architecture Highlights

- **Local-First & Offline:** Application data remains strictly on the device unless explicitly exported or synchronized by the user.
- **Hardware-Backed Protection:** Sensitive keychains and tokens utilize platform-native hardware security modules (Android Keystore / iOS Keychain).
- **Privacy-First Telemetry:** Any telemetry or analytics must never include raw personal information, credentials, or sensitive user data.
