@echo off
setlocal enabledelayedexpansion

:: Check for admin privileges and elevate if needed
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
    pushd "%CD%"
    CD /D "%~dp0"

:: Set working directory
cd /d "%~dp0"

:: Check if links.txt exists
if not exist "links.txt" (
    echo Error: links.txt not found in current directory!
    pause
    exit /b 1
)

:: Create necessary directories
if not exist "bin" mkdir "bin"
if not exist "videos" mkdir "videos"
if not exist "audios" mkdir "audios"

:: Download yt-dlp if not exists
if not exist "bin\yt-dlp.exe" (
    echo Downloading yt-dlp...
    powershell -Command "(New-Object Net.WebClient).DownloadFile('https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe', 'bin\yt-dlp.exe')"
)

:: Download FFmpeg if not exists
if not exist "bin\ffmpeg.exe" (
    echo Downloading FFmpeg...
    powershell -Command "$ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri 'https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip' -OutFile 'bin\ffmpeg.zip'"
    powershell -Command "Expand-Archive -Path 'bin\ffmpeg.zip' -DestinationPath 'bin' -Force"
    move "bin\ffmpeg-master-latest-win64-gpl\bin\*" "bin"
    rmdir /s /q "bin\ffmpeg-master-latest-win64-gpl"
    del "bin\ffmpeg.zip"
)

:: Set PATH to include local binaries
set "PATH=%~dp0bin;%PATH%"

:: Set default format to 720p
set "format=bestvideo[height<=720][ext=mp4]+bestaudio[ext=m4a]/best[height<=720][ext=mp4]"
set "folder=videos"
set "output_template=%%(playlist_title,channel)s\%%(title)s.mp4"

:: Process each link from links.txt
for /f "usebackq delims=" %%U in ("links.txt") do (
    set "video_url=%%U"
    echo Processing URL: !video_url!
    
    :: Run yt-dlp with full path
    "%~dp0bin\yt-dlp.exe" ^
        --no-update ^
        --ignore-errors ^
        --no-warnings ^
        --merge-output-format mp4 ^
        --format "%format%" ^
        --output "%~dp0%folder%\%output_template%" ^
        --no-playlist-reverse ^
        --concurrent-fragments 3 ^
        --retries 3 ^
        --ffmpeg-location "%~dp0bin" ^
        --windows-filenames ^
        "!video_url!"
    
    if !ERRORLEVEL! equ 0 (
        echo Successfully downloaded: !video_url!
    ) else (
        echo Failed to download: !video_url!
    )
    echo -------------------------------------------
)

echo All downloads completed!
pause