# How to Merge Claude Branches into Main

## Current Branch

**Branch:** `claude/fix-location-badge-cRWHm`

**Changes:**
- Fixed location badge not fetching by running user data and location loading in parallel (`Future.wait`)
- Added `getLastKnownPosition()` as instant fallback before active GPS in `getCurrentLocation()`
- Added `openSettings` parameter to `checkLocationPermission()` so the header badge doesn't auto-redirect to app settings on startup
- Changed `LocationAccuracy.best` to `LocationAccuracy.high` for faster GPS locks
- Added `LocationStatus` enum and `getLocationStatus()` for granular state tracking
- Smart location badge: shows "Enable GPS" / "Allow location" / "Location blocked" with context-aware tap actions
- GPS service status listener: auto-retries location when GPS is toggled on, updates badge when toggled off
- Created `LocationGuidanceDialog` for guiding users to enable GPS or grant permissions
- Created `LocationPermissionScreen` shown once on first launch to request location permission
- Updated login and email verification to route through permission screen on first launch
- Added `NSLocationWhenInUseUsageDescription` to iOS Info.plist (was missing — would crash on iOS)

**Files Changed:**
- `lib/screens/module_screens/home_screen.dart`
- `lib/services/geolocation_services.dart`
- `lib/utils/location_permission_manager.dart`
- `lib/widgets/dialog_widgets/location_guidance_dialog.dart` (new)
- `lib/widgets/home_widgets/home_header_widgets/home_header.dart`
- `lib/screens/secondary_screens/location_permission_screen.dart` (new)
- `lib/screens/auth_screens/login_screen.dart`
- `lib/screens/auth_screens/email_verification_screen.dart`
- `ios/Runner/Info.plist`

---

## Merge Steps

```bash
# 1. Fetch the latest main branch from remote
git fetch origin main

# 2. Fetch the Claude feature branch from remote
git fetch origin claude/fix-location-badge-cRWHm

# 3. Switch to your local main branch
git checkout main

# 4. Pull the latest main so you're up to date
git pull origin main

# 5. Merge the Claude branch into main
git merge origin/claude/fix-location-badge-cRWHm

# 6. Push the updated main to remote
git push origin main
```

---

## What Each Command Does

| Command | What It Does |
|---------|-------------|
| `git fetch origin main` | Downloads the latest `main` from GitHub without changing your local files |
| `git fetch origin claude/...` | Downloads the latest Claude feature branch from GitHub |
| `git checkout main` | Switches your working directory to the `main` branch |
| `git pull origin main` | Updates your local `main` with any new commits from remote |
| `git merge origin/claude/...` | Merges the Claude branch commits into your current branch (`main`) |
| `git push origin main` | Uploads your updated `main` branch to GitHub |

---

## If There Are Merge Conflicts

```bash
# See which files have conflicts
git status

# Open conflicting files, resolve the <<<< ==== >>>> markers
# Then:
git add <resolved-files>
git commit -m "Merge claude branch with conflict resolution"
git push origin main
```

---

## Cleanup (Optional)

After merging, delete the feature branch if you no longer need it:

```bash
# Delete local branch
git branch -d claude/fix-location-badge-cRWHm

# Delete remote branch
git push origin --delete claude/fix-location-badge-cRWHm
```

---

## Previous Branches

| Branch | Description |
|--------|-------------|
| `claude/email-system-documentation-01SQSwtB1tC5U2Y8sWGN885E` | Email system fix - updated API endpoint domain |
| `claude/review-detection-mechanism-O35UP` | Lint fixes - removed unused fields and variables |
| `claude/fix-location-badge-cRWHm` | Fix location badge not fetching on home screen |
