# NAFacial - Nigerian Army Facial Verification System

A Flutter application for facial verification, designed to be responsive and consistent across Android, Windows, and web platforms.

![NAFacial Logo](assets/favicon/web/favicon.png)

## Installation

### Prerequisites
- Flutter SDK (version 3.0.0 or higher)
- Dart SDK (version 2.17.0 or higher)
- Android Studio / VS Code with Flutter extensions
- For Windows: Windows 10 or higher
- For Android: Android SDK
- For Web: Chrome browser

### Access the Repository
This repository is private and only accessible to authorized personnel of the Nigerian Army. If you have been granted access, you can clone the repository using your authorized credentials:

```bash
git clone https://github.com/Peemkay/nafacial.git
cd nafacial
```

### Install Dependencies
```bash
flutter pub get
```

### Run the Application
```bash
# For Android
flutter run -d android

# For Windows
flutter run -d windows

# For Web
flutter run -d chrome
```

## Harmonized Design System

This application implements a unified design system that ensures consistent styling and behavior across all platforms while respecting platform-specific conventions:

### Unified Design Approach

1. **Consistent Design Language**
   - Shared color palette, typography, and spacing across all platforms
   - Platform-specific adjustments for optimal user experience
   - Unified component library that adapts to each platform

2. **Platform-Aware Components**
   - Components automatically adjust to the platform they're running on
   - Subtle platform-specific styling (e.g., different border radii on Windows vs. Android)
   - Consistent behavior with platform-appropriate interactions

3. **Single Codebase, Multiple Platforms**
   - One codebase that runs on Android, Windows, and web
   - Platform detection to apply appropriate styling
   - Responsive layouts that work across all form factors

## Responsive Design Implementation

### Key Responsive Features

1. **Adaptive Layouts**
   - Portrait and landscape orientations supported
   - Different layouts for mobile, tablet, and desktop
   - Responsive container sizes and spacing

2. **Responsive Typography**
   - Font sizes adjust based on screen size
   - Text remains readable on all devices

3. **Flexible UI Components**
   - UI elements scale appropriately for different screen sizes
   - Consistent visual hierarchy maintained across devices

4. **Platform-Specific Optimizations**
   - Touch-friendly targets on mobile
   - Keyboard and mouse optimizations for desktop

### Responsive Design Structure

The app uses the following approach to implement responsive design:

- **Responsive Utilities**: Helper functions in `lib/utils/responsive_utils.dart` to determine device size and provide responsive values
- **Responsive Widgets**: Custom widgets in `lib/widgets/responsive_layout.dart` that adapt to different screen sizes
- **Responsive Theme**: Theme definitions in `lib/config/theme.dart` with responsive spacing, font sizes, and other design tokens
- **Adaptive Layouts**: Screen layouts that change based on screen size and orientation

## Testing Responsive Design

To test the responsive design of this application:

### On Physical Devices
1. Connect your device (Android or iOS)
2. Run `flutter run`
3. Test in both portrait and landscape orientations

### On Emulators/Simulators
1. Launch an Android emulator or iOS simulator
2. Run `flutter run -d [device-id]`
3. Test in both portrait and landscape orientations
4. Try different device sizes (phone, tablet)

### On Desktop
1. Run `flutter run -d windows` (or macos/linux)
2. Resize the window to test different screen sizes
3. Test with different window aspect ratios

### On Web
1. Run `flutter run -d chrome`
2. Use browser dev tools to simulate different screen sizes
3. Test with responsive design mode in browser dev tools

## Responsive Design Best Practices Used

1. **Mobile-First Approach**: Designed for mobile first, then enhanced for larger screens
2. **Flexible Grids**: Used Flex layouts for proportional sizing
3. **Media Queries**: Implemented through responsive utility functions
4. **Relative Units**: Used relative sizing instead of fixed pixel values where appropriate
5. **Breakpoints**: Defined logical breakpoints for different device categories
6. **Testing**: Verified on multiple screen sizes and orientations

## Future Responsive Enhancements

- Implement more advanced responsive navigation patterns
- Add responsive data tables for larger screens
- Optimize image loading based on screen size
- Implement advanced responsive animations

## Harmonized Design System Implementation

The application uses a comprehensive design system to ensure consistency across platforms:

### Design System Structure

1. **Core Design Tokens**
   - `lib/config/design_system.dart`: Central repository for all design tokens
   - Platform-specific adjustments for colors, typography, spacing, and more
   - Consistent naming conventions across all platforms

2. **Platform-Aware Components**
   - `lib/widgets/platform_aware_widgets.dart`: Components that adapt to each platform
   - Consistent API with platform-specific implementations
   - Automatic detection of platform for appropriate styling

3. **Responsive Utilities**
   - `lib/utils/responsive_utils.dart`: Utilities for responsive design
   - Screen size detection and breakpoints
   - Platform-specific responsive behavior

### Platform-Specific Considerations

#### Android
- Touch-optimized UI elements with appropriate sizing
- Material Design influences with platform-specific adjustments
- Optimized for both phone and tablet form factors

#### Windows
- Larger touch targets for desktop interaction
- Appropriate spacing for mouse and keyboard input
- Window resizing support with fluid layout adjustments

#### Web
- Browser-specific optimizations
- Responsive design for various viewport sizes
- Progressive enhancement for different browser capabilities

### Testing the Harmonized Design

To verify the harmonized design across platforms:

1. **Run on Multiple Platforms**
   ```
   flutter run -d windows  # For Windows
   flutter run -d chrome   # For Web
   flutter run -d android  # For Android
   ```

2. **Verify Consistent Experience**
   - Check that colors, typography, and spacing are consistent
   - Verify that components adapt appropriately to each platform
   - Ensure that the application is usable on all platforms

3. **Test Platform-Specific Features**
   - Test touch interactions on Android
   - Test mouse and keyboard interactions on Windows
   - Test browser-specific features on Web

## Getting Started with Flutter

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Contributing

This is a proprietary project of the Nigerian Army. Contributions are limited to authorized personnel only. If you are authorized to contribute to this project, please follow the internal contribution guidelines provided by the Nigerian Army.

Unauthorized contributions will not be accepted.

## Copyright Notice

This software is proprietary and confidential. Copyright © 2024 Nigerian Army. All Rights Reserved.

Unauthorized copying, distribution, modification, public display, or public performance of this software is strictly prohibited. See the [COPYRIGHT](COPYRIGHT) file for details.

## Contact

Nigerian Army IT Department - [Contact Information]

Project Link: [https://github.com/Peemkay/nafacial](https://github.com/Peemkay/nafacial)
