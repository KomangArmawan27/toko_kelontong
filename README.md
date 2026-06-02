# 🏪 Toko Kelontong

A comprehensive Flutter application for managing small grocery stores and general merchandise businesses. Toko Kelontong is an inventory and point-of-sale management system designed to streamline daily operations for small business owners.

## ✨ Features

- **Authentication System** - Secure user login and registration
- **Dashboard** - Overview of key metrics and business insights
- **Cash Management** - Track cash flow and transactions
- **Inventory Management** - Manage product stock levels and updates
- **Item Master** - Maintain product catalog with detailed information
- **Reports** - Generate business reports and analytics
- **Local Database** - Fast offline access with Isar database
- **API Integration** - Seamless backend synchronization

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) 3.11.5+
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Routing**: [GoRouter](https://pub.dev/packages/go_router)
- **Local Database**: [Isar](https://pub.dev/packages/isar)
- **Networking**: [HTTP](https://pub.dev/packages/http)
- **File Storage**: [Path Provider](https://pub.dev/packages/path_provider)
- **Build Tool**: [Build Runner](https://pub.dev/packages/build_runner)

## 📁 Project Structure

```
lib/
├── main.dart              # Application entry point
├── bloc/                  # Business logic components
├── core/
│   ├── constants/         # App constants
│   ├── theme/             # App theming
│   └── utils/             # Utility functions
├── database/
│   └── isar_service.dart  # Isar database service
├── models/
│   ├── cash_model.dart
│   ├── item_model.dart
│   └── stock_model.dart
├── providers/             # State management providers
│   ├── cash_provider.dart
│   ├── item_provider.dart
│   └── stock_provider.dart
├── routes/
│   └── app_router.dart    # Navigation routing
├── screens/               # UI screens
│   ├── auth/              # Authentication screens
│   ├── cash/              # Cash management screens
│   ├── dashboard/         # Dashboard screen
│   ├── items/             # Item management screens
│   ├── reports/           # Reports screens
│   └── stock/             # Stock management screens
├── services/
│   ├── api_client.dart    # API client
│   └── api_data.dart      # API data models
├── widget/                # Reusable widgets
└── widgets/
    ├── app_drawer.dart
    └── dashboard_card.dart
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.11.5 or higher
- Dart SDK
- Android Studio or Xcode (for mobile development)
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd toko_kelontong
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code (Isar models)**
   ```bash
   flutter pub run build_runner build
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 💻 Development

### Running Tests
```bash
flutter test
```

### Building for Production

**Android:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

**Web:**
```bash
flutter build web --release
```

### Code Generation

When you modify data models, regenerate code with:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## 📱 Supported Platforms

- ✅ Android
- ✅ Web

## 🔐 Authentication

The app uses a custom authentication system with:
- User registration
- Secure login
- Session management via providers
- Protected routes

## 💾 Local Database

Uses **Isar** for local data persistence:
- Fast, efficient NoSQL database
- Offline-first capability
- Automatic migration

## 🌐 API Integration

The app communicates with a backend API through:
- `ApiClient` for HTTP requests
- `ApiData` for data serialization/deserialization
- JSON-based request/response format

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📧 Support

For issues, questions, or contributions, please contact the development team or create an issue in the repository.

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

**Built with ❤️ using Flutter**
