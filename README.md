# Workly

Workly is an iOS app (SwiftUI + Firebase, MVVM) that connects customers with trusted home-service workers such as electricians, plumbers and cleaners. It has two roles, **Customer** and **Worker**, and runs on iPhone and iPad.

## Features
- **Both roles:** sign-up with validation, email login, **Face ID login**, in-app **notifications**, profile photo, home-screen widget
- **Customer:** search workers (list and map), worker profiles and reviews, favourites, service requests, live booking status, rating, PDF service summary
- **Worker:** dashboard, profile and availability, real-time requests, accept, start and complete jobs

## Run the app
1. Open `IOS_Coursework.xcodeproj` in Xcode 16+ and wait for the Firebase packages to download.
2. Choose an iPhone or iPad simulator and press **Run** (⌘R). An internet connection is required.
3. Create a **customer** account and a **worker** account from the **Sign Up** screen (choose the role at the top), then log in with them.
4. To see the full flow: as the worker, complete the profile and switch **Available** on in the dashboard; as the customer, search for the worker and send a request; then accept it as the worker.

## Backend (for markers)
The backend is **Firebase Authentication + Cloud Firestore**. `GoogleService-Info.plist` is already in the project and points to the live Firebase project (`[YOUR-FIREBASE-PROJECT-ID]`), so no setup is needed. To use your own project instead: create a Firebase project, add an iOS app with the bundle ID, replace `GoogleService-Info.plist`, enable **Email/Password** sign-in, create a Firestore database and publish the rules in `firestore.rules`.

## Tests
Unit tests use Swift Testing. Press **⌘U** to run them (no network needed).

## Simulator tips
- **Location:** Features → Location → Custom Location
- **Face ID:** Features → Face ID → Enrolled
