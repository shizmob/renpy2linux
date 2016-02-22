#!/bin/sh
set -e

if test $# -eq 0 ; then
  echo "usage: $0 <game> [renpy_version]"
  exit 1
fi
BASEDIR="$1"
cd "$BASEDIR"
BASEDIR=$(pwd)

trap 'cd "$BASEDIR" && rm -rf __tmp' EXIT


echo "==> Determining game information..."
# Read Ren'Py version.
if test $# -gt 1 ; then
    RENPYVER=$2
else
    echo "=> Determining Ren'Py version..."
    if [ ! -f renpy/__init__.py ]; then
        echo "!! Could not read renpy/__init__.py -- is this a Ren'Py game?"
        exit 1
    fi

    RENPYVER=$(python -c 'from renpy import version_tuple; print ".".join(str(i) for i in version_tuple[:3])')
fi
echo "=> Ren'Py version: ${RENPYVER}"

# Extract game title.
PYEXE=$(echo *.py)
TITLE=${PYEXE%.py}
echo "=> Game title: ${TITLE}"

# Flush temporary directory.
rm -rf __tmp
mkdir __tmp
cd __tmp

echo "==> Downloading Ren'Py SDK..."
# Get the appropriate Ren'Py version SDK to supplement missing files.
SDKFILE="renpy-${RENPYVER}-sdk.tar.bz2"
SDKURL="http://renpy.org/dl/${RENPYVER}/${SDKFILE}"
if ! wget -nv "${SDKURL}"; then
    echo "!! Download failed -- aborting."
    exit 3
fi

echo "==> Extracting Ren'Py SDK..."
if ! tar -xf "${SDKFILE}"; then
    echo "!! Extraction failed -- aborting."
    exit 4
fi
rm "${SDKFILE}"

echo "==> Finding SDK directory..."
for x in "renpy-${RENPYVER}-sdk" "renpy-${RENPYVER}" ; do
  if test -d "$x" ; then
    SDKDIR=$x
    break
  fi
done
if test -z "${SDKDIR}" ; then
  echo "!! Couldn't find Ren'Py SDK directory -- aborting."
  exit 5
fi

echo "==> Copying files..."
# Copy the required platform files.
cd "${SDKDIR}"
for x in $(echo lib/*) ; do
  if ! test -e "../../lib/$x" ; then
    echo "=> $x"
    cp -R "$x" ../../lib
  fi
done

# Copy over the launch scripts.
for x in exe sh app ; do
  if ! test -e "../../${TITLE}.$x" ; then
    echo "=> ${TITLE}.$x"
    cp -R renpy.$x ../../"${TITLE}".$x
  fi
done
cd ..

echo "\o/ Done!"
