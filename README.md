# LiveOgo

LiveOgo is a Flutter-first live-commerce SaaS platform for buyers, sellers and platform administrators.

## Stack
- Flutter + Material 3
- Riverpod for state management
- GoRouter for navigation
- Dio for API networking
- Google Fonts (Inter)

## Getting started
1. Install Flutter stable and run `flutter doctor`.
2. From this directory run `flutter pub get`.
3. Configure your API base URL with `--dart-define=API_BASE_URL=https://your-api.example`.
4. Run `flutter run`.

## Current implementation
This branch establishes the Flutter application foundation: themed app shell, splash/onboarding, phone sign-in entry, role selection, buyer/seller navigation and initial feed/studio screens.

Production integrations (Firebase phone OTP, Supabase persistence, Agora live video, Firestore chat, payment provider verification, maps and KYC) require project credentials and backend contracts. They are intentionally not simulated as successful transactions.

## Project structure
- `lib/app`: app configuration, routing and theme
- `lib/core`: networking and shared UI
- `lib/features/auth`: onboarding, sign-in and role selection
- `lib/features/buyer`: buyer navigation and discovery feed
- `lib/features/seller`: seller studio navigation and dashboard
