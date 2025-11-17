# TWAD App Test Suite

This directory contains comprehensive unit tests for the TWAD (Tamil Nadu Water Supply and Drainage Board) Flutter application.

## Test Structure

### Login Page Tests (`pages/login_page_test.dart`)

The login page tests cover all aspects of the login functionality:

#### 🎯 **UI Rendering Tests**
- Verifies all UI elements are displayed correctly
- Checks TWAD logo rendering
- Validates text field configuration
- Ensures proper button styling

#### 📱 **Phone Number Validation Tests**
- Tests empty phone number validation
- Tests invalid phone number format validation
- Tests valid phone number acceptance
- Comprehensive phone number pattern validation

#### 🔐 **OTP Request Tests**
- Tests loading dialog display during OTP request
- Tests successful OTP navigation
- Tests error handling for failed requests
- Tests API exception handling

#### 🧭 **Navigation Tests**
- Tests navigation to registration page
- Tests keyboard submission handling
- Tests back navigation functionality

#### ⚠️ **Error Handling Tests**
- Tests error snackbar display
- Tests proper error styling
- Tests error message formatting

#### 🔄 **State Management Tests**
- Tests input state persistence on validation errors
- Tests loading state management

#### ♿ **Accessibility Tests**
- Tests semantic labels
- Tests keyboard navigation support
- Tests input focus handling

#### 🔍 **Edge Cases Tests**
- Tests very long phone numbers
- Tests special characters in phone numbers
- Tests whitespace handling

#### ⚡ **Performance Tests**
- Tests rapid button tap handling
- Tests graceful error handling under stress

#### 🔗 **Integration Tests**
- Tests complete OTP flow
- Tests navigation flow integrity

## Running the Tests

### Prerequisites
- Flutter SDK installed
- Project dependencies installed (`flutter pub get`)

### Run All Tests
```bash
flutter test
```

### Run Specific Test File
```bash
flutter test test/pages/login_page_test.dart
```

### Run Tests with Coverage
```bash
flutter test --coverage
```

### Run Tests Verbosely
```bash
flutter test --verbose
```

### Run Tests in Watch Mode
```bash
flutter test --watch
```

## Test Coverage

The test suite provides comprehensive coverage for:

- ✅ **UI Components**: All visual elements and their properties
- ✅ **User Interactions**: Tap, text input, navigation
- ✅ **Validation Logic**: Phone number format validation
- ✅ **Error Handling**: Various error scenarios and user feedback
- ✅ **State Management**: Provider state changes and UI updates
- ✅ **Navigation**: Page transitions and routing
- ✅ **Edge Cases**: Unusual input scenarios
- ✅ **Performance**: Stress testing and error resilience

## Test Data

### Valid Phone Numbers
- `9876543210` - Standard valid number
- `6789012345` - Valid number starting with 6
- `7890123456` - Valid number starting with 7
- `8901234567` - Valid number starting with 8
- `9012345678` - Valid number starting with 9

### Invalid Phone Numbers
- `1234567890` - Starts with invalid digit (1)
- `2345678901` - Starts with invalid digit (2)
- `0123456789` - Starts with invalid digit (0)
- `987654321` - Too short (9 digits)
- `98765432101` - Too long (11 digits)
- `abc123def` - Contains letters
- `98765 43210` - Contains spaces
- `98765-43210` - Contains dashes

## Mock Implementation

The tests use a simplified `MockAuthProvider` that:

- Simulates API responses based on phone number input
- Provides different responses for testing various scenarios
- Includes realistic delays to test loading states
- Throws exceptions to test error handling

## Best Practices

1. **Isolation**: Each test is independent and doesn't affect others
2. **Realistic Data**: Tests use realistic phone numbers and scenarios
3. **Comprehensive Coverage**: Tests cover both success and failure paths
4. **Performance**: Tests include stress testing scenarios
5. **Accessibility**: Tests verify proper semantic labeling and navigation

## Adding New Tests

When adding new tests:

1. Follow the existing group structure
2. Use descriptive test names that explain the scenario
3. Test both positive and negative cases
4. Include edge cases and error scenarios
5. Ensure tests are independent and repeatable

## Troubleshooting

### Common Issues

1. **Test Fails Intermittently**: Check for async operations that need proper waiting
2. **Widget Not Found**: Ensure proper `pumpAndSettle()` calls after async operations
3. **Mock Not Working**: Verify mock provider is properly injected
4. **Navigation Issues**: Check if navigation targets exist and are properly imported

### Debug Tips

- Use `flutter test --verbose` for detailed output
- Add `print()` statements in tests for debugging
- Use `tester.pump()` and `tester.pumpAndSettle()` appropriately
- Check widget tree with `tester.dumpRenderTree()`

## Contributing

When contributing to tests:

1. Follow the existing test patterns
2. Ensure 100% test coverage for new features
3. Add tests for any bug fixes
4. Update this README when adding new test categories
5. Run the full test suite before submitting changes
