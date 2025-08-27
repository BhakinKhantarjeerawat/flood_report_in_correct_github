# 🎛️ Location Toggle Guide for Development

## Quick Switch Between Mock and Real GPS

The flood report form now has a **simple toggle system** that lets you easily switch between mock location and real GPS during development.

### 🔧 How to Use the Toggle

**File**: `lib/screeens/flood_report_form.dart`

**Line**: Look for this comment near the top:
```dart
// 🎛️ DEVELOPMENT TOGGLE: Easy switch between mock and real GPS
// Change this to false when you want to test with real GPS
const bool useMockLocation = true;
```

### 📱 Toggle Options

| Setting | Mode | Description |
|---------|------|-------------|
| `useMockLocation = true` | 🎯 **MOCK** | Uses fixed Bangkok location (13.7563, 100.5018) |
| `useMockLocation = false` | 📍 **GPS** | Uses real device GPS location |

### 🎯 Mock Location Mode (Recommended for Development)

**Benefits:**
- ✅ **No GPS required** - works on any device/emulator
- ✅ **Consistent location** - same coordinates every time
- ✅ **No permissions** - works immediately
- ✅ **Fast testing** - no waiting for GPS
- ✅ **Predictable** - perfect for debugging

**Location**: Bangkok, Thailand (13.7563°N, 100.5018°E)

### 📍 Real GPS Mode (For Production Testing)

**Benefits:**
- ✅ **Real location data** - actual device coordinates
- ✅ **Production-like** - tests real user experience
- ✅ **Permission testing** - tests location access flow
- ✅ **Device testing** - works with real GPS hardware

**Requirements:**
- Location permissions granted
- GPS service enabled
- Real device or emulator with GPS

### 🔄 How to Switch

1. **Open** `lib/screeens/flood_report_form.dart`
2. **Find** the toggle comment (around line 20)
3. **Change** `useMockLocation = true` to `useMockLocation = false`
4. **Save** the file
5. **Hot reload** your app (press `r` in terminal)

### 🎨 Visual Indicators

The form shows which mode is active:

- **Orange "MOCK" badge** with robot icon = Mock location mode
- **Green "GPS" badge** with GPS icon = Real GPS mode
- **Button text changes** to reflect current mode
- **Success messages** indicate which mode was used

### 🚀 Development Workflow

1. **Start with Mock** (`useMockLocation = true`)
   - Test form validation
   - Test photo uploads
   - Test UI responsiveness
   - No GPS complications

2. **Switch to GPS** (`useMockLocation = false`)
   - Test real location flow
   - Test permission handling
   - Test production behavior
   - Final testing before release

### 💡 Pro Tips

- **Keep mock during development** - faster iteration
- **Switch to GPS before testing** - catch real-world issues
- **Use mock for demos** - consistent location every time
- **Test both modes** - ensure both paths work correctly

### 🔍 Current Status

**Default**: Mock location mode is **enabled** (`useMockLocation = true`)

**Perfect for**: Current development stage, testing, and debugging
