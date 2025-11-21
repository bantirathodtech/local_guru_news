# 📱 Google Play Store Release Build Checklist

## ✅ Configuration Updates Completed

1. **build.gradle** - Added proper signing configuration
   - ✅ Added keystore properties loading
   - ✅ Added release signing config
   - ✅ Updated release build type to use proper signing

2. **key.properties** - Updated path format
   - ✅ Changed from Windows path to relative path
   - ✅ Updated path to: `../upload-key.keystore`

3. **Version Information**
   - Current version: `2.0.0+4` (from pubspec.yaml)
   - Version code: 4
   - Version name: 2.0.0

## ⚠️ REQUIRED ACTIONS Before Building

### 1. Place Keystore File
You need to place your keystore file (`upload-key.keystore`) in one of these locations:

**Option A (Recommended):**
```
android/upload-key.keystore
```

**Option B:**
```
android/app/upload-key.keystore
```
Then update `android/key.properties`:
```
storeFile=upload-key.keystore
```

### 2. Verify Keystore Credentials
Current configuration in `android/key.properties`:
- Store Password: `suvidha@123`
- Key Password: `suvidha@123`
- Key Alias: `upload`

**If you don't have the keystore file**, create a new one:
```bash
cd android
keytool -genkey -v -keystore upload-key.keystore -alias upload \
  -keyalg RSA -keysize 2048 -validity 10000
```
Then enter the same passwords when prompted.

### 3. Verify AndroidManifest.xml
- ✅ Application ID: `com.localguru.news`
- ✅ App label: `Local Guru`
- ✅ Minimum SDK: From Flutter defaults
- ✅ Target SDK: 36 (Google Play compliant)

### 4. Test Build (Optional but Recommended)
```bash
# Clean previous builds
flutter clean

# Build APK first to test (optional)
flutter build apk --release

# Build App Bundle for Play Store
flutter build appbundle --release
```

### 5. Verify Output
After successful build, check:
- Location: `build/app/outputs/bundle/release/app-release.aab`
- File size: Should be reasonable (typically 20-50 MB)
- Upload to Google Play Console: Internal testing track first

## 📋 Pre-Upload Checklist

- [ ] Keystore file placed in correct location
- [ ] Version number updated if needed (pubspec.yaml)
- [ ] App tested thoroughly
- [ ] All features working
- [ ] Permissions declared in AndroidManifest.xml
- [ ] Privacy policy URL added (if required)
- [ ] App screenshots prepared
- [ ] App description prepared
- [ ] **Test account created for Google Play reviewers** (see GOOGLE_PLAY_ACCESS_INSTRUCTIONS.md)
- [ ] **App access instructions prepared in Google Play Console**

## 🚀 Build Command

Once everything is ready:
```bash
flutter build appbundle --release
```

The output will be at:
```
build/app/outputs/bundle/release/app-release.aab
```

## 📝 Notes

- **NEVER share your keystore file or passwords**
- Keep keystore file backed up safely (required for all future updates)
- If keystore is lost, you cannot update the app on Play Store
- Version code must always increase for each upload
