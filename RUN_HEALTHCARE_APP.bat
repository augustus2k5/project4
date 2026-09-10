@echo off
cd /d "%~dp0app"
echo Getting Flutter packages...
flutter pub get
echo Starting Patient App...
flutter run -t lib/main_booking.dart -d chrome
pause
