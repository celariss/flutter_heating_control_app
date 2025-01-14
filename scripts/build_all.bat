pushd ..
call flutter build apk --split-per-abi 
call flutter build windows 
call flutter build web 
popd
