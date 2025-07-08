# Nomzy MVP – Copilot Project README

## 1. Business Context
- **Product:** Nomzy – an MVP marketplace for surplus meals/stock (Too-Good-To-Go style).
- **Key feature set:** Browse nearby surplus deals → reserve & pay → show pickup QR → seller marks as picked up.
- **Back-end / BaaS:** Google Firebase (single project) handles Auth, Firestore, Cloud Functions, Remote Config, Storage (food photos), and FCM.
- **Client app:** One Flutter 3.x codebase → targets Android · iOS · Web · Windows desktop.
- **Monorepo:** All code (Flutter + Cloud Functions) lives in `nomzy_mvp/` for now.

## 2. Firebase Work Already Done
| Step | Command / Action | Outcome |
|------|------------------|---------|
| Create Firebase project | `firebase projects:create nomzy-mvp` (web UI is fine too) | Project ID confirmed |
| Enable products | Auth · Firestore · Functions · Storage · RemoteConfig enabled in console. | |
| Install CLIs | `npm i -g firebase-tools` → `firebase login` → `dart pub global activate flutterfire_cli` | Both CLIs ready |
| Register mobile apps | `flutterfire configure` (picked Android & iOS) | `firebase_options.dart` generated and added to Flutter |
| Initialise Cloud Functions | `firebase init functions` (chose TypeScript) | Functions folder scaffolding in repo (not yet implemented) |

## 3. Flutter App Bootstrap
```bash
flutter create nomzy_mvp
cd nomzy_mvp
flutter pub add firebase_core firebase_auth cloud_firestore firebase_storage
flutterfire configure            # generated firebase_options.dart
```
App entry (`main.dart`) now calls `Firebase.initializeApp()`.

- Android / iOS builds already work (`flutter run -d android` etc.).

## 4. Remaining TODOs
| Area | Task |
|------|------|
| Cloud Functions | Write TypeScript endpoints (create deal, send FCM, etc.), deploy with `firebase deploy --only functions`. |
| Flutter UI | Replace counter demo with: login / browse deals / map list / checkout page / seller app view. |
| Release pipeline | GitHub Actions → flutter test → builds (APK · IPA stub · MSIX) → upload to TestFlight / Play Console / signed MSIX package. |
| App secrets | Move non-public keys to flutter_dotenv + Firebase Remote Config. |

## 5. Copilot Engineering Rules
- Autocomplete CMake tweaks but never add `/WX` back to plugin targets.
- Suggest Dart/Flutter code that talks to `Firebase.initializeApp()`, `FirebaseAuth.instance`, `FirebaseFirestore.instance` with clean MVVM or BLoC separation.
- Recognise that Windows uses C++ SDK while Android/iOS/Web rely on standard FlutterFire.

## 6. Firebase-Only Cheat-Sheet
| # | Action | Command / Console step | Result in the project |
|---|--------|-----------------------|----------------------|
| 1 | Created a fresh Firebase project | `firebase projects:create nomzy-mvp` (or via console) | Got a unique project ID & default GCP resources |
| 2 | Installed both CLIs | `npm i -g firebase-tools` `dart pub global activate flutterfire_cli` `firebase login` | `firebase --version` and `flutterfire --version` now work globally |
| 3 | Initialised base config | `firebase init` → picked → Firestore → Functions → Storage → RemoteConfig | Generated .firebaserc, firebase.json, firestore.rules, default storage rules, functions/ scaffold |
| 4 | Enabled the products in the console | • Authentication (Email/Password for MVP) • Firestore in production mode (multi-region) • Storage, Remote Config, FCM | All are now “green” in console |
| 5 | Flutter-side registration | `flutterfire configure` | - Chose Android & iOS bundle IDs - Generated lib/firebase_options.dart with embedded API keys |
| 6 | Added core packages | `flutter pub add firebase_core firebase_auth cloud_firestore firebase_storage` | Pubspec locked, packages download |
| 7 | Boot-strapped app | In main.dart: `void main() async { WidgetsFlutterBinding.ensureInitialized(); await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform, ); runApp(NomzyApp()); }` | Mobile & web now connect to Firebase |
| 8 | Cloud Functions scaffold | `firebase init functions` (TypeScript, Node 20) | functions/ with index.ts, package.json, ready to deploy |
| 9 | Local emulators tested (optional) | `firebase emulators:start` | Firestore + Auth + Functions run locally for dev |
| 10 | Desktop linking (Windows only) | Added Firebase C++ SDK and custom CMake (see previous message) | Desktop build finally links firebase_app, firebase_auth, firebase_firestore |
