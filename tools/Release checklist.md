- [ ] flutter test
- [ ] New changelog
- [ ] Bump version
- [ ] git add . && git commit -m "Bump version and update changelog"
- [ ] git push

- [ ] git checkout releases
- [ ] git merge main -X theirs -m "Release v<version>"
- [ ] ./tools/compile.sh
- [ ] git push

- [ ] Release on GitHub
    - [ ] Set GitHub tag and title to version number (with 'v' at the start)
    - [ ] Set GitHub target branch to releases
    - [ ] Copy changelog in to GitHub
    - [ ] Attach binaries to GitHub
- [ ] Publish
- [ ] rm daily_diary_android.apk daily_diary_linux.tar.gz
- [ ] git checkout main -f
