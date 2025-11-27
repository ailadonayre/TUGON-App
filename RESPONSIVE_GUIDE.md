# Responsive Design Guide for TUGON App

This guide explains how to make your Flutter app responsive across all screen sizes (mobile, tablet, and desktop).

## Overview

The app now includes a comprehensive responsive utility system that automatically adapts UI elements based on screen size.

## Files Added

- `lib/utils/responsive.dart` - Main responsive utility class

## Quick Start

### 1. Basic Usage

```dart
import '../../utils/responsive.dart';

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    return Container(
      padding: responsive.pagePadding,  // Auto-adjusts padding
      child: Text(
        'Hello World',
        style: TextStyle(fontSize: responsive.fontSize(16)),  // Responsive font size
      ),
    );
  }
}
```

### 2. Using Extension Method

```dart
import '../../utils/responsive.dart';

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Use the extension method for easier access
    final r = context.responsive;

    return Container(
      width: r.wp(80),  // 80% of screen width
      height: r.hp(50), // 50% of screen height
    );
  }
}
```

## Responsive Methods

### Screen Information

```dart
final responsive = Responsive(context);

// Screen dimensions
double width = responsive.screenWidth;
double height = responsive.screenHeight;

// Device type detection
bool isMobile = responsive.isMobile;      // < 600px
bool isTablet = responsive.isTablet;      // 600px - 900px
bool isDesktop = responsive.isDesktop;    // > 900px

// Orientation
bool isPortrait = responsive.isPortrait;
bool isLandscape = responsive.isLandscape;
```

### Sizing Methods

```dart
// Percentage-based sizing
double width = responsive.wp(50);   // 50% of screen width
double height = responsive.hp(30);  // 30% of screen height

// Responsive spacing (mobile: 1x, tablet: 1.2x, desktop: 1.5x)
double space = responsive.spacing(16);

// Responsive font size (scales with screen width)
double fontSize = responsive.fontSize(16);
double fontSizeSp = responsive.sp(16);  // Alternative

// Responsive icon size
double iconSize = responsive.iconSize(24);

// Responsive border radius
double radius = responsive.radius(12);
```

### Pre-defined Responsive Values

```dart
// Padding presets
EdgeInsets pagePadding = responsive.pagePadding;
// Mobile: 16, Tablet: 24, Desktop: 32

EdgeInsets cardPadding = responsive.cardPadding;
// Mobile: 16, Tablet: 20, Desktop: 24

// Maximum content width (for centering on large screens)
double maxWidth = responsive.maxContentWidth;
// Mobile: full width, Tablet: 800, Desktop: 1200

// Grid columns
int columns = responsive.gridColumns;
// Mobile: 1, Tablet: 2, Desktop: 4

// Safe area
EdgeInsets safeArea = responsive.safeAreaPadding;

// Keyboard visibility
bool isKeyboardOpen = responsive.isKeyboardVisible;
```

### Value Based on Screen Size

```dart
// Return different values based on screen size
final buttonHeight = responsive.valueBasedOnSize<double>(
  mobile: 48.0,
  tablet: 56.0,
  desktop: 64.0,
);
```

## Responsive Widgets

### 1. ResponsiveBuilder

Rebuilds when screen size changes:

```dart
ResponsiveBuilder(
  builder: (context, responsive) {
    return Container(
      padding: responsive.pagePadding,
      child: Text('Responsive Content'),
    );
  },
)
```

### 2. ResponsiveLayout

Show different widgets for different screen sizes:

```dart
ResponsiveLayout(
  mobile: MobileLayout(),
  tablet: TabletLayout(),    // Optional
  desktop: DesktopLayout(),  // Optional
)
```

If tablet/desktop are not provided, it falls back to mobile.

### 3. ResponsiveContainer

Automatically centers content on larger screens:

```dart
ResponsiveContainer(
  child: Column(
    children: [
      // Your content here
      // Will be centered and max-width constrained on desktop/tablet
    ],
  ),
)
```

## Best Practices

### 1. Use Responsive Sizing Everywhere

❌ **Bad:**
```dart
Container(
  width: 200,
  height: 100,
  padding: EdgeInsets.all(16),
  child: Text(
    'Hello',
    style: TextStyle(fontSize: 18),
  ),
)
```

✅ **Good:**
```dart
final r = context.responsive;

Container(
  width: r.wp(50),
  height: r.spacing(100),
  padding: r.pagePadding,
  child: Text(
    'Hello',
    style: TextStyle(fontSize: r.fontSize(18)),
  ),
)
```

### 2. Use Percentage for Dynamic Sizing

```dart
// Instead of fixed width
width: 300,

// Use percentage
width: responsive.wp(80),  // 80% of screen width
```

### 3. Use Spacing Method for Consistent Scaling

```dart
// All spacing should use responsive.spacing()
SizedBox(height: responsive.spacing(20)),
padding: EdgeInsets.all(responsive.spacing(16)),
```

### 4. Test on Multiple Screen Sizes

Use Flutter DevTools to test on different screen sizes:
- iPhone SE (375x667) - Small mobile
- iPhone 14 Pro (393x852) - Standard mobile
- iPad (768x1024) - Tablet
- Desktop (1920x1080) - Desktop

### 5. Wrap Screens with ResponsiveContainer

For full-screen layouts that should center on desktop:

```dart
Scaffold(
  body: ResponsiveContainer(
    child: YourContent(),
  ),
)
```

## Common Patterns

### Responsive Grid

```dart
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: context.responsive.gridColumns,
    crossAxisSpacing: context.responsive.spacing(16),
    mainAxisSpacing: context.responsive.spacing(16),
  ),
  itemBuilder: (context, index) => YourGridItem(),
)
```

### Responsive Card

```dart
Card(
  margin: responsive.pagePadding,
  child: Padding(
    padding: responsive.cardPadding,
    child: Column(
      children: [
        Icon(Icons.star, size: responsive.iconSize(32)),
        SizedBox(height: responsive.spacing(16)),
        Text(
          'Title',
          style: TextStyle(fontSize: responsive.fontSize(20)),
        ),
      ],
    ),
  ),
)
```

### Responsive Button

```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    padding: EdgeInsets.symmetric(
      horizontal: responsive.spacing(32),
      vertical: responsive.spacing(16),
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(responsive.radius(12)),
    ),
  ),
  child: Text(
    'Button',
    style: TextStyle(fontSize: responsive.fontSize(16)),
  ),
  onPressed: () {},
)
```

### Responsive AppBar

```dart
AppBar(
  title: Text(
    'Title',
    style: TextStyle(fontSize: responsive.fontSize(20)),
  ),
  toolbarHeight: responsive.spacing(56),
  actions: [
    IconButton(
      icon: Icon(
        Icons.settings,
        size: responsive.iconSize(24),
      ),
      onPressed: () {},
    ),
  ],
)
```

## Screen Size Breakpoints

| Device Type | Width Range | Multiplier |
|-------------|-------------|------------|
| Mobile      | < 600px     | 1.0x       |
| Tablet      | 600-900px   | 1.2x       |
| Desktop     | > 900px     | 1.5x       |

## Migration Guide

To update existing screens:

1. Import the responsive utility:
```dart
import '../../utils/responsive.dart';
```

2. Add responsive variable in build method:
```dart
final responsive = Responsive(context);
// or
final r = context.responsive;
```

3. Replace fixed values:
   - `EdgeInsets.all(16)` → `responsive.pagePadding`
   - `fontSize: 18` → `fontSize: responsive.fontSize(18)`
   - `width: 200` → `width: responsive.wp(50)` (percentage-based)
   - `size: 24` → `size: responsive.iconSize(24)`
   - `BorderRadius.circular(12)` → `BorderRadius.circular(responsive.radius(12))`

4. Test on multiple screen sizes!

## Examples

Check these updated screens for reference:
- `lib/screens/onboarding/login_screen.dart` - Login with responsive sizing
- `lib/screens/user/user_dashboard_screen.dart` - Dashboard with responsive navigation
- `lib/screens/user/create_post_screen.dart` - Form with responsive layouts

## Tips

1. **Don't overuse responsive sizing** - Some values (like stroke width, very small spacings) don't need to scale
2. **Use relative sizing** - Prefer `wp()` and `hp()` for dynamic layouts
3. **Test early and often** - Don't wait until the end to test responsiveness
4. **Consider orientation** - Use `isPortrait` and `isLandscape` for orientation-specific layouts
5. **Max width on desktop** - Always use `maxContentWidth` or `ResponsiveContainer` for desktop layouts

## Need Help?

If you're unsure how to make a specific component responsive, refer to:
- The examples in updated screens
- The `responsive.dart` utility file comments
- This guide

Happy coding! 🎉
