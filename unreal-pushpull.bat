@echo off

:: Gather text colors functionality
( for /f "delims=" %%i in ('echo prompt $E^| cmd') do set "ESC=%%i" & reg query HKCU\Console /v VirtualTerminalLevel >nul 2>nul || reg add HKCU\Console /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul ) || echo ERR: color compatibility failure.

echo Script to push and pull between local projects in Unreal Engine and GitHub.

:start
set "PROJNAME="
set "BRANCH="
set /p PROJNAME="Enter project name: "
set /p BRANCH="Enter branch: "
if "%PROJNAME%"=="" if "%BRANCH%"=="" ( echo %ESC%[33mWritten values are empty. Rerunning.%ESC%[0m && goto start )
if "%PROJNAME%"=="" ( echo %ESC%[33mWritten project name is empty. Rerunning.%ESC%[0m && goto start )
if "%BRANCH%"=="" ( echo %ESC%[33mWritten branch is empty. Rerunning.%ESC%[0m && goto start )

set "PROJECT_DIR=%USERPROFILE%\Documents\Unreal Projects\%PROJNAME%"

cd /d %PROJECT_DIR% || (echo %ESC%[31mProject folder not found: %PROJECT_DIR%. Rerunning.%ESC%[0m && goto start)
( git rev-parse --is-inside-work-tree >nul 2>&1 || (echo Not a git repo here. & pause & exit /b 1) && echo Fetching . . . && git fetch origin ) ^
|| goto fatal

echo %ESC%[36mBeginning operation . . .%ESC%[0m

goto decide

:decide
set "DECIDE="
set /p DECIDE="Push to GitHub files or pull to local UE project folder? (push/pull) "
if "%DECIDE%"=="" goto cancel-operation
if /I "%DECIDE%"=="push" goto push-confirm
if /I "%DECIDE%"=="pull" goto pull-confirm

echo %ESC%[33mInvalid option. Please type push, pull, or press enter to cancel.%ESC%[0m
goto decide

:: Push Operations
:push-confirm
set "CONFIRM="
echo %ESC%[33mWarning: This will overwrite the current GitHub repository: origin/%BRANCH%.%ESC%[0m
set /p CONFIRM="Are you sure you want to continue? (y/N) "
if "%CONFIRM%"=="" ( echo Cancelling operation . . . && goto cancel-operation )
if /I "%CONFIRM%"=="n" ( echo Cancelling operation . . . && goto cancel-operation )
if /I "%CONFIRM%"=="y" ( ( git push --force origin %BRANCH% && goto push-finish ) || ( git push --force origin %BRANCH% && goto push-finish ) || goto fatal )

echo %ESC%[33mInvalid option. Please type Y, N, or press enter to choose the default option (N).%ESC%[0m
goto push-confirm

:: Pull Operations
:pull-confirm
set "CONFIRM="
echo %ESC%[33mWarning: This will overwrite your local files in directory: %PROJECT_DIR%.%ESC%[0m
set /p CONFIRM="Are you sure you want to continue? (y/N) "
if "%CONFIRM%"=="" ( echo Cancelling operation . . . && goto cancel-operation )
if /I "%CONFIRM%"=="n" ( echo Cancelling operation . . . && goto cancel-operation )
if /I "%CONFIRM%"=="y" ( ( git pull && goto pull-finish ) || goto pull-fallback )

echo %ESC%[33mInvalid option. Please type Y, N, or press enter to choose the default option (N).%ESC%[0m
goto pull-confirm

:pull-confirm-fallback
set "CONFIRM="
echo %ESC%[33mWarning: This will overwrite your local files in directory: %PROJECT_DIR%. %ESC%[0m
set /p CONFIRM="Are you sure you want to continue? (y/N) "
if "%CONFIRM%"=="" ( echo Cancelling operation . . . && goto cancel-operation )
if /I "%CONFIRM%"=="n" ( echo Cancelling operation . . . && goto cancel-operation )
if /I "%CONFIRM%"=="y" ( ( git pull --force origin %BRANCH% && goto pull-finish ) || goto fatal )

echo %ESC%[33mInvalid option. Please type Y, N, or press enter to choose the default option (N).%ESC%[0m
goto confirm-fallback

:pull-fallback
echo %ESC%[36mMain operation failure; attempting branch repair . . .%ESC%[0m
git fetch origin
git reset --hard origin/main
git clean -fd
goto confirm-fallback

:: End Conditions
:push-finish
echo Files pushed successfully.
goto end

:pull-finish
echo Files pulled successfully
goto end

:fatal
echo %ESC%[33mOperation failed. Read errors for more info.%ESC%[0m

pause
exit

:cancel-operation
set "QUIT="
set /p QUIT="%ESC%[36mOperation cancelled. Exit?%ESC%[0m (Y/n)"
if "%QUIT%"=="" exit
if /I "%QUIT%"=="y" exit
if /I "%QUIT%"=="n" goto decide

:end
set "QUIT="
set /p QUIT="%ESC%[36mOperation complete. Exit?%ESC%[0m (Y/n)"
if "%QUIT%"=="" exit
if /I "%QUIT%"=="y" exit
if /I "%QUIT%"=="n" goto decide

@echo on