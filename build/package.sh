#!/bin/bash

pushd `dirname $0` >/dev/null

SRC_D=../deploy_Debug
SRC_R=../deploy_RelWithDebInfo

PACKAGE_NAME="GLUE-Customized"

DEST=../$PACKAGE_NAME

echo "Cleaning destination directory ($DEST)..."
rm -fr $DEST
mkdir $DEST

echo "Copy documentation..."
mkdir $DEST/doc
cp -R $SRC_R/doc/html $DEST/doc

echo "Copy includes..."
cp -R $SRC_R/include $DEST

echo "Copy binaries..."
mkdir $DEST/bin
mkdir $DEST/bin/Debug
cp $SRC_D/bin/* $DEST/bin/Debug
cp $SRC_D/x64/gcc/bin/* $DEST/bin/Debug
mkdir $DEST/bin/Release
cp $SRC_R/bin/* $DEST/bin/Release
cp $SRC_R/x64/gcc/bin/* $DEST/bin/Release

echo "Copy libraries..."
mkdir $DEST/lib
mkdir $DEST/lib/Debug
cp --preserve=all -r $SRC_D/lib/* $DEST/lib/Debug
cp $SRC_D/x64/gcc/staticlib/* $DEST/lib/Debug
mkdir $DEST/lib/Release
cp --preserve=all -r $SRC_R/lib/* $DEST/lib/Release
cp $SRC_R/x64/gcc/staticlib/* $DEST/lib/Release

echo "Packaging..."
cd ..
tar cfj $PACKAGE_NAME.tar.bz2 $PACKAGE_NAME

echo "Package created in directory $PACKAGE_NAME and in $PACKAGE_NAME.tar.bz2"

popd >/dev/null

exit 0
