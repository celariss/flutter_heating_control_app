pushd ..
call flutter build windows
call flutter build apk --split-per-abi
popd