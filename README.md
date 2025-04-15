# Endgame - Application Management System

## Overview
A secure Flutter application implementing role-based access control with admin verification system. Built with custom backend integration for enhanced security and control.

## Features

### User Features
- Secure Authentication
- Profile Management
- Document Upload System
- Real-time Verification Status
- Push Notifications
- Access Level Management
- Theme Customization

### Admin Features
- Verification Management Dashboard
- User Access Control
- Document Review System
- Activity Monitoring
- Status Management
- Reporting Tools

## Technical Stack

### Frontend (Flutter)
- **State Management**: Provider
- **Navigation**: Motion Tab Bar, Curved Navigation Bar
- **Network**: Dio, HTTP
- **Storage**: 
  - Shared Preferences (Local Storage)
  - Path Provider (File Management)
  - File Picker (Document Selection)
  
- **UI Components**:
  - Card Swiper
  - Social Media Buttons
  - Custom Material Components
  
- **Utilities**:
  - URL Launcher
  - Device Info Plus
  - Permission Handler
  - Flutter dotenv
  - PDF & Printing Support

### Security Features
- JWT Based Authentication
- Secure File Storage
- Encrypted Data Transfer
- Session Management
- Access Control

## Setup & Installation

### Prerequisites
- Flutter SDK ≥ 3.5.4
- Dart SDK
- Android Studio / VS Code
- Required environment variables

### Installation Steps

1. Clone the repository:
```bash
git clone https://github.com/Ash469/AssamApp.git
```

2. Install dependencies:
```bash
cd endgame
flutter pub get
```

3. Configure environment:
- Create `.env` file in root directory
- Add required configuration (refer to .env.example)

4. Run the application:
```bash
flutter run
```

## Building Release APK

```bash
flutter build apk --release
```
APK will be generated at: `build/app/outputs/flutter-apk/app-release.apk`

## Download

[⬇️ Download Latest Release](https://github.com/Ash469/AssamApp/releases/download/v0.0/app-release.apk)

## Application Flow

### User Journey
1. Download and install application
2. Register new account
3. Submit verification documents
4. Wait for admin verification
5. Access granted upon approval

### Admin Journey
1. Login with admin credentials
2. Access admin dashboard
3. Review pending verifications
4. Manage user access
5. Monitor system activity

## Version
Current Version: 1.0.0

## License
This project is proprietary software. All rights reserved.

## Support
For support inquiries, please contact support@endgame.com

---
Note: This is a secure application with proprietary backend implementation. API documentation and database schema are provided separately to authorized personnel.
