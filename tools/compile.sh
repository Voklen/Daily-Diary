flutter build apk
flutter build linux
cp build/app/outputs/flutter-apk/app-release.apk daily_diary_android.apk
cp -r build/linux/x64/release/bundle/ Daily-Diary/
tar -czf daily_diary_linux.tar.gz Daily-Diary/
rm -r Daily-Diary/
