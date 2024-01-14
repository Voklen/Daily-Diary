#!/usr/bin/env sh

flutter test

python3 tools/bump_version.py "$1"
git add . && git commit -m "Bump version and update changelog"
git push

git checkout releases
git merge main -X theirs -m "Release v$1"
git submodule init
git submodule update
./submodules/flutter/bin/flutter build apk
./submodules/flutter/bin/flutter build linux
cp build/app/outputs/flutter-apk/app-release.apk daily_diary_android.apk
cp -r build/linux/x64/release/bundle/ Daily-Diary/
tar -czf daily_diary_linux.tar.gz Daily-Diary/
rm -r Daily-Diary/
git push
