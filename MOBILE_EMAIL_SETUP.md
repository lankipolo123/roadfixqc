# RoadFix Mobile App - Email System Documentation

## CRITICAL CHANGE: Domain Update

**The web dashboard domain has changed from `roadfix-web.vercel.app` to `roadfix-dashboard.vercel.app`**

This affects all email verification and password reset functionality.

---

## How Email Verification Works in RoadFix

### The Complete Flow

```
1. User Signs Up (Mobile)
   ↓
2. Firebase creates account (unverified)
   ↓
3. Mobile calls EmailService.sendVerificationEmail()
   ↓
4. API generates verification link pointing to web dashboard
   ↓
5. Brevo sends email to user
   ↓
6. User clicks link in email
   ↓
7. Link opens web dashboard (https://roadfix-dashboard.vercel.app/verify-email)
   ↓
8. Web dashboard verifies the Firebase oobCode
   ↓
9. User account is marked as verified
   ↓
10. User can now login on mobile
```

---

## What Changed in This Update

### ✅ FIXED: lib/services/email_service.dart

**Line 9** - Updated base URL:

```dart
// OLD (BROKEN):
static const String _baseUrl = 'https://roadfix-web.vercel.app/api';

// NEW (CORRECT):
static const String _baseUrl = 'https://roadfix-dashboard.vercel.app/api';
```

This single change fixes:
- Email verification emails
- Password reset emails
- All email-related API calls

---

## Mobile App Email Architecture

### Key Files

#### 1. `lib/services/email_service.dart`
- Sends verification emails via Vercel API
- Sends password reset emails via Vercel API
- **CONTAINS THE CRITICAL DOMAIN URL**

#### 2. `lib/services/auth_service.dart`
- Calls EmailService for verification/reset
- Methods:
  - `resendEmailVerification()` → calls EmailService
  - `resetPassword()` → calls EmailService
  - `_sendEmailVerification()` → calls EmailService

#### 3. `lib/screens/auth_screens/email_verification_screen.dart`
- UI for email verification flow
- "Resend Verification Email" button
- "I've Verified My Email" button

#### 4. `lib/screens/auth_screens/forgot_password_screen.dart`
- UI for password reset flow
- "Send Reset Email" button

---

## How The Email System Works Technically

### Verification Email Flow

1. **Mobile Triggers Email** (`email_service.dart:13-40`)
   ```dart
   EmailService.sendVerificationEmail(email)
   ```

2. **API Endpoint Called**
   ```
   POST https://roadfix-dashboard.vercel.app/api/send-verification-email
   Body: { "email": "user@example.com" }
   ```

3. **Web API Generates Link** (Vercel Function)
   ```javascript
   const actionCodeSettings = {
     url: 'https://roadfix-dashboard.vercel.app/verify-email',
     handleCodeInApp: false  // Opens in browser, not in-app
   };

   const link = await admin.auth().generateEmailVerificationLink(
     email,
     actionCodeSettings
   );
   ```

4. **Brevo Sends Email**
   - Email contains: `https://roadfix-dashboard.vercel.app/verify-email?oobCode=ABC123...`

5. **User Clicks Link**
   - Opens web dashboard in browser
   - Web dashboard verifies the `oobCode` with Firebase
   - Firebase marks user as verified

6. **Mobile Checks Status**
   ```dart
   await _authService.checkEmailVerificationAndActivate()
   // Reloads user and checks emailVerified flag
   ```

### Password Reset Flow

Same flow, different endpoints:
- API: `/api/send-reset-email`
- Web page: `/reset-password`

---

## Why The Domain Matters

### The Problem With Wrong Domain

If the domain in `email_service.dart` is wrong:

❌ API calls go to non-existent server
❌ Emails never get sent
❌ Users can't verify their accounts
❌ Password reset fails

### What The Correct Domain Does

✅ API calls reach the correct Vercel deployment
✅ Emails get sent via Brevo
✅ Verification links point to correct web dashboard
✅ Users can complete verification flow

---

## Testing The Email System

### Test Email Verification

1. Sign up a new test user in mobile app
2. Check email inbox
3. Verify email contains link like:
   ```
   https://roadfix-dashboard.vercel.app/verify-email?oobCode=...
   ```
4. Click link → should open web dashboard
5. Web should show "Email verified successfully"
6. Go back to mobile app
7. Tap "I've Verified My Email"
8. Should navigate to main app

### Test Password Reset

1. On login screen, tap "Forgot Password?"
2. Enter email and tap "Send Reset Email"
3. Check email inbox
4. Verify email contains link like:
   ```
   https://roadfix-dashboard.vercel.app/reset-password?oobCode=...
   ```
5. Click link → should open web dashboard
6. Enter new password and submit
7. Go back to mobile app
8. Login with new password

---

## Common Issues & Solutions

### Issue: "Failed to send verification email"

**Cause:** Network error or API endpoint unreachable

**Solutions:**
- Check internet connection
- Verify domain is `roadfix-dashboard.vercel.app`
- Check Vercel deployment status
- Check API function logs

### Issue: User clicks email link but nothing happens

**Cause:** Email link points to wrong domain

**Solutions:**
- Check that email contains `roadfix-dashboard.vercel.app`
- If it contains `roadfix-web.vercel.app`, the domain wasn't updated
- Make sure `email_service.dart` line 9 has correct URL

### Issue: "Email already verified" but user can't login

**Cause:** Firebase user verified but Firestore `isActive` flag not updated

**Solutions:**
- Check `auth_service.dart:40-59` → `checkEmailVerificationAndActivate()`
- This method updates Firestore after verification

---

## Mobile Responsibilities vs Web Responsibilities

### Mobile Does:
- Trigger verification email sending
- Trigger password reset email sending
- Check if user is verified
- Handle "resend verification email" button
- Navigate user after successful verification

### Web Dashboard Does:
- Provide verification landing pages (`/verify-email`, `/reset-password`)
- Process Firebase `oobCode` from email links
- Verify user accounts in Firebase
- Show success/error messages
- Handle actual password reset form

### Mobile Does NOT:
- ❌ Process `oobCode` directly
- ❌ Verify users (Firebase Admin SDK required)
- ❌ Send emails directly (done via web API)

---

## Firebase Configuration

### Firebase Project
- Project ID: `roadfixqc-admin`
- Platform: Android, iOS, Web, Windows

### Email Action Links
All email action links redirect to: `https://roadfix-dashboard.vercel.app`

This is configured in:
- Web API's actionCodeSettings
- Firebase Console (if configured there)

---

## API Endpoints Used By Mobile

### 1. Send Verification Email
```
POST https://roadfix-dashboard.vercel.app/api/send-verification-email

Headers:
  Content-Type: application/json

Body:
  { "email": "user@example.com" }

Response (Success):
  { "success": true, "message": "Verification email sent" }

Response (Error):
  { "success": false, "message": "Error message here" }
```

### 2. Send Password Reset Email
```
POST https://roadfix-dashboard.vercel.app/api/send-reset-email

Headers:
  Content-Type: application/json

Body:
  { "email": "user@example.com" }

Response (Success):
  { "success": true, "message": "Reset email sent" }

Response (Error):
  { "success": false, "message": "Error message here" }
```

---

## For Future Updates

### If Dashboard Domain Changes Again

Update this single line in `lib/services/email_service.dart`:

```dart
static const String _baseUrl = 'https://NEW-DOMAIN-HERE.vercel.app/api';
```

### If API Endpoints Change

Update method names in `email_service.dart`:
- Line 16: `/send-verification-email`
- Line 47: `/send-reset-email`

---

## Summary

**What was the problem?**
- Mobile was calling old domain `roadfix-web.vercel.app`
- Web dashboard moved to `roadfix-dashboard.vercel.app`
- Email links were going to wrong place

**What was the fix?**
- Changed one line in `email_service.dart` (line 9)
- Updated base URL to new dashboard domain

**Why does it work now?**
- Mobile calls correct API endpoint
- API generates links pointing to correct web dashboard
- Users can verify emails successfully
- Password reset works correctly

---

## Contact & Support

If you have questions about the email system:
1. Check this documentation first
2. Review `lib/services/email_service.dart` for API calls
3. Check web dashboard `/api/send-verification-email.js` for backend logic
4. Test with a real email to verify the complete flow

---

**Last Updated:** 2025-11-14
**Change:** Updated domain from roadfix-web to roadfix-dashboard
