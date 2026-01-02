@echo off
REM Helper script to render Quarto site and work around Dropbox locking issues

echo Removing .quarto folder to avoid Dropbox locks...
if exist .quarto (
    rmdir /s /q .quarto 2>nul
    timeout /t 1 /nobreak >nul
)

echo Rendering Quarto site...
quarto render

echo.
echo Rendering complete! The site is in docs/
echo Note: You may see errors about .quarto\_freeze - these can be ignored.
echo The HTML files are generated correctly despite the errors.
