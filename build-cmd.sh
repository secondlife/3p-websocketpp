#!/usr/bin/env bash

cd "$(dirname "$0")"

# turn on verbose debugging output for parabuild logs.
exec 4>&1; export BASH_XTRACEFD=4; set -x
# make errors fatal
set -e
# complain about unset env variables
set -u

WEBSOCKETPP_SOURCE_DIR="websocketpp"
# version number is conveniently found in a file with no other content
WEBSOCKETPP_VERSION=$(grep -m1 -E '^[0-9]+\.[0-9]+\.[0-9]+' "$WEBSOCKETPP_SOURCE_DIR/changelog.md" | awk '{print $1}')

if [ -z "$AUTOBUILD" ] ; then
   exit 1
fi

if [ "$OSTYPE" = "cygwin" ] ; then
   autobuild="$(cygpath -u $AUTOBUILD)"
else
   autobuild="$AUTOBUILD"
fi

stage="$(pwd)/stage"
mkdir -p "$stage"

# load autobuild provided shell functions and variables
source_environment_tempfile="$stage/source_environment.sh"
"$autobuild" source_environment > "$source_environment_tempfile"
. "$source_environment_tempfile"

build=${AUTOBUILD_BUILD_ID:=0}
echo "${WEBSOCKETPP_VERSION}.${build}" > "${stage}/VERSION.txt"

pushd "$WEBSOCKETPP_SOURCE_DIR"
    mkdir --parents "$stage/include/websocketpp"
    cp -r ../"${WEBSOCKETPP_SOURCE_DIR}"/websocketpp "$stage/include/"

    mkdir -p "$stage/LICENSES"
    cp COPYING "$stage/LICENSES/websocketpp.txt"
popd
