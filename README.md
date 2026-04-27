# Dashboard App 🚀

A modern, responsive, and feature-rich Dashboard application built with **Flutter**. This application is designed to manage and monitor data efficiently with a sleek user interface.

## ✨ Features

- **📊 Real-time Analytics**: Monitor key performance indicators at a glance.
- **🔐 Secure Authentication**: Integrated with JWT-based authentication.
- **🌑 Dark/Light Mode**: Premium design with support for both themes.
- **📱 Fully Responsive**: Optimized for Mobile, Tablet, and Desktop.
- **🔄 State Management**: Powered by `flutter_bloc` for clean and scalable logic.
- **🌐 API Integration**: Seamless communication with the backend using `dio`.

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev/)
- **State Management**: [Bloc/Cubit](https://pub.dev/packages/flutter_bloc)
- **Networking**: [Dio](https://pub.dev/packages/dio)
- **Local Storage**: [Shared Preferences](https://pub.dev/packages/shared_preferences)
- **Environment Management**: [flutter_dotenv](https://pub.dev/packages/flutter_dotenv)

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (Latest Version)
- Android Studio / VS Code
- A running backend API

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/dashboard_app.git
   cd dashboard_app
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Environment Setup:**
   - Copy `.env.example` to `.env`.
   - Update the `API_BASE_URL` in `.env` with your backend URL.
   ```bash
   cp .env.example .env
   ```

4. **Run the application:**
   ```bash
   flutter run
   ```

## 📂 Project Structure

```text
lib/
├── core/            # App constants, utils, and common widgets
│   ├── api/         # Dio client and API interceptors
│   ├── theme/       # App styling and color schemes
│   └── storage/     # Local data management
├── features/        # Feature-based architecture
│   ├── auth/        # Login and registration
│   ├── dashboard/   # Main dashboard modules
│   └── settings/    # User preferences
└── main.dart        # Entry point
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
