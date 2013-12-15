#!/usr/bin/env bash

set -e

# build app
xcodebuild clean build
VERSION=$(defaults read $(pwd)/Leviathan/Leviathan-Info CFBundleShortVersionString)
VERSION_ROBOT=$(defaults read $(pwd)/Leviathan/Leviathan-Info CFBundleVersion)
FILENAME="Builds/Leviathan-$VERSION.app.tar.gz"
LATEST="Builds/Leviathan-LATEST.app.tar.gz"

# build .zip
rm -rf $FILENAME
tar -zcf $FILENAME -C build/Release Leviathan.app
echo "Created $FILENAME"

# make "latest" version for the link in the readme
rm -f $LATEST
cp $FILENAME $LATEST
echo "Created $LATEST"

# update latest-version file
echo $VERSION > Updates/latest-version.txt
echo $VERSION_ROBOT >> Updates/latest-version.txt
