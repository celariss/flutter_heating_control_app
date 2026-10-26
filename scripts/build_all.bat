pushd ..
call flutter pub get
call dart run flutter_launcher_icons
call flutter build apk --split-per-abi 
call flutter build windows 
call flutter build web 
popd
