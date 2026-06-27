# Firebase setup — real accounts, email verification, password reset

The code for sign-up, sign-in, **email verification**, **forgot password**, and
**email validation** is already built into the app. It just needs a free
**Firebase project** to talk to. Until you do this, the app runs in **demo
login** mode (any email/password works, no real verification). After setup, real
accounts activate automatically.

## 1. Create the Firebase project (free, 3 min)
1. Go to **https://console.firebase.google.com** → **Add project** → name it `CurioLock` → continue (you can skip Analytics).

## 2. Turn on Email/Password sign-in
- In the project: **Build → Authentication → Get started → Sign-in method → Email/Password → Enable → Save.**
- This is what powers verification emails + password-reset emails (Firebase sends them for you, free).

## 3. Add the Android app
1. Firebase Console → **Project Overview → Add app → Android**.
2. **Android package name:** `com.curiousaders.curiolock` (must match exactly).
3. Download the **`google-services.json`** file.
4. Put it in your project at: **`android/app/google-services.json`**.

## 4. Add the Google-Services Gradle plugin
Edit **`android/settings.gradle.kts`** — inside the `plugins { ... }` block add:
```kotlin
id("com.google.gms.google-services") version "4.4.2" apply false
```
Edit **`android/app/build.gradle.kts`** — inside its `plugins { ... }` block add:
```kotlin
id("com.google.gms.google-services")
```

## 5. (iOS) Add the iOS app — only if building for iPhone
- Firebase Console → Add app → **iOS** → bundle ID `com.curiousaders.curiolock`.
- Download **`GoogleService-Info.plist`** → put it in **`ios/Runner/`** (and add it to the Runner target in Xcode / via Codemagic).

## 6. Commit + rebuild
```powershell
cd C:\dev\curiolock_app
git add -A
git commit -m "Add Firebase config"
git push
```
Then run the Codemagic build again → the new APK has **real accounts**:
- **Create account** → Firebase makes the user + sends a verification email.
- **Email verification** → user clicks the link, then taps "I've verified".
- **Sign in** → checks the real email + password.
- **Forgot password** → Firebase emails a reset link.

## Notes
- `google-services.json` is safe to commit for a student project. If you prefer to keep it out of a public repo, make the GitHub repo **Private** (Settings → Danger Zone), or add it in Codemagic as an environment file.
- Email verification + reset emails come **from Firebase** — check spam the first time.
- The app still works without all this (demo login) — so nothing breaks if you set it up later.
