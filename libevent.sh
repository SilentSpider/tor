#!/bin/bash

# Source environment
. ./source.sh

VERSION="2.0.22-stable"
VERIFYGPG=true

# Exit the script if an error happens
set -e

# Download and verify signatures to make sure we have the right source
if [ ! -e "libevent-${VERSION}.tar.gz" ]; then
	echo "Downloading libevent-${VERSION}.tar.gz"
	#curl -LO https://github.com/downloads/libevent/libevent/libevent-${VERSION}.tar.gz
    curl -LO http://netix.dl.sourceforge.net/project/levent/release-${VERSION}/libevent-${VERSION}.tar.gz
fi
echo "Using libevent-${VERSION}.tar.gz"

if $VERIFYGPG; then
	if [ ! -e "${SRCDIR}/libevent-${VERSION}.tar.gz.asc" ]; then
		#curl -LO https://github.com/downloads/libevent/libevent/libevent-${VERSION}.tar.gz.asc
        gpg --recv-keys 910397D88D29319A
        curl -LO http://netix.dl.sourceforge.net/project/levent/release-${VERSION}/libevent-${VERSION}.tar.gz.asc
	fi
	echo "Using libevent-${VERSION}.tar.gz.asc"
	if out=$(gpg --status-fd 1 --verify "libevent-${VERSION}.tar.gz.asc" "libevent-${VERSION}.tar.gz" 2>/dev/null) &&
	echo "$out" | grep -qs "^\[GNUPG:\] VALIDSIG"; then
		echo "$out" | egrep "GOODSIG|VALIDSIG"
		echo "Verified GPG signature for source..."
	else
		echo "$out" >&2
		echo "COULD NOT VERIFY PACKAGE SIGNATURE..."
		exit 1
	fi
fi

tar zxf libevent-${VERSION}.tar.gz
cd "libevent-${VERSION}"

OUTPUT=`pwd`/../output

# Add include files for libevent makefile
export CFLAGS="$CFLAGS -I$OUTPUT/openssl/include -L$OUTPUT/openssl/lib -lssl -lcrypto"
export CC=arm-linux-androideabi-gcc
export CFLAGS="$CFLAGS --sysroot=$SYSROOT"
export CPPFLAGS="$CPPFLAGS --sysroot=$SYSROOT"

# Configure build
./configure --disable-shared --enable-static --disable-debug-mode \
LDFLAGS="$LDFLAGS" \
--host=arm-linux-androideabi --target=arm-linux-androideabi

# Build
make -j4

# Distribute artefacts
mkdir -p ../output/libevent
mkdir -p ../output/libevent/include
cp ./.libs/*  ../output/libevent
cp -r include/event2 ../output/libevent/include