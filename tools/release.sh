#!/usr/bin/env sh

# Exit if any error is encountered
set -e

if [ -z "$1" ]; then
    echo "Usage: ./tools/release.sh <version number"
    echo "Note that the version number should be without a leading 'v'"
    echo "i.e. 1.4.4 rather than v1.4.4"
fi

echo "Press enter once you've updates the version in pubspec.yaml and added a changelog. (ctrl + c to cancel)"
read -r
git add .
git commit -m "Bump version and update changelog"

echo "Should I push this state to GitHub? (ctrl + c to cancel)"
read -r
git push

git checkout releases
git submodule init
git submodule update --remote
git commit -a -m "Update flutter submodule"
git merge main -X theirs -m "Release v$1"
./submodules/flutter/bin/flutter build apk
./submodules/flutter/bin/flutter build linux
cp build/app/outputs/flutter-apk/app-release.apk daily_diary_android.apk
cp -r build/linux/x64/release/bundle/ Daily-Diary/
tar -czf daily_diary_linux.tar.gz Daily-Diary/
rm -r Daily-Diary/


echo "Should I push this state to GitHub? (ctrl + c to cancel)"
read -r
git push
