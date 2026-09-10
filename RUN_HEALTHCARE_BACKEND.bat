@echo off
cd /d "%~dp0backend"
echo Starting Healthcare API...
node src/complete/server_complete.js
pause
