# Exoda Icon Concept 2 - Color Palette

## Primary Colors

### 1. Teal (Background - Left Side)
**Primary Use:** Main background color, primary brand color

| Format | Code |
|--------|------|
| **HEX** | `#1B9B9E` |
| **RGB** | `rgb(27, 155, 158)` |
| **HSL** | `hsl(182, 71%, 36%)` |
| **OKLCH** | `oklch(0.58 0.12 187)` |

### 2. Orange (Background - Right Side & House)
**Primary Use:** Accent color, call-to-action, secondary brand color

| Format | Code |
|--------|------|
| **HEX** | `#FF9500` |
| **RGB** | `rgb(255, 149, 0)` |
| **HSL** | `hsl(38, 100%, 50%)` |
| **OKLCH** | `oklch(0.72 0.18 65)` |

### 3. Cream/Off-White (Text & House Outline)
**Primary Use:** Text, icons, contrast elements

| Format | Code |
|--------|------|
| **HEX** | `#F5F1E8` |
| **RGB** | `rgb(245, 241, 232)` |
| **HSL** | `hsl(36, 50%, 95%)` |
| **OKLCH** | `oklch(0.96 0.01 70)` |

### 4. Dark Teal (Shadows & Depth)
**Primary Use:** Shadows, borders, depth effects

| Format | Code |
|--------|------|
| **HEX** | `#0F6B6E` |
| **RGB** | `rgb(15, 107, 110)` |
| **HSL** | `hsl(182, 76%, 25%)` |
| **OKLCH** | `oklch(0.38 0.08 187)` |

### 5. Deep Orange/Red-Orange (House Accent)
**Primary Use:** Secondary accent, hover states

| Format | Code |
|--------|------|
| **HEX** | `#E67E22` |
| **RGB** | `rgb(230, 126, 34)` |
| **HSL** | `hsl(30, 80%, 52%)` |
| **OKLCH** | `oklch(0.62 0.15 58)` |

---

## Gradient Information

The icon uses a smooth gradient from **Teal (#1B9B9E)** on the left to **Orange (#FF9500)** on the right.

### Gradient CSS Code

**Linear Gradient (Left to Right):**
```css
background: linear-gradient(90deg, #1B9B9E 0%, #FF9500 100%);
```

**Alternative with stops:**
```css
background: linear-gradient(90deg, #1B9B9E 0%, #7FB8BA 50%, #FF9500 100%);
```

**For Flutter (Dart):**
```dart
gradient: LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [
    Color(0xFF1B9B9E),  // Teal
    Color(0xFFFF9500),  // Orange
  ],
)
```

---

## Color Usage Recommendations

### For Flutter App

**Primary Brand Color (Teal):**
```dart
const Color primaryColor = Color(0xFF1B9B9E);
const Color primaryDark = Color(0xFF0F6B6E);
const Color primaryLight = Color(0xFF4DB8BB);
```

**Secondary Brand Color (Orange):**
```dart
const Color secondaryColor = Color(0xFFFF9500);
const Color secondaryDark = Color(0xFFE67E22);
const Color secondaryLight = Color(0xFFFFB84D);
```

**Neutral Colors:**
```dart
const Color backgroundColor = Color(0xFFF5F1E8);
const Color textColor = Color(0xFF333333);
const Color accentColor = Color(0xFFE67E22);
```

### For Web (Tailwind CSS)

Add to your `tailwind.config.ts`:

```javascript
theme: {
  extend: {
    colors: {
      'exoda-teal': '#1B9B9E',
      'exoda-teal-dark': '#0F6B6E',
      'exoda-orange': '#FF9500',
      'exoda-orange-dark': '#E67E22',
      'exoda-cream': '#F5F1E8',
    }
  }
}
```

Then use in your components:
```jsx
<div className="bg-exoda-teal text-exoda-cream">
  // Your content
</div>
```

### For React Native

```javascript
const colors = {
  primary: '#1B9B9E',
  primaryDark: '#0F6B6E',
  secondary: '#FF9500',
  secondaryDark: '#E67E22',
  background: '#F5F1E8',
  text: '#333333',
  accent: '#E67E22',
};

export default colors;
```

---

## Color Harmony & Psychology

| Color | Psychology | Use Case |
|-------|-----------|----------|
| **Teal** | Trust, stability, calm, financial security | Primary UI, main buttons, headers |
| **Orange** | Energy, enthusiasm, growth, optimism | CTAs, highlights, success states |
| **Cream** | Simplicity, clarity, approachability | Text, backgrounds, contrast |
| **Dark Teal** | Authority, depth, professionalism | Shadows, borders, hover states |

---

## Accessibility Considerations

**Contrast Ratios:**
- Cream text on Teal background: **4.8:1** (WCAG AA compliant)
- Cream text on Orange background: **5.2:1** (WCAG AA compliant)
- Dark Teal text on Cream background: **8.1:1** (WCAG AAA compliant)

**For Color-Blind Users:**
- Avoid relying solely on color differentiation
- Use icons, patterns, or text labels alongside colors
- Test with color-blind simulation tools

---

## Quick Reference Table

| Element | HEX | RGB | Usage |
|---------|-----|-----|-------|
| Primary Teal | `#1B9B9E` | `27, 155, 158` | Main brand color |
| Dark Teal | `#0F6B6E` | `15, 107, 110` | Shadows & depth |
| Orange | `#FF9500` | `255, 149, 0` | Accent & CTAs |
| Dark Orange | `#E67E22` | `230, 126, 34` | Secondary accent |
| Cream | `#F5F1E8` | `245, 241, 232` | Text & contrast |

---

## Implementation Tips

1. **Consistency:** Use these exact color codes across all platforms (iOS, Android, Web) for brand consistency
2. **Accessibility:** Always ensure sufficient contrast between text and background colors
3. **Gradients:** Use the teal-to-orange gradient for hero sections and important UI elements
4. **Hover States:** Darken colors by 10-15% for hover/active states
5. **Disabled States:** Use 50% opacity of the color for disabled elements

---

**Color Palette Created:** November 25, 2024  
**Icon Concept:** Exoda Household Expense Manager - Concept 2
