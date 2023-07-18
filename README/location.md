# Location Setup

[Link](https://pub.dev/packages/location)

## Android

Agregar los permisos necesarios en el archivo `android/app/src/main/AndroidManifest.xml` (también para las carpetas debug & profile)

```xml
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION"/>
```

## iOS

Agregar los permisos en el archivo `ios/Runner/Info.plist`

```xml
<key>NSLocationWhenInUseUsageDescription</key>	
<string>Save location on form submit</string>
```
