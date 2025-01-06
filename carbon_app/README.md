# Carbon App Boilerplate

## Overview
A Flutter boilerplate project following the MVVM (Model-View-ViewModel) architecture, designed to provide a robust starting point for Flutter applications.

## Features
- MVVM Architecture
- Modular Project Structure
- Dependency Injection with Provider
- Multiple Environment Support (Development, Staging, Production)
- Comprehensive Routing Setup
- Basic Theme Configuration

## Project Structure
```
lib/
├── config/           # App configuration files
├── data/             # Data layer (repositories, services)
│   ├── model/        # Data models
│   ├── repositories/ # Data repositories
│   └── services/     # Network and other services
├── domain/           # Domain models and business logic
│   └── models/       # Domain-specific models
├── routing/          # App navigation and routing
├── ui/               # User interface
│   ├── core/         # Shared UI components
│   │   ├── themes/   # App theming
│   │   └── ui/       # Shared widgets
│   └── <feature>/    # Feature-specific UI components
│       ├── view/     # Screens
│       └── viewmodel/# View models
└── utils/            # Utility classes and helpers
```

## Getting Started

### Prerequisites
- Flutter SDK
- Dart SDK
- Android Studio or VS Code

### Installation
1. Clone the repository
```bash
git clone https://github.com/yourusername/carbon-app-boilerplate.git
cd carbon-app-boilerplate
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the app
```bash
flutter run
```

## Development

### Running Different Environments
- Development: `flutter run lib/main_development.dart`
- Staging: `flutter run lib/main_staging.dart`
- Production: `flutter run lib/main.dart`

### Testing
```bash
flutter test
```

## Contributing
1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License
Distributed under the MIT License. See `LICENSE` for more information.

## Contact
Your Name - your.email@example.com

Project Link: [https://github.com/yourusername/carbon-app-boilerplate](https://github.com/yourusername/carbon-app-boilerplate)
