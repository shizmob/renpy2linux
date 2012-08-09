#!/bin/bash

# Read Ren'Py version.
if [[ $# -ge 1 ]]; then
    RENPY_VERSION=$1
else
    echo "Determining Ren'Py version..."
    if [ ! -f renpy/__init__.py ]; then
        echo "Could not read renpy/__init__.rpy -- is this a Ren'Py game?"
        exit 1
    fi

    RENPY_VERSION=$(python2 -c 'from renpy import version_tuple; print ".".join(str(i) for i in version_tuple[0:3])')
fi
echo "Ren'Py version: ${RENPY_VERSION}"

# Extract game title.
EXE=$(echo *.py)
GAME=${EXE%.py}
echo "Game title: ${GAME}"

# Flush temporary directory.
rm -rf __tmp
mkdir __tmp
cd __tmp

echo "Downloading Ren'Py SDK..."
# Get the appropriate Ren'Py version SDK to supplement missing files.
FILE="renpy-$RENPY_VERSION-sdk.tar.bz2"
DIR="renpy-$RENPY_VERSION-sdk"
URL="http://renpy.org/dl/$RENPY_VERSION/$FILE"
if ! wget -nv "$URL"; then
    cd ..
    rm -rf __tmp
    echo "Download failed -- aborting."
    exit 3
fi

echo "Extracting Ren'Py SDK..."
if ! tar -xf "$FILE"; then
    rm "$FILE"
    cd ..
    rm -rf __tmp
    echo "Extraction failed -- aborting."
    exit 4
fi
rm "$FILE"

echo "Copying files..."
# Copy the required Linux files over.
if [ -d "$DIR/lib/python"* ]; then
    cp -R "$DIR/lib/python"* ../lib
fi
if [ -d "$DIR/lib/linux-x86" ]; then
    cp -R "$DIR/lib/linux-x86" ../lib
fi
if [ -d "$DIR/lib/linux-i686" ]; then
    cp -R "$DIR/lib/linux-i686" ../lib
fi
if [ -d "$DIR/lib/linux-x86_64" ]; then
    cp -R "$DIR/lib/linux-x86_64" ../lib
fi

# Copy over the launch script file.
cp "$DIR/renpy.sh" ../"$GAME".sh

echo "Done!"
# Remove the temporary directory.
cd ..
rm -rf __tmp
