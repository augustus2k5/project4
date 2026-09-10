@echo off
cd /d "%~dp0admin"
echo Getting Flutter packages...
flutter pub get
echo Starting Admin App...
flutter run -t lib/main_complete.dart -d chrome
pause
