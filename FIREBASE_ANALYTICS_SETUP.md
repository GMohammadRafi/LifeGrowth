# Firebase Analytics Setup and Troubleshooting

## What Was Fixed

The Firebase Analytics integration was not working because several key components were missing:

### 1. Android Configuration
- **Added Firebase plugins** to `android/build.gradle`:
  - Google Services classpath
  - Firebase BOM for dependency management
- **Added Google Services plugin** to `android/app/build.gradle`
- **Added Firebase Analytics dependency** using Firebase BOM
- **Updated Kotlin version** to 2.1.0 (was causing build warnings)

### 2. Flutter Configuration
- **Added firebase_core dependency** to `pubspec.yaml`
- **Added Firebase initialization** to `main.dart` before other services
- **Enhanced TelemetryService** with better error handling and test events

## Files Modified

1. `android/build.gradle` - Added Firebase buildscript dependencies
2. `android/app/build.gradle` - Added Google Services plugin and Firebase dependencies
3. `pubspec.yaml` - Added firebase_core dependency
4. `lib/main.dart` - Added Firebase.initializeApp() call
5. `lib/services/telemetry_service.dart` - Enhanced with test events and better logging

## Verification Steps

### 1. Check Debug Logs
When you run the app in debug mode, you should see these logs:
```
TelemetryService: Firebase Analytics initialized successfully
TelemetryService: Test event sent to verify analytics
```

### 2. Firebase Console
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `gen-lang-client-0139538207`
3. Navigate to **Analytics > Events**
4. Look for the `app_initialized` event (may take 24-48 hours to appear)

### 3. Real-time Events (Debug Mode)
To see events in real-time during development:
1. In Firebase Console, go to **Analytics > DebugView**
2. Enable debug mode on your device by running:
   ```bash
   adb shell setprop debug.firebase.analytics.app app.lifegrowth
   ```
3. Run your app and you should see events appearing in real-time

## Common Issues and Solutions

### Issue: "Could not find com.google.firebase:firebase-core"
**Solution**: The `firebase-core` dependency is deprecated. Use Firebase BOM instead (already implemented).

### Issue: Events not showing in Firebase Console
**Possible causes**:
1. **Delay**: Analytics data can take 24-48 hours to appear
2. **Debug mode**: Use DebugView for real-time testing
3. **Network**: Ensure device has internet connection
4. **App ID mismatch**: Verify `google-services.json` matches your Firebase project

### Issue: Build failures
**Solution**: 
1. Run `flutter clean`
2. Run `flutter pub get`
3. Rebuild the project

## Testing Analytics

The app now sends several types of analytics events:
- `app_initialized` - When the app starts
- `task_toggle` - When tasks are completed/uncompleted
- `detail_edit` - When task details are edited
- `task_detail_edit` - When task details are modified

## Next Steps

1. **Test the app** on a physical device or emulator
2. **Check debug logs** to ensure Firebase is initializing properly
3. **Enable DebugView** in Firebase Console for real-time event monitoring
4. **Wait 24-48 hours** for data to appear in standard Analytics reports

## Important Notes

- The `google-services.json` file is correctly placed in `android/app/`
- Your Firebase project ID is: `gen-lang-client-0139538207`
- Your Android package name is: `app.lifegrowth`
- Analytics collection is enabled by default

If you continue to have issues, check the debug logs in your IDE console when running the app.