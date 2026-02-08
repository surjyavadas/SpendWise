# 💸 SpendWise

SpendWise is a modern, privacy-friendly expense tracking app built with **Flutter**.  
It focuses on a **clean UI**, **calm UX**, and **realistic budgeting insights**, inspired by Google-style design principles.

> 🚧 The project is actively evolving. Core features are stable, and more improvements are planned after exams.

---

## ✨ Features

- 📊 Monthly budget tracking
- ➕ Add & manage expenses
- 📸 Receipt scanner (OCR-based)
- 🌗 Automatic light / dark mode (system-based)
- ⚠️ Smart budget warnings (non-intrusive)
- 📈 Spending overview by category
- 💾 Local storage (no cloud, privacy-first)
- 🎨 Material 3 + modern UI

---

## 🖼️ Screenshots

> Screenshots will be added soon.

---

## 🛠️ Tech Stack

- **Flutter** (Material 3)
- **Provider** (state management)
- **Shared Preferences** (local storage)
- **Google ML Kit** (receipt scanning)
- **Kotlin DSL** (`build.gradle.kts`)
- **R8 + ProGuard** (release optimization)

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (stable)
- Android Studio / Android SDK
- A physical Android device or emulator

### Clone the repository
bash
git clone https://github.com/your-username/spendwise.git
cd spendwise

###Install dependencies
flutter pub get

RUN THE APP
flutter run

Build APK (Release)
flutter clean
flutter pub get
flutter build apk --release

