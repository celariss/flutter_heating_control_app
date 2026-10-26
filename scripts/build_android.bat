pushd ..
call dart run flutter_launcher_icons
call flutter build apk --split-per-abi 
popd