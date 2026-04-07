# RoadFixQC — Project Context Document

## What is RoadFixQC?

RoadFixQC is a mobile application built with Flutter for reporting road hazards (potholes, cracks, etc.) in Quezon City, Philippines. It is a capstone project. The app lets citizens photograph road damage, automatically detect the type of damage using AI, and submit geo-tagged reports to local authorities. Reports are managed through a Firebase backend with real-time status tracking.

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter (Dart >=3.8.0 <4.0.0) |
| Auth | Firebase Auth (email/password + Google Sign-In) |
| Database | Cloud Firestore (real-time streams) |
| Image Storage | ImageKit (imagekit.io) — not Firebase Storage |
| Email Service | Custom Vercel API (verification + password reset) |
| AI Detection | YOLO via `ultralytics_yolo` package (on-device inference) |
| Location | Geolocator + Nominatim (OpenStreetMap) + Valhalla (map matching) |
| State Management | Stream-based (Firestore streams + RxDart BehaviorSubject) |

**Firebase Project ID:** `roadfixqc-admin`

---

## Folder Structure

```
lib/
├── main.dart                  → App entry point, Firebase init, route definitions
├── constant/ (6 files)        → Theme colors, text styles, app-wide config
├── layouts/ (5 files)         → Reusable page layout templates
├── models/ (14 files)         → Data classes
│   ├── user_model.dart        → UserModel (uid, name, email, contact, TOTP fields, role, isActive)
│   ├── report_model.dart      → ReportModel (image, location, GPS coords, status, priority, tags)
│   ├── detection_result.dart  → DetectionResult (bbox, confidence, className)
│   ├── location_data.dart     → LocationData (lat, lng, formatted addresses)
│   ├── security_result.dart   → SecurityResult (validation output)
│   └── ...others
├── screens/ (11 files)
│   ├── auth_screens/          → LoginScreen, SignUpScreen, EmailVerificationScreen, ForgotPasswordScreen
│   ├── module_screens/        → HomeScreen, ReportTypeScreen, UserReportScreen, ProfileScreen, NavigationScreen
│   ├── secondary_screens/     → SendReportScreen, ReportDetailScreen, UnifiedDetectionScreen
│   └── tutorial_screens/      → TutorialScreen (onboarding)
├── services/ (17 files)       → All business logic (see Services section below)
├── utils/ (14 files)          → Helpers: responsive sizing, auth error handling, validation, formatting
└── widgets/ (49 files)        → Reusable UI organized by feature area
    ├── auth_widgets/          → Login/signup form components
    ├── common_widgets/        → Buttons, toasts, shared UI
    ├── detection_widgets/     → Detection result display, location fields
    ├── dialog_widgets/        → Modals (loading, location permission, TOTP setup, logout)
    ├── home_widgets/          → Dashboard header, banners, recent reports list
    ├── profile_widgets/       → Profile card, options list, status summary
    ├── reporting_widgets/     → Report form fields, detection tag chips
    └── user_report_widgets/   → Report cards, filters, pagination controls
```

**~19,800 lines of Dart across 132 files.**

---

## App Flow

### Authentication
```
LoginScreen
├── Email + Password login
│   ├── Checks email verification → redirects to EmailVerificationScreen if unverified
│   ├── Checks TOTP → shows TOTP dialog if 2FA is enabled
│   └── Rate limited: 5 failed attempts = 30-min lockout
├── Google Sign-In (OAuth)
│   └── Auto-creates Firestore user if first time
└── ForgotPasswordScreen → sends reset email via Vercel API

SignUpScreen
├── Creates Firebase Auth account + Firestore user document
├── Sends verification email via Vercel API (NOT Firebase default)
└── Redirects to EmailVerificationScreen (polls until verified, sets isActive: true)
```

### Main App (NavigationScreen — 4 bottom tabs)
```
Tab 1: HomeScreen
  → Dashboard with greeting, user location, report stats (pending/in-progress/resolved counts), recent reports

Tab 2: ReportTypeScreen
  → Shows report categories → opens ImageSourceDialog (camera or gallery)
  → Navigates to UnifiedDetectionScreen → then SendReportScreen

Tab 3: UserReportScreen (My Reports)
  → Filterable list of user's own reports with pagination
  → Tap a report → ReportDetailScreen

Tab 4: ProfileScreen
  → User info, edit profile, enable/disable TOTP 2FA, logout
```

### Report Submission Pipeline
```
1. User selects image (camera/gallery)
2. AI detection runs on-device (YOLO model)
3. Detections filtered and displayed
4. User proceeds to SendReportScreen:
   - Auto-filled: image, detection tags, AI-generated description
   - Auto-filled: GPS location (high-accuracy mode with Kalman filter)
   - User can edit description and location
5. Security validation runs:
   - File size check (100KB – 25MB)
   - Text sanitization (strips HTML/JS for XSS prevention)
   - Spam cooldown (5-minute gap between reports)
   - Daily limit (10 reports/day)
6. Image compressed → uploaded to ImageKit (/reports folder)
7. Report document created in Firestore with status: 'pending'
```

### Report Lifecycle
```
pending → in_progress → accepted → resolved
                     └→ invalid (if rejected)
```
Reports include: image URL, description, location string, GPS coordinates, reportType, detection tags, userId, status, priority (low/medium/high/urgent), timestamps, and optional resolvedImageUrl + completionNotes (added by admin).

---

## Services (Business Logic Layer)

| Service | Responsibility |
|---------|---------------|
| `AuthService` | Firebase Auth operations: sign in, sign up, sign out, Google auth, email verification check |
| `FirestoreService` | Firestore CRUD for `users` collection, real-time streams (getUserStream, getCurrentUserStream, getActiveUsersStream) |
| `ReportService` | Firestore CRUD for `reports` collection, streams (getUserReports, reportCounts, acceptedReports), report submission with ImageKit upload |
| `UserService` | User data caching (5-min TTL), profile update helper |
| `GeolocationService` | Two modes: high-accuracy for reports (Kalman-filtered, 15s timeout) and general-use (cached 10-min TTL with fallbacks) |
| `GeocodingService` | Reverse geocoding via Nominatim (OpenStreetMap), map matching via Valhalla, Kalman filter for GPS smoothing |
| `ImageKitService` | Singleton. Image compression + upload to ImageKit. Folders: /reports, /profiles |
| `ImageKitUploader` | Low-level HTTP calls to ImageKit upload API (Basic auth) |
| `SecurityService` | Singleton. Validates file size, sanitizes text, checks spam cooldown + daily limits, brute force detection |
| `EmailService` | Sends verification and password reset emails via Vercel-hosted API endpoints |
| `TotpService` | TOTP 2FA: secret generation (Base32, 160-bit), QR code data, HMAC-SHA1 code verification (±1 time step tolerance), backup code generation |
| `NotificationService` | Singleton. Tracks viewed/deleted notifications via BehaviorSubject + SharedPreferences. Provides recently-updated-reports stream |
| `ConnectivityService` | Internet connection checks |
| `TutorialService` | Manages onboarding tutorial completion state |
| `CameraAngleService` | Device orientation/sensor data |
| `UnifiedDetectionService` | YOLO model loading and inference (NOTE: detection scope is changing — see notes) |

---

## Location System

The app uses an advanced multi-layer location pipeline:

1. **Geolocator** — raw GPS coordinates from device
2. **Kalman Filter** — smooths GPS noise for more stable readings
3. **Valhalla Map Matching** — snaps coordinates to nearest road
4. **Nominatim Reverse Geocoding** — converts coordinates to human-readable addresses

Two accuracy modes:
- **High-accuracy** (`getCurrentLocationForReports`) — used during report submission, fresh GPS fix, 15s timeout
- **General-use** (`getCurrentLocation`) — used for UI (home header), cached 10-min TTL, falls back to last-known

Location model stores: latitude, longitude, formattedAddress, shortAddress, fullAddress, city, province, country.

**Quezon City geo-restriction** is behind a feature flag (`enableQuezonCityOnly`) — when enabled, reports outside QC boundaries are rejected.

---

## State Management Approach

No dedicated state management package (no Provider, Bloc, Riverpod). Instead:

- **Firestore real-time streams** power most UI updates (reports, user data, counts)
- **RxDart BehaviorSubject** used in NotificationService for local state
- **SharedPreferences** for persisting notification state, spam prevention timestamps, tutorial completion
- **Service singletons** hold shared state (ImageKitService, SecurityService, NotificationService)
- **StatefulWidget + setState** for screen-level local state

---

## Security Features

- **Authentication:** Email verification required, optional TOTP 2FA with backup codes
- **Login protection:** Rate limiting (5 attempts → 30-min lockout)
- **Content validation:** HTML/script stripping to prevent XSS, file type + size validation
- **Spam prevention:** 5-minute cooldown between reports, 10 reports/day maximum
- **Brute force detection:** Tracked via SharedPreferences

---

## Theming & Responsive Design

- **Primary color:** `#F7C90D` (yellow)
- **Secondary color:** `#030303` (black)
- **Reference design:** 375×812 (standard mobile)
- **Responsive system:** Custom extensions (`.w` for width, `.h` for height, `.sp` for font size, `.r` for radius) that scale relative to reference dimensions
- **Defined in:** `lib/constant/themes.dart` and `lib/utils/Responsive.dart`

---

## External Service Endpoints

| Service | Endpoint |
|---------|----------|
| ImageKit Upload | `https://upload.imagekit.io/api/v1/files/upload` |
| Vercel Email API | `[base-url]/api/send-verification-email` and `/api/send-reset-email` |
| Nominatim Geocoding | `https://nominatim.openstreetmap.org/reverse` |
| Valhalla Map Matching | Configured in GeocodingService |

---

## Important Notes for Future Development

1. **Detection scope is changing.** The YOLO model and detection filtering logic (currently filters to 'Road-Cracks' only with 0.15 confidence threshold) will be updated. Do not make major changes to detection code until the new scope is defined.

2. **Emails go through Vercel, not Firebase.** The app uses a custom Vercel-hosted API for sending verification and password reset emails. This is important for deployment — the Vercel endpoints must be running.

3. **ImageKit, not Firebase Storage.** All images (reports + profiles) are stored on ImageKit. Credentials are in `ImageKitService`. Profile images use a consistent filename to overwrite on re-upload.

4. **Firestore collections:** `users` (user profiles) and `reports` (all reports). No subcollections.

5. **No dedicated admin panel in this app.** Report status changes (pending → in_progress → resolved) are handled externally (admin dashboard is a separate project or done via Firestore console).

6. **Quezon City restriction** can be toggled via `enableQuezonCityOnly` feature flag in the detection/report flow.

7. **The `mounted` check** is required after any async operation before using BuildContext (Flutter lint rule `use_build_context_synchronously`). This has been an ongoing fix pattern.
