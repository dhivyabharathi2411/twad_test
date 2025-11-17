# TWAD - Tamil Nadu Water Supply and Drainage Board

A Flutter application for the Tamil Nadu Water Supply and Drainage Board (TWAD) with modern UI design and clean architecture.

## 🏗️ Project Structure

```
lib/
├── constants/
│   └── app_constants.dart      # App-wide constants and configurations
├── theme/
│   └── app_theme.dart          # App theme configuration
├── widgets/
│   └── twad_logo.dart          # TWAD logo widget
├── pages/
│   ├── login_page.dart         # Login page with authentication
│   └── otp_page.dart           # OTP verification page
└── main.dart                   # Main application entry point
```

## 🎨 Design System

### Colors
- **Primary Color**: Blue (`#2196F3`)
- **Secondary Color**: Purple (`#9C27B0`)
- **Accent Color**: Green (`#4CAF50`)
- **Error Color**: Red (`#F44336`)
- **Background**: Light Grey (`#F5F5F5`)
- **Card Color**: White (`#FFFFFF`)

### Typography
- **Title**: 20px, Bold, Primary Text Color
- **Subtitle**: 16px, Medium, Accent Color
- **Body**: 14px, Regular, Secondary Text Color
- **Button**: 16px, Bold, White
- **Link**: 14px, Medium, Primary Color

### Spacing
- **Default Padding**: 20px
- **Card Padding**: 30px
- **Border Radius**: 12px
- **Card Border Radius**: 20px

## 🚀 Features

### Login Page
- Modern card-based design
- Mobile number input field
- Sign in with OTP option
- Create account option
- TWAD branding with logo
- Simplified and clean interface

### OTP Page
- 6-digit OTP input
- 5-minute countdown timer
- Resend OTP functionality
- OTP verification
- Back navigation
- Consistent branding

## 📱 Screenshots

### Login Page
- Clean, modern interface
- Responsive design
- Material Design 3 components
- TWAD logo and branding

### OTP Page
- Secure OTP input
- Timer display
- Gradient buttons
- Error handling

## 🛠️ Technical Implementation

### Architecture
- **Clean Architecture**: Separation of concerns
- **Constants Management**: Centralized configuration
- **Theme System**: Consistent styling
- **Responsive Design**: Works on all screen sizes

### Code Standards
- **Dart Style Guide**: Following official Dart conventions
- **Documentation**: Comprehensive code comments
- **Error Handling**: Proper validation and user feedback
- **Performance**: Optimized widget rebuilds

### Dependencies
- **Flutter**: Latest stable version
- **Material Design**: Material 3 components
- **Custom Theme**: Consistent app-wide styling

## 🔧 Setup Instructions

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd TWAD
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

## 📋 Development Guidelines

### File Naming
- Use snake_case for file names
- Use PascalCase for class names
- Use camelCase for variables and methods

### Code Organization
- Group related functionality in directories
- Use meaningful file and folder names
- Keep files focused on single responsibility

### Documentation
- Add comments for complex logic
- Document public methods and classes
- Use clear and descriptive names

### Error Handling
- Implement proper validation
- Show user-friendly error messages
- Handle edge cases gracefully

## 🎯 Future Enhancements

- [ ] User registration flow
- [ ] Dashboard implementation
- [ ] Profile management
- [ ] Settings page
- [ ] Dark theme support
- [ ] Multi-language support
- [ ] Push notifications
- [ ] Offline functionality

## 📄 License

This project is developed for the Tamil Nadu Water Supply and Drainage Board.

## 👥 Contributing

1. Follow the established code standards
2. Add proper documentation
3. Test thoroughly before submitting
4. Use meaningful commit messages

## 📞 Support

For technical support or questions, please contact the development team.
