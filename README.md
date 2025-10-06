# MyCalendarApp

A minimal Flutter offline calendar app with:
- Hijri + Gregorian dates
- Add events with local storage (Hive)
- Local notifications (flutter_local_notifications)
- Light/Dark theme switching
- Android home screen widget (native AppWidget that reads simple shared prefs)

## How to use

1. Extract this project and open it in Android Studio or VS Code.
2. Run `flutter pub get`.
3. To run on device: `flutter run`.
4. To build release APK locally: `flutter build apk --release`.

### Notes about the widget
- The widget implementation is a minimal native Android AppWidget. It reads two SharedPreferences keys:
  - `today_count` (int)
  - `today_summary` (String)
- The Flutter app updates those keys when events change, so the widget will show today's summary.
- You must add the receiver snippet from `android/ app/src/main/AndroidManifest_add.txt` into your `AndroidManifest.xml` inside the `<application>` tag.

## GitHub Actions
A workflow is included at `.github/workflows/build_apk.yml` that builds a release APK when you push to `main`.

