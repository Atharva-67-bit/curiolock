# Publishing CurioLock to the App Store (iOS) & Play Store (Android)

You have a Windows laptop and a paid developer account. iOS apps **cannot** be built
on Windows, so we use **Codemagic** — a free cloud CI with macOS machines that builds
**both** the Android and iOS apps for you. You then upload them to the stores.

App identity (already set in the project):
- **App name:** CurioLock
- **Bundle ID / Application ID:** `com.curiousaders.curiolock`  *(change everywhere if your developer account uses a different one)*
- **Version:** 1.0.0 (build 1) — set in `pubspec.yaml` (`version: 1.0.0+1`)

---

## Step 1 — Put the code on GitHub (one time)
Codemagic builds from a git repo.
```powershell
cd C:\dev\curiolock_app
git init
git add .
git commit -m "CurioLock app ready for cloud build"
```
Then create an empty repo on github.com (e.g. `curiolock`) and push:
```powershell
git remote add origin https://github.com/<your-username>/curiolock.git
git branch -M main
git push -u origin main
```

## Step 2 — Connect Codemagic
1. Go to **https://codemagic.io** → sign up with your **GitHub** account (free).
2. **Add application** → pick your `curiolock` repo → it detects Flutter + the `codemagic.yaml`.

---

## Step 3A — Android (APK to share + AAB for Play Store)

**Create a signing key** (do this once, on your laptop):
```powershell
& "C:\Android\jdk17\jdk-17.0.19+10\bin\keytool.exe" -genkey -v -keystore curiolock.jks -keyalg RSA -keysize 2048 -validity 10000 -alias curiolock
```
Answer the prompts; remember the password.

**Add it to Codemagic:** Teams → your app → **Code signing identities → Android keystores** → upload `curiolock.jks`, enter the password + alias. Reference group `android_keystore` (already in `codemagic.yaml`).

**Build:** in Codemagic, run the **`android-release`** workflow → download the **`.apk`** (install on any Android / share) and **`.aab`** (for the Play Store).

**Publish to Play Store:**
1. **play.google.com/console** → pay the **$25 one-time** fee → **Create app**.
2. App name **CurioLock**, package `com.curiousaders.curiolock`.
3. Upload the **`.aab`**, fill the listing (below), submit for review (~hours–days).

> Don't need the store? The **`.apk`** alone installs directly on any Android phone — perfect for the competition without paying $25.

---

## Step 3B — iOS (IPA → App Store / TestFlight)

**Register the app with Apple (one time):**
1. **developer.apple.com** → Certificates, IDs & Profiles → **Identifiers** → register an App ID `com.curiousaders.curiolock` with **Bluetooth** capability if listed.
2. **App Store Connect** (appstoreconnect.apple.com) → **My Apps → +** → create **CurioLock** with that bundle ID.

**Give Codemagic permission to sign/upload (App Store Connect API key):**
1. App Store Connect → **Users and Access → Integrations → App Store Connect API** → generate a key (Admin/App Manager role). Download the `.p8`, note the **Key ID** + **Issuer ID**.
2. Codemagic → **Teams → Integrations → App Store Connect** → add the key → name it **`CurioLock_ASC_Key`** (matches `codemagic.yaml`).

**Build:** run the **`ios-release`** workflow. Codemagic auto-creates the signing certificate/profile, builds the **`.ipa`**, and (per the yaml) uploads it to **TestFlight**.

**Publish to App Store:**
1. In **App Store Connect**, the build appears under TestFlight in ~15–30 min.
2. Fill the listing (below), attach the build, **Submit for Review** (~1–3 days).

---

## Store listing assets you'll need (both stores)
- **App icon** 1024×1024 (replace the default Flutter icon — ask me and I'll generate a CurioLock icon).
- **Screenshots** (phone) — capture from the running app or the web demo.
- **Short + full description** — use the pitch from the project handbook.
- **Privacy policy URL** — required by both stores. A simple page stating the app uses Bluetooth to control the user's own vault and stores no personal data beyond the login.
- **Category:** Utilities / Tools.

---

## Cost summary
| | Cost | You have it? |
|---|------|---|
| Codemagic (cloud build, both platforms) | Free tier | sign up |
| Google Play Developer | $25 once | — |
| Apple Developer | $99 / year | ✅ (your paid account) |

---

## Important reminders
- The app talks to the vault over **real Bluetooth** on phones (`useMock = kIsWeb` → false on mobile). Make sure the **ESP32 UUIDs in `lib/services/ble_service.dart` match the firmware** before the store build.
- Bump `version:` in `pubspec.yaml` for every new store upload (e.g. `1.0.1+2`).
- Test the **.apk** (and a **TestFlight** install on a real iPhone) before submitting for review.
- If a build fails on Codemagic, copy me the log and I'll fix the config.
