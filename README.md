<p align="center">
  <!-- TODO: Replace with actual app logo -->
  <img src="assets/app-logo-placeholder.png" alt="Abstrakt Logo" width="120" height="120" />
</p>

<h1 align="center">Abstrakt</h1>

<p align="center">
  <strong>A library of beautifully customizable iPhone widgets.</strong>
</p>

<p align="center">
  Personalize your home screen and lock screen with widgets that match your style.<br/>
  Adjust colors, fonts, borders, and themes — make every widget truly yours.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/iOS-17.0%2B-blue?style=flat-square" alt="iOS 17.0+" />
  <img src="https://img.shields.io/badge/Swift-5.9-orange?style=flat-square" alt="Swift 5.9" />
  <img src="https://img.shields.io/badge/SwiftUI-5-purple?style=flat-square" alt="SwiftUI" />
  <img src="https://img.shields.io/badge/Architecture-MVVM-green?style=flat-square" alt="MVVM" />
  <img src="https://img.shields.io/badge/License-MIT-lightgrey?style=flat-square" alt="License" />
</p>

---

## Screenshots

<!-- TODO: Replace with actual mockups/posters -->

<p align="center">
  <img src="assets/mockup-1-placeholder.png" alt="Home Screen Preview" width="200" />
  &nbsp;&nbsp;
  <img src="assets/mockup-2-placeholder.png" alt="Widget Customization" width="200" />
  &nbsp;&nbsp;
  <img src="assets/mockup-3-placeholder.png" alt="Lock Screen Widgets" width="200" />
</p>

---

## Features

### Widget Library
| Widget | Description |
|--------|-------------|
| 🔋 **Batteries** | Monitor device and accessory battery levels at a glance |
| 🕐 **Clock** | Analog and digital clocks with timezone support |
| 📅 **Calendar** | Upcoming events and monthly calendar view |
| 🌤️ **Weather** | Current conditions and forecasts powered by WeatherKit |
| ❤️ **Health** | Step count, activity rings, and health metrics from HealthKit |

### Customization
- **Colors** — Pick any color for backgrounds, text, accents, and borders
- **Fonts** — Choose from a curated set of system and custom typefaces
- **Borders** — Adjust border width, radius, and color
- **Themes** — Pre-built themes for quick styling, fully editable
- **Per-widget configs** — Each widget instance can have its own unique look

### Widget Sizes
- Home Screen: Small, Medium, Large
- Lock Screen: Circular, Rectangular, Inline

---

## Tech Stack

| Technology | Purpose |
|------------|---------|
| **SwiftUI** | Declarative UI framework for all screens and widget views |
| **WidgetKit** | Widget rendering, timelines, and intent configuration |
| **SwiftData** | On-device persistence for widget configurations |
| **App Groups** | Shared data container between the main app and widget extension |
| **EventKit** | Access to calendar events and reminders |
| **HealthKit** | Access to health and fitness data |
| **WeatherKit** | Real-time weather data from Apple Weather |
| **CoreLocation** | Location services for weather widgets |

---

## Architecture

Abstrakt follows the **MVVM (Model-View-ViewModel)** pattern with a clear separation of concerns.

```
Abstrakt/
├── App/                        # App entry point
├── Features/
│   ├── Main/                   # Home, Onboarding, Settings
│   └── Widget/                 # Each widget category (Batteries, Clock, etc.)
│       └── [Category]/
│           ├── Models/         # Data structures and configurations
│           ├── ViewModels/     # Business logic and state
│           └── Views/          # SwiftUI views
├── Shared/
│   ├── Constants/              # App Group IDs, shared keys
│   ├── DataProviders/          # Framework wrappers (EventKit, HealthKit, etc.)
│   ├── Persistence/            # SwiftData container and models
│   └── Theme/                  # Design tokens — colors, typography
└── WidgetExtension/            # WidgetKit extension bundle
```

### Data Flow

```
Main App (SwiftData) → JSON Serialization → App Groups Container → Widget Extension (reads JSON)
```

The main app manages widget configurations via SwiftData. When a user saves or updates a widget, the config is serialized to JSON and written to the App Groups shared container. The widget extension reads this JSON to render the widget — keeping the extension lightweight and stateless.

---

## Accessibility

| Feature | Status |
|---------|--------|
| Dynamic Type | ✅ Supported — all text scales with user preferences |
| Bold Text | ✅ Supported — respects system bold text setting |
| Dark Mode | ✅ Full support — all colors adapt to light/dark appearance |

---

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Apple Developer Program membership (required for WeatherKit and HealthKit entitlements)

---

## Getting Started

1. Clone the repository
   ```bash
   git clone https://github.com/your-username/Abstrakt.git
   ```

2. Open the project in Xcode
   ```bash
   cd Abstrakt
   open Abstrakt.xcodeproj
   ```

3. Configure code signing
   - Copy `Abstrakt/Config/Signing.local.xcconfig.example` to `Signing.local.xcconfig`
   - Set your `DEVELOPMENT_TEAM` ID
   - `Signing.local.xcconfig` is gitignored — your credentials stay local

4. Build and run on a simulator or device (iOS 17.0+)

---

## Team

<!-- TODO: Replace placeholder info with actual team members -->

<table>
  <tr>
    <td align="center" width="200">
      <img src="https://via.placeholder.com/100" width="100" height="100" style="border-radius: 50%;" alt="Developer 1" /><br/>
      <strong>Team Member 1</strong><br/>
      <sub>Developer</sub><br/>
      <a href="https://github.com/username1"><img src="https://img.shields.io/badge/-GitHub-181717?style=flat-square&logo=github" alt="GitHub" /></a>
      <a href="https://linkedin.com/in/username1"><img src="https://img.shields.io/badge/-LinkedIn-0A66C2?style=flat-square&logo=linkedin&logoColor=white" alt="LinkedIn" /></a>
    </td>
    <td align="center" width="200">
      <img src="https://via.placeholder.com/100" width="100" height="100" style="border-radius: 50%;" alt="Developer 2" /><br/>
      <strong>Team Member 2</strong><br/>
      <sub>Developer</sub><br/>
      <a href="https://github.com/username2"><img src="https://img.shields.io/badge/-GitHub-181717?style=flat-square&logo=github" alt="GitHub" /></a>
      <a href="https://linkedin.com/in/username2"><img src="https://img.shields.io/badge/-LinkedIn-0A66C2?style=flat-square&logo=linkedin&logoColor=white" alt="LinkedIn" /></a>
    </td>
    <td align="center" width="200">
      <img src="https://via.placeholder.com/100" width="100" height="100" style="border-radius: 50%;" alt="Designer" /><br/>
      <strong>Team Member 3</strong><br/>
      <sub>Designer</sub><br/>
      <a href="https://github.com/username3"><img src="https://img.shields.io/badge/-GitHub-181717?style=flat-square&logo=github" alt="GitHub" /></a>
      <a href="https://linkedin.com/in/username3"><img src="https://img.shields.io/badge/-LinkedIn-0A66C2?style=flat-square&logo=linkedin&logoColor=white" alt="LinkedIn" /></a>
    </td>
  </tr>
</table>

---

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
