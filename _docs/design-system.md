# Design System Guidelines

## Philosophy & Aesthetics
- **Style**: Modern, clean, high-contrast dashboard with subtle glassmorphism and card elevation.
- **Implementation**: Vanilla CSS using custom properties (design tokens). Avoid Tailwind unless explicitly requested.

## Color Palette Tokens
- **Backgrounds**: Deep dark workspace backdrop (`#0f172a` / `#1e293b`) with clean surface cards.
- **Accent & Primary**: Indigo/Violet gradients (`#6366f1` / `#8b5cf6`).
- **Status Indicators**:
  - `On Track`: Emerald green (`#10b981`)
  - `At Risk`: Amber/Orange (`#f59e0b`)
  - `Blocked`: Crimson/Red (`#ef4444`)
  - `Completed`: Royal Blue (`#3b82f6`)

## Typography
- **Headings & Badges**: Outfit / Inter (`font-family: 'Outfit', 'Inter', sans-serif`).
- **Body & Forms**: Inter (`font-family: 'Inter', sans-serif`).
- **Code / Identifiers**: JetBrains Mono or monospace.

## Component Rules
1. **Badges & Pills**: Rounded-full pill tags with subtle background tint and vibrant text.
2. **Cards**: 1px border with glassmorphism or slight gradient stroke (`border: 1px solid rgba(255, 255, 255, 0.08)`), rounded corners (`border-radius: 12px`).
3. **Empty States**: Clear graphic or icon with descriptive subtitle and call-to-action button.
4. **Interactive States**: Smooth hover transitions (`transition: all 0.2s ease`).
