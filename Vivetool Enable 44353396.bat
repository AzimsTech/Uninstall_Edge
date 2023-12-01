@echo off
setlocal EnableDelayedExpansion

set "params=%*"
cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && ""%~s0"" %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )


:: GitHub repository and API URL
set "repoOwner=thebookisclosed"
set "repoName=ViVe"
set "apiUrl=https://api.github.com/repos/%repoOwner%/%repoName%/releases/latest"

:: Define the file path for ViVeTool.zip
set "zipFilePath=%CD%\ViVeTool.zip"

:: Check if the file already exists before attempting to download
if not exist "%zipFilePath%" (
    :: Get latest release download URL
    for /f "usebackq tokens=*" %%A in (`curl -s %apiUrl% ^| findstr /C:"browser_download_url"`) do (
        set "line=%%A"
        set "line=!line:*browser_download_url": =!"
        set "line=!line:,=!"
        set "line=!line:\"=!"
        set "downloadURL=!line!"
    )

    :: Download the latest release if URL is obtained
    if defined downloadURL (
        echo Downloading ViVeTool...
        bitsadmin.exe /transfer "ViVeToolDownload" "!downloadURL!" "%zipFilePath%"
        echo Download complete.
        
        :: Extract the contents of ViVeTool.zip
        echo Extracting ViVeTool...
        powershell -command "Expand-Archive -Path '%zipFilePath%' -DestinationPath '%CD%\ViVeTool'"
        echo Extraction complete.
    ) else (
        echo Failed to retrieve download URL for the latest release.
    )
) else (
    echo ViVeTool.zip already exists. Skipping download.
)

:: Rest of the script remains the same

set "curPath=%~dp0"

echo !curPath!vivetool.exe
for /D %%I in ("!curPath!ViVeTool*") do (
    %%I\vivetool.exe /enable /id:44353396
)


pause
