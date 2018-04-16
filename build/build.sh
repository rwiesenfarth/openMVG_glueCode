#!/bin/bash

usage () {
  cat <<EOF

Usage: build Configuration [Scope]

Configuration can be one of
  All (corresponds to both Debug and RelWithDebInfo)
- Debug
- Release
- RelWithDebInfo
- MinSizeRel
NOTE: If Configuration changes, the files generated in the deploy subdirectory should be removed.

Scope is optional (default is 'full') and can be
- nowide    : configure and build only the nowide third party package
- eigen     : configure and build only the Eigen third party package
- cereal    : configure and build only the cereal third party package
- openmvg   : configure and build only the OpenMVG third party package
- full      : configure and build all packages
EOF
  exit 1
}

fail () {
  echo "Build failed: $1"
  exit 1
}


_TMP_CONFIG=`echo "$1" | tr [A-Z] [a-z]`
_TMP_SCOPE=`echo "$2" | tr [A-Z] [a-z]`

case "$_TMP_CONFIG" in
all)
  $0 Debug $2 && $0 RelWithDebInfo $2 && exit 0
  exit 1
  ;;
debug)
  CONFIGURATION=Debug
  ;;
release)
  CONFIGURATION=Release
  ;;
relwithdebinfo)
  CONFIGURATION=RelWithDebInfo
  ;;
minsizerel)
  CONFIGURATION=MinSizeRel
  ;;
*)
  usage
  ;;
esac

echo "Configuration is $CONFIGURATION"

BUILD_NOWIDE="false"
BUILD_EIGEN="false"
BUILD_CEREAL="false"
BUILD_OPENMVG="false"

case "x$2" in
x|xfull)
  BUILD_NOWIDE="true"
  BUILD_EIGEN="true"
  BUILD_CEREAL="true"
  BUILD_OPENMVG="true"
  ;;
xnowide)
  BUILD_NOWIDE="true"
  ;;
xeigen)
  BUILD_EIGEN="true"
  ;;
xcereal)
  BUILD_CEREAL="true"
  ;;
xopenmvg)
  BUILD_OPENMVG="true"
  ;;
*)
  usage
  ;;
esac


if $BUILD_NOWIDE = "true"
then
  mkdir nowide_$CONFIGURATION 2>/dev/null
  cd nowide_$CONFIGURATION
  cmake -G "Unix Makefiles" -DGLUE_DEPLOY_DIR=deploy_$CONFIGURATION -DCMAKE_BUILD_TYPE=$CONFIGURATION -C ../../src/thirdparty/nowide_CMakeDefines.txt ../../src/thirdparty/nowide || fail "Nowide configuration"
  cmake --build . --target install --config $CONFIGURATION || fail "Nowide build"
  cd ..
fi

if $BUILD_EIGEN = "true"
then
  mkdir eigen_$CONFIGURATION 2>/dev/null
  cd eigen_$CONFIGURATION
  cmake -G "Unix Makefiles" -DGLUE_DEPLOY_DIR=deploy_$CONFIGURATION -DCMAKE_BUILD_TYPE=$CONFIGURATION -C ../../src/thirdparty/eigen_CMakeDefines.txt ../../src/thirdparty/eigen || fail "Eigen configuration"
  cmake --build . --target install --config $CONFIGURATION || fail "Eigen build"
  cd ..
fi

if $BUILD_CEREAL = "true"
then
  mkdir cereal_$CONFIGURATION 2>/dev/null
  cd cereal_$CONFIGURATION
  cmake -G "Unix Makefiles" -DGLUE_DEPLOY_DIR=deploy_$CONFIGURATION -DCMAKE_BUILD_TYPE=$CONFIGURATION ../../src/thirdparty/cereal || fail "cereal configuration"
  cmake --build . --target install --config $CONFIGURATION || fail "cereal build"
  cd ..
fi

if $BUILD_OPENMVG = "true"
then
  mkdir openmvg_$CONFIGURATION 2>/dev/null
  cd openmvg_$CONFIGURATION
  cmake -G "Unix Makefiles" -DGLUE_DEPLOY_DIR=deploy_$CONFIGURATION -DCMAKE_BUILD_TYPE=$CONFIGURATION -C ../../src/thirdparty/openmvg_CMakeDefines.txt ../../src/thirdparty/openmvg/src || fail "OpenMVG configuration"
  cmake --build . --target install --config $CONFIGURATION || fail "OpenMVG build"
  cd ..
fi

exit 0
