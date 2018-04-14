echo Getting latest build of GDCC...
echo

if [ -d tools ]; then
    rm -r tools/
fi

mkdir tools

if ! [ -d bin ]; then
    mkdir bin
fi

echo
echo Downloading GDCC...
echo

# download gdcc
curl -L "https://www.dropbox.com/sh/e4msp35vxp61ztg/AACoOWfWHArqaNP4huJ0UzUpa/gdcc/gdcc-0.13.3-1-win64.7z?dl=1" > bin/gdcc.7z

echo
echo Unpacking GDCC...
echo

# extract gdcc
7z x "bin/gdcc.7z" -otools/gdcc -aoa

echo

# run the build script
. ./build.sh
