# Design System

## Overview

The Organizer app follows a modern, clean design aesthetic inspired by contemporary e-commerce applications. The design emphasizes visual content (item photos) while maintaining excellent usability and accessibility.

**Design Inspiration**: [Furniture E-Commerce App](https://dribbble.com/shots/26804818-Furniture-E-Commerce-App)

## Color Palette

### Primary Colors
```dart
// Main brand color - Trust and reliability
Primary: #2196F3 (Blue)
Primary Light: #64B5F6
Primary Dark: #1976D2

// Accent color - Actions and highlights
Accent: #FF6F00 (Deep Orange)
Accent Light: #FF9800
Accent Dark: #E65100
```

### Neutral Colors
```dart
// Backgrounds and surfaces
Background: #FFFFFF
Surface: #F5F5F5
Card: #FFFFFF

// Text colors
Text Primary: #212121
Text Secondary: #757575
Text Hint: #BDBDBD

// Dividers and borders
Divider: #E0E0E0
Border: #EEEEEE
```

### Semantic Colors
```dart
// Status and feedback
Success: #4CAF50
Warning: #FFC107
Error: #F44336
Info: #2196F3

// Special states
Gift: #E91E63 (Pink - for gift items)
Bought: #2196F3 (Blue - for purchased items)
```

## Typography

### Font Family
- **Primary**: SF Pro Display (iOS) / Roboto (Android)
- **Alternative**: Inter or Poppins for a more modern look

### Type Scale
```dart
// Headings
h1: 32px, Bold, Letter spacing: -0.5
h2: 28px, Bold, Letter spacing: -0.5
h3: 24px, SemiBold, Letter spacing: 0
h4: 20px, SemiBold, Letter spacing: 0.15
h5: 18px, Medium, Letter spacing: 0.15
h6: 16px, Medium, Letter spacing: 0.15

// Body
body1: 16px, Regular, Letter spacing: 0.5, Line height: 24px
body2: 14px, Regular, Letter spacing: 0.25, Line height: 20px

// Captions and labels
caption: 12px, Regular, Letter spacing: 0.4
overline: 10px, Medium, Letter spacing: 1.5, Uppercase
button: 14px, Medium, Letter spacing: 1.25, Uppercase
```

## Spacing System

Based on 8px grid system:
```dart
xs: 4px
sm: 8px
md: 16px
lg: 24px
xl: 32px
xxl: 48px
```

### Common Spacings
- Card padding: 16px
- Screen padding: 16px (mobile), 24px (tablet)
- Section spacing: 24px
- Item spacing in grids: 12px
- Button padding: 12px vertical, 24px horizontal

## Components

### 1. Cards

#### List Card
- **Size**: Full width, height ~120px
- **Shadow**: Elevation 2
- **Border Radius**: 12px
- **Content**:
  - Cover image (if available)
  - List name (h5)
  - Item count (body2, secondary)
  - Last updated (caption, hint)

#### Item Card
- **Size**: Square or 3:4 ratio
- **Shadow**: Elevation 1
- **Border Radius**: 12px
- **Content**:
  - Item image (fills card)
  - Overlay gradient at bottom
  - Item name (body1, white)
  - Value badge (if bought)

#### Stat Card
- **Size**: Small, fixed height 80px
- **Shadow**: None
- **Background**: Surface color
- **Border Radius**: 8px
- **Content**:
  - Icon (24px)
  - Value (h4)
  - Label (body2)

### 2. Buttons

#### Primary Button
```dart
Height: 48px
Background: Primary color
Text: White, button style
Border Radius: 24px (fully rounded)
Shadow: Elevation 2
```

#### Secondary Button
```dart
Height: 48px
Background: Transparent
Text: Primary color, button style
Border: 2px solid primary
Border Radius: 24px
```

#### Icon Button
```dart
Size: 48x48px
Background: Surface or transparent
Icon: 24px, primary or secondary color
Border Radius: 24px (circular)
```

#### Floating Action Button (FAB)
```dart
Size: 56x56px
Background: Accent color
Icon: 24px, white
Shadow: Elevation 6
Position: Bottom right, 16px margin
```

### 3. Input Fields

#### Text Field
```dart
Height: 56px
Border: 1px solid border color
Border Radius: 8px
Padding: 16px
Font: body1

// Focused state
Border: 2px solid primary
Border Radius: 8px
```

#### Search Bar
```dart
Height: 48px
Background: Surface color
Border Radius: 24px (fully rounded)
Padding: 12px 16px
Icon: 20px, hint color
Font: body1
```

### 4. App Bars

#### Top App Bar
```dart
Height: 56px
Background: White or transparent
Shadow: Elevation 0 (use divider instead)
Title: h6, text primary
Icons: 24px, text primary
```

#### Bottom Navigation Bar
```dart
Height: 56px
Background: White
Shadow: Elevation 8 (top shadow)
Icons: 24px
Labels: caption
Active color: Primary
Inactive color: Text secondary
```

### 5. Lists and Grids

#### Grid View (Items)
```dart
Columns: 2 (mobile), 3-4 (tablet)
Aspect Ratio: 3:4
Spacing: 12px
Padding: 16px
```

#### List View (Lists)
```dart
Item height: ~100-120px
Divider: 1px, divider color
Padding: 16px horizontal
Spacing: 8px between items
```

### 6. Images

#### Item Images
```dart
Aspect Ratio: 1:1 or 3:4
Border Radius: 12px
Placeholder: Gray gradient with icon
Error: Error color background with icon
Loading: Shimmer effect
```

#### Cover Images
```dart
Aspect Ratio: 16:9
Border Radius: 12px (top only for cards)
Overlay: Gradient for readability
```

### 7. Badges and Chips

#### Value Badge
```dart
Height: 24px
Background: Success or primary color
Text: White, caption style
Border Radius: 12px
Padding: 4px 8px
```

#### Filter Chip
```dart
Height: 32px
Background: Surface (inactive), Primary (active)
Text: body2, text primary (inactive), white (active)
Border Radius: 16px
Padding: 8px 12px
```

#### Status Badge
```dart
Size: 8px (dot) or 24px (with text)
Colors: Success, warning, error, info
Position: Top right corner of card
```

## Icons

### Icon Set
Use Material Icons (included with Flutter) or custom icon font

### Common Icons
- Home: home
- Lists: view_list / grid_view
- Camera: camera_alt
- Search: search
- Add: add
- Edit: edit
- Delete: delete
- Settings: settings
- Filter: filter_list
- Sort: sort
- Share: share
- Info: info_outline
- Gift: card_giftcard
- Shopping: shopping_cart

### Icon Sizes
```dart
Small: 16px
Medium: 24px (default)
Large: 32px
Extra Large: 48px
```

## Animations

### Transitions
- Screen transitions: 300ms, ease-in-out
- Card elevation changes: 200ms
- Button press: 150ms
- Shimmer loading: 1500ms loop

### Micro-interactions
- Button press: Scale down to 0.95, then spring back
- Card tap: Scale to 0.98
- FAB tap: Ripple effect + slight rotation
- Pull to refresh: Custom indicator animation
- Swipe actions: Reveal background with icon

## Accessibility

### Color Contrast
- Minimum contrast ratio: 4.5:1 for text
- Minimum contrast ratio: 3:1 for UI components
- Test all color combinations

### Touch Targets
- Minimum size: 48x48px
- Spacing between targets: 8px minimum

### Text Scaling
- Support system text scaling up to 200%
- Test layouts with large text sizes

### Screen Readers
- Provide semantic labels for all interactive elements
- Group related content
- Announce state changes

## Responsive Design

### Breakpoints
```dart
Mobile: < 600px
Tablet: 600px - 1024px
Desktop: > 1024px (future consideration)
```

### Layout Adaptations
- **Mobile**: Single column, bottom navigation
- **Tablet**: 2-3 columns, side navigation option
- **Landscape**: Optimize for wider screens

## Dark Mode (Future Enhancement)

### Dark Color Palette
```dart
Background: #121212
Surface: #1E1E1E
Card: #2C2C2C
Primary: #90CAF9 (Lighter blue)
Accent: #FFB74D (Lighter orange)
Text Primary: #FFFFFF
Text Secondary: #B0B0B0
```

## Design Tokens (Flutter Implementation)

```dart
// lib/utils/theme/app_theme.dart
class AppTheme {
  // Colors
  static const primaryColor = Color(0xFF2196F3);
  static const accentColor = Color(0xFFFF6F00);
  static const backgroundColor = Color(0xFFFFFFFF);
  
  // Typography
  static const fontFamily = 'Roboto'; // Or custom font
  
  // Spacing
  static const spacingXs = 4.0;
  static const spacingS = 8.0;
  static const spacingM = 16.0;
  static const spacingL = 24.0;
  static const spacingXl = 32.0;
  
  // Border Radius
  static const radiusS = 8.0;
  static const radiusM = 12.0;
  static const radiusL = 24.0;
  
  // Elevation
  static const elevation1 = 2.0;
  static const elevation2 = 4.0;
  static const elevation3 = 8.0;
  
  // Theme Data
  static ThemeData lightTheme() {
    return ThemeData(
      primaryColor: primaryColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
      ),
      fontFamily: fontFamily,
      cardTheme: CardTheme(
        elevation: elevation1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
      ),
      // ... more theme configuration
    );
  }
}
```

## Implementation Checklist

- [ ] Set up theme configuration
- [ ] Create color constants
- [ ] Define text styles
- [ ] Build reusable widget components
- [ ] Implement spacing system
- [ ] Test on different screen sizes
- [ ] Verify accessibility compliance
- [ ] Create component showcase (Storybook)
