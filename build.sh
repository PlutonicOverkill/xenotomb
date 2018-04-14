#!/bin/bash

echo ======== Xenotomb ========
echo
echo Build started...
echo

# get filename for built .pk3
git_version=$(git describe --long --tags --dirty --always)
build_name='xenotomb-'$git_version'.pk3'

# force recompilation of libc
# this is because the new version
# of gdcc might be different
libc=bin/build/acs/libc.lib
if [ -f $libc ]; then
    rm $libc
fi

echo
echo Compiling...
echo

# run the compile script
. ./compile.sh

echo
echo Building .pk3 file...
echo

# make the .pk3 file
7z a -r -tzip bin/$build_name ./bin/build/*

# which should be piped through dev/null, but my
# version of bash doesn't support it for some reason
path_to_executable=$(which appveyor)
if [ -x "$path_to_executable" ] ; then
    mkdir bin/appveyor
    cp bin/$build_name bin/appveyor/xenotomb.pk3
    "${path_to_executable}" PushArtifact bin/appveyor/xenotomb.pk3
fi

echo
echo Build completed.
