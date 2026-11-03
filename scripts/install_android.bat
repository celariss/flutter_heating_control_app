rem call flutter install --use-application-binary=build\app\outputs\flutter-apk\app-arm64-v8a-release.apk 

rem using adb with -r option allows updating without uninstall => not loosing app parameters
call adb.exe install -r ..\build\app\outputs\flutter-apk\app-arm64-v8a-release.apk 

