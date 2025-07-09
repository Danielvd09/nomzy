---

## 🚧 Nomzy TODO List: What’s Next?

Here’s a clear breakdown of what’s left to do for Nomzy, split into **Frontend** and **Backend** tasks. Each item has a short explanation so you know exactly what it means and why it matters.

### 🖌️ Frontend Tasks (UI/UX)

- **1. Polish the Deals List UI**  
  Make the deals list look more attractive: add images, better spacing, maybe a card layout or color accents. (See `DealsPage` in `main.dart`.)

- **2. Add/Edit/Delete Deal Functionality**  
  Right now, you can only add deals. Add the ability to edit or delete your own deals (e.g., with an edit button or swipe action).

- **3. Deal Detail Page Improvements**  
  Make the deal detail dialog/page more visual: bigger photo, clearer price breakdown, maybe a map for pickup location.

- **4. User Profile Page**  
  Add a page where users can see their own deals, edit their info, or sign out.

- **5. Responsive Design**  
  Make sure the app looks good on all screen sizes (mobile, tablet, desktop, web). Use Flutter’s layout widgets for this.

- **6. Error Handling & Validation**  
  Show friendly error messages if something goes wrong (e.g., failed to save a deal, bad input).

- **7. (Optional) State Management**  
  If the UI gets more complex, consider using Provider, Riverpod, or Bloc for cleaner state handling.

- **8. (Optional) Animations & Polish**  
  Add subtle animations for transitions, button presses, or loading states to make the app feel smooth.

---

### 🛠️ Backend Tasks (Firebase/Logic)

- **1. Firestore Security Rules**  
  Write rules so only logged-in users can add/edit/delete their own deals, and no one can mess with others’ data. (See Firebase console > Firestore > Rules.)

- **2. Cloud Functions for Notifications**  
  Add server-side code (TypeScript) to send push notifications when a new deal is added, or when someone reserves a bag. (See `functions/` folder.)

- **3. Reservation/Order Flow**  
  Add a way for users to reserve a deal (creates an order in Firestore), and for sellers to mark it as picked up. This needs both UI and backend logic.

- **4. User Management**  
  Store extra info about users (name, phone, etc.) in Firestore, and let users update their profile.

- **5. (Optional) Image Uploads**  
  Let users upload real photos (not just URLs) for deals, using Firebase Storage. Requires both frontend and backend changes.

- **6. (Optional) Analytics & Metrics**  
  Track how many deals are posted, reserved, picked up, etc. Use Firebase Analytics or custom Firestore fields.

- **7. (Optional) Automated Deployments**  
  Set up GitHub Actions to automatically deploy the app and backend when you push to main.

---

If you have questions about any task, just ask! Each item is a real-world feature that will make Nomzy more useful and robust.

---

# Nomzy – Surplus Food Marketplace

---


## � Frontend Dev Quickstart (for my awesome girlfriend)

Hey! Here’s what you need to know to get started fast as a frontend dev on this project:

### 1. Run the app locally
- `flutter pub get`
- `flutterfire configure` (if you change bundle IDs)
- `flutter run -d chrome` (web), `-d windows`, `-d android`, etc.

### 2. Where’s the UI?
- All main UI is in `lib/main.dart` (see: `DealsPage`, `AddDealPage`, `DealDetailDialog`).
- Auth is handled with `firebase_ui_auth` (see `AuthGate`).
- Firestore integration is direct (no state management yet).

### 3. How to change the design
- Edit the widgets in `DealsPage` and `AddDealPage`.
- You can add new pages, dialogs, or refactor to separate files if you want.
- All UI is Material for now, but you can add your own style/components.

### 4. Hot reload works everywhere
- Just save and the UI updates instantly (web, desktop, mobile).

### 5. Firebase
- Auth and Firestore are already set up. If you want to add Storage (for real photo uploads), see `pubspec.yaml` and `main.dart`.

### 6. Collaboration
- Push to GitHub, open a PR, or just ping me for a review!

---

If you want to refactor, add state management, or go wild with the UI, go for it! Ping me if you want backend endpoints or new Firestore fields. ❤️

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
