# ⚡ VOLTTSENSE — Electricity Bill Estimator

A Flutter Android application for estimating monthly electricity bills using TNB (Tenaga Nasional Berhad) block tariff rates. Records are stored locally on-device and can be viewed, edited, or deleted at any time.

---

## 📱 Screenshots

> Coming soon

---

## ✨ Features

- **Bill Calculator** — select a month, enter units used (1–1000 kWh), and set a rebate (0–5%) via slider
- **Tiered tariff calculation** — automatically applies TNB's 4-block pricing structure
- **Results on the same page** — total charges and final cost after rebate shown instantly
- **Local database** — all records saved offline using SQLite (sqflite)
- **Records list** — browse all saved bills showing month and final cost
- **Detail view** — tap any record to see full details, edit values, or delete the entry
- **About page** — student info, app description, how-to guide, and clickable GitHub link
- **Splash screen & custom icon** — purple-themed branding applied to launcher and splash

---

## 🧮 Tariff Rate Table

| Block | Units (kWh) | Rate (sen/kWh) |
|-------|-------------|----------------|
| 1 | First 200 kWh (1 – 200) | 21.8 |
| 2 | Next 100 kWh (201 – 300) | 33.4 |
| 3 | Next 300 kWh (301 – 600) | 51.6 |
| 4 | Next 400 kWh (601 – 1000) | 54.6 |

**Formula:**
```
Final Cost = Total Charges − (Total Charges × Rebate%)
```

---

## 🗂️ Project Structure

```
electricity_bill_app/
├── lib/
│   ├── main.dart                  # App entry point, theme, navigation
│   ├── models/
│   │   └── bill_record.dart       # Data model
│   ├── database/
│   │   └── database_helper.dart   # SQLite CRUD operations
│   ├── screens/
│   │   ├── home_screen.dart       # Calculator screen
│   │   ├── list_screen.dart       # Saved records list
│   │   ├── detail_screen.dart     # Record detail, edit & delete
│   │   └── about_screen.dart      # About page
│   └── utils/
│       └── bill_calculator.dart   # Tariff calculation logic
├── assets/
│   └── icon/
│       ├── app_icon.png           # Launcher icon (1024×1024)
│       ├── splash.png             # Splash screen image (2048×2048)
│       └── student_photo.jpg      # Student profile photo
└── pubspec.yaml
```

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) `>=3.0.0`
- Android Studio or VS Code with Flutter extension
- An Android device or emulator (API 21+)

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/yourusername/electricity-bill-app.git
cd electricity-bill-app

# 2. Install dependencies
flutter pub get

# 3. Generate app icon
dart run flutter_launcher_icons

# 4. Generate splash screen
dart run flutter_native_splash:create

# 5. Run the app
flutter run
```

### Build a signed APK

```bash
flutter build apk --release
```
The signed APK will be at `build/app/outputs/flutter-apk/app-release.apk`.

---

## 📦 Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `sqflite` | ^2.3.0 | Local SQLite database |
| `path` | ^1.8.3 | Database file path helper |
| `url_launcher` | ^6.2.5 | Open GitHub URL from About page |
| `flutter_native_splash` | ^2.4.0 | Splash screen generation |
| `flutter_launcher_icons` | ^0.13.1 | App icon generation |

---

## 🗃️ Database Schema

**Table: `bills`**

| Column | Type | Description |
|--------|------|-------------|
| `id` | INTEGER (PK) | Auto-incremented ID |
| `month` | TEXT | Selected month (e.g. January) |
| `units` | REAL | Units used in kWh |
| `totalCharges` | REAL | Calculated charge before rebate (RM) |
| `rebatePercent` | REAL | Rebate percentage applied (0–5) |
| `finalCost` | REAL | Final cost after rebate (RM) |

---

## 📖 How to Use

1. **Open the app** — the Calculator tab loads by default
2. **Select a month** from the dropdown (January – December)
3. **Enter units used** between 1 and 1000 kWh
4. **Adjust the rebate slider** from 0% to 5% if applicable
5. **Tap Calculate** to see the total charges and final cost
6. **Tap Save** to store the result in the local database
7. **Go to Records tab** to see all saved bills listed by month
8. **Tap any record** to view full details, edit values, or delete it
9. **Go to About tab** to view student information and instructions

---

## 📋 Assignment Rubric Coverage

| Criteria | Implementation |
|----------|---------------|
| Input & Output (5M) | Dropdown (month), number field (units), slider (rebate); formatted RM output |
| Database (5M) | SQLite via sqflite — insert, list view, detail view, edit, delete |
| Layout (5M) | Purple theme, custom app name in AppBar, bottom nav icons, signed APK |
| About Page (5M) | Student photo, full name, ID, course, copyright, clickable GitHub URL |
| Good Design Practice (5M) | Form validation errors, info banner, snackbar confirmations, input hints |

---

## 👤 About the Developer

- **Name:** Arwan Awat Othman
- **Student ID:** QIU 23-0265
- **Course:** Mobile Technology
- **Course Code:** ICT602
- **Institution:** UITM

---

## 🔗 Links

- **GitHub Repository:** [https://github.com/ArwanAwat/vlottsense]

---

## © License

© 2026 Arwan Awat Othman. All rights reserved.  
Built with Flutter for Android — Individual Assignment, Mobile Technology.