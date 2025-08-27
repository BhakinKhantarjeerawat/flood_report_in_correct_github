# 📱 Update Reminder Setup Guide

## 🎯 What This Feature Does

The Update Reminder Screen shows users a beautiful update prompt when they open the app, encouraging them to update monthly for the best experience.

## 🔧 Setup Required

### 1. Update App Store URLs

In `lib/screeens/update_reminder_screen.dart`, replace the placeholder URLs:

**For iOS (App Store):**
```dart
const String appStoreUrl = 'https://apps.apple.com/app/your-app-id';
```
Replace `your-app-id` with your actual iOS app ID.

**For Android (Play Store):**
```dart
const String playStoreUrl = 'https://play.google.com/store/apps/details?id=your.package.name';
```
Replace `your.package.name` with your actual Android package name.

### 2. Customize Update Message

You can modify the update message in the same file:
- Title: "Update Available!"
- Subtitle: "Keep your Flood Marker app updated"
- Monthly tip: "Update your app monthly for the best experience!"

### 3. Update Benefits

The screen shows three update benefits:
- Security Updates
- Bug Fixes  
- New Features

You can customize these in the `UpdateBenefit` widgets.

## 🚀 How It Works

1. **App Launch**: Shows Update Reminder Screen first
2. **Version Display**: Shows current app version
3. **Update Button**: Opens appropriate app store
4. **Continue Button**: Allows users to proceed to main app
5. **Monthly Reminder**: Friendly tip about monthly updates

## 📱 User Experience

- **Non-Forced**: Users can choose to update or continue
- **Platform Aware**: Automatically detects iOS/Android
- **Beautiful Design**: Matches your app's theme
- **Easy Navigation**: Clear paths to update or continue

## 🔄 Customization Options

### Show Update Reminder Every Time
Currently shows every app launch. To change this:

1. Add SharedPreferences to store last shown date
2. Check if 30 days have passed
3. Only show reminder monthly

### Add Version Checking
To show reminder only for outdated versions:

1. Add server endpoint for latest version
2. Compare current vs. latest version
3. Show reminder only when update needed

## 📋 Files Modified

- `lib/screeens/update_reminder_screen.dart` - New update reminder screen
- `lib/main.dart` - Added import and route
- `pubspec.yaml` - Added package_info_plus dependency

## ✅ Ready to Use

After updating the app store URLs, the update reminder will work immediately!

Users will see the beautiful update screen every time they open the app, encouraging them to keep their Flood Marker app updated monthly.
