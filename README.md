# Nomzy – Surplus Food Marketplace

---

## 💖 For My Girlfriend: How to Use Nomzy

Hi! This is a simple app to help you (or anyone) find and add surplus food deals nearby. You can use it on your phone, computer, or in your browser. Here’s how to get started:

### What you can do
- **See all surplus bags**: Browse a list of available food deals from local sellers.
- **Add your own deal**: Click the plus (+) button to add a new surplus bag (fill in the form and save).
- **View details**: Click on any deal to see more info (description, price, pickup time, and photo).
- **Sign in/out**: You’ll need to sign in with your email to add or view deals.

### How to run the app (for non-techies)
1. **Web**: Just open the app in your browser (ask Daniel for the link if it’s live!).
2. **Windows**: Double-click the app if you have it, or ask Daniel to send you the latest version.
3. **Android/iOS**: Open the app on your phone (if installed). If not, ask Daniel for the install link.

### How to add a deal
1. Click the **+** button (top right).
2. Fill in the form: title, description, price, pickup time, and (optionally) a photo URL.
3. Click **Opslaan** (Save). Your deal will appear in the list!

### How to see more info
Click any deal in the list to see all details (including the pickup window and photo).

---

If you have any questions or want a new feature, just ask Daniel! 💬

---

![Nomzy App Screenshots](screenshots/nomzy_screens.png)

## Turn Surplus Food Into Extra Income—Risk Free

- ✅ Easy to upload daily surplus
- ✅ No upfront cost—pay per sale only
- ✅ New student customers daily

**Save good food. Save money. Eat smart.**

---

## Product Overview
Nomzy is a marketplace for surplus food, inspired by Too-Good-To-Go. Businesses can easily list daily surplus, reach new customers, and earn extra income with zero risk or upfront cost. Students and locals get great deals on fresh food that would otherwise go to waste.

## App Experience
- Browse and reserve surplus deals from local cafes and restaurants
- Pay in-app and show your QR code at pickup
- Businesses manage listings and track orders in real time

---

## Screenshots
Add your app screenshots to a `screenshots/` folder and reference them here for a visual overview.

![Nomzy App UI](screenshots/nomzy_ui_1.png)
![Nomzy App UI](screenshots/nomzy_ui_2.png)

---

## 💡 Quick facts
- **Product:** Nomzy · surplus‑food marketplace (Too‑Good‑To‑Go vibe).
- **Stack:** Flutter 3.x (one codebase) → Android · iOS · Web · Windows
- **Back-end:** Google Firebase (all back‑end)
- **Repo root:** `nomzy_mvp/` – holds Flutter app and functions/.

## 1 · What’s already finished
### 1.1 Firebase / CLI setup
```bash
npm i -g firebase-tools
firebase login                   # auth

dart pub global activate flutterfire_cli
flutterfire --version            # sanity

firebase projects:create nomzy-mvp
firebase init                   # picked: Firestore · Functions · Storage · Remote Config
firebase init functions         # TypeScript, Node 20
```
**Console Status:**
- Auth: Email / Password enabled
- Firestore: Production mode; blank collections
- Storage: Default bucket created
- Remote Config: Enabled, no parameters yet
- FCM: Enabled
- Functions: Scaffolded, zero code so far

### 1.2 Flutter bootstrap
```bash
flutter create nomzy_mvp
cd nomzy_mvp
flutter pub add firebase_core firebase_auth cloud_firestore firebase_storage
flutterfire configure                 # picks android + ios, writes firebase_options.dart
```
`main.dart` calls `Firebase.initializeApp()`.

Android / iOS / Web builds work.

### 1.3 Windows‑desktop fix (the tricky part)
- Download Firebase C++ SDK → unzip to `windows/firebase_cpp_sdk/`.
- Kept the VS2019 / MD / x64 / Release libs + DLLs.
- Regenerated default Windows runner (because folder was deleted):

```bash
flutter create .
flutter config --enable-windows
```
- Added `/windows/CMakeLists.txt` (full file below).

#### windows/CMakeLists.txt (put this verbatim)
```cmake
cmake_minimum_required(VERSION 3.14)
project(nomzy_mvp LANGUAGES CXX)
set(BINARY_NAME "nomzy_mvp")

# ── global flags ────────────────
add_definitions(-D_CRT_SECURE_NO_WARNINGS -DUNICODE -D_UNICODE)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
cmake_policy(VERSION 3.14...3.25)

# ── build matrix ────────────────
get_property(IS_MC GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
if(IS_MC)
  set(CMAKE_CONFIGURATION_TYPES "Debug;Profile;Release" CACHE STRING "" FORCE)
else()
  if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_TYPE Debug CACHE STRING "Flutter build" FORCE)
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS Debug Profile Release)
  endif()
endif()
set(CMAKE_EXE_LINKER_FLAGS_PROFILE "${CMAKE_EXE_LINKER_FLAGS_RELEASE}")
set(CMAKE_SHARED_LINKER_FLAGS_PROFILE "${CMAKE_SHARED_LINKER_FLAGS_RELEASE}")

# ── helper function ─────────────
function(apply_std tgt)
  target_compile_features(${tgt} PUBLIC cxx_std_17)
  target_compile_options(${tgt} PRIVATE /W3 /EHsc /permissive-)
endfunction()

# ── Flutter runner / plugins ────
add_subdirectory("${CMAKE_CURRENT_SOURCE_DIR}/flutter")
add_subdirectory("runner")
apply_std(${BINARY_NAME})
include(flutter/generated_plugins.cmake)

# Turn *off* /WX for auto‑generated plugin code
get_property(ALLT DIRECTORY PROPERTY BUILDSYSTEM_TARGETS)
foreach(t IN LISTS ALLT)
  if(t MATCHES "_plugin" AND TARGET ${t})
    target_compile_options(${t} PRIVATE "/WX-")
  endif()
endforeach()

# ── Firebase C++ SDK linkage ────
set(FB "${CMAKE_CURRENT_SOURCE_DIR}/firebase_cpp_sdk")
set(FB_LIB "${FB}/libs/windows/VS2019/MD/x64/Release")
target_include_directories(${BINARY_NAME} PRIVATE "${FB}/include")
link_directories("${FB_LIB}")

target_link_libraries(${BINARY_NAME} PRIVATE
  firebase_app firebase_auth firebase_firestore
  libcrypto.lib libssl.lib
  Shlwapi.lib Crypt32.lib Ws2_32.lib)

# ── bundle so `flutter run` works ─
set(BUNDLE "$<TARGET_FILE_DIR:${BINARY_NAME}>")
set(CMAKE_VS_INCLUDE_INSTALL_TO_DEFAULT_BUILD 1)
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT_BUILD)
  set(CMAKE_INSTALL_PREFIX "${BUNDLE}" CACHE PATH "" FORCE)
endif()
set(DATA "${CMAKE_INSTALL_PREFIX}/data")

install(TARGETS ${BINARY_NAME} RUNTIME DESTINATION "${CMAKE_INSTALL_PREFIX}")
install(FILES "${FLUTTER_ICU_DATA_FILE}" DESTINATION "${DATA}")
install(FILES "${FLUTTER_LIBRARY}"       DESTINATION "${CMAKE_INSTALL_PREFIX}")
install(DIRECTORY "${FB_LIB}"            DESTINATION "${CMAKE_INSTALL_PREFIX}" FILES_MATCHING PATTERN "*.dll")

set(NATIVE "${PROJECT_BUILD_DIR}native_assets/windows/")
install(DIRECTORY "${NATIVE}" DESTINATION "${CMAKE_INSTALL_PREFIX}")

set(ASSETS flutter_assets)
install(CODE "file(REMOVE_RECURSE \"${DATA}/${ASSETS}\")")
install(DIRECTORY "${PROJECT_BUILD_DIR}/${ASSETS}" DESTINATION "${DATA}")
install(FILES "${AOT_LIBRARY}" DESTINATION "${DATA}" CONFIGURATIONS Profile;Release)
```
Now `flutter run -d windows` and `flutter build windows` succeed.

## 2 · What’s not done yet (road‑map)
- **Cloud Functions** – implement TypeScript triggers (onDealCreated, onPurchase, sendPickupReminder), deploy.
- **Firestore + rules** – design collections: /users, /deals, /orders; write security rules.
- **Flutter UI** – replace counter demo with real screens: login, list/map, deal details, checkout, QR scanner, seller dashboard.
- **CI/CD pipeline** – GitHub Actions → run tests → build APK, IPA (manual upload for now), MSIX → firebase deploy for Functions + Hosting (PWA).
- **Config / secrets** – move env‑specific keys to flutter_dotenv + Remote Config.
- **iOS** – run flutterfire configure, add Capabilities (Keychain + Push) in Xcode.

## 3 · Rules for Copilot (or any AI assistant)
- Never re‑enable /WX on plugin targets – their warnings break Windows build.
- Propose CMake edits only under the #### ---- Firebase C++ SDK linkage ---- section.
- Use FirebaseAuth.instance, FirebaseFirestore.instance with riverpod or bloc (our discretion).
- When suggesting Desktop code, remember that Firebase access is via C++ SDK, not Flutter plugins.

## 4 · One‑liner cheat‑sheet for devs
```bash
# first‑time setup
brew (or choco) install flutter dart
npm i -g firebase-tools
dart pub global activate flutterfire_cli

# run the app
flutter pub get
flutterfire configure          # if bundle IDs changed
flutter run -d windows         # or android / ios / web

# Local back‑end
firebase emulators:start

# deploy back‑end
npm --prefix functions i
firebase deploy --only functions,firestore:rules,storage:rules,hosting
```
