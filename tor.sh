#!/bin/bash

# Source environment
. ./source.sh

VERSION="0.2.7.6"
VERIFYGPG=true
TOR_DIST_URL="https://dist.torproject.org/"

set -e

# Download and verify tor source code
if [ ! -e "tor-${VERSION}.tar.gz" ]; then
	echo "Downloading tor-${VERSION}.tar.gz"
	#curl -O https://archive.torproject.org/tor-package-archive/tor-${VERSION}.tar.gz
	curl -O ${TOR_DIST_URL}tor-${VERSION}.tar.gz
fi
echo "Using tor-${VERSION}.tar.gz"

if $VERIFYGPG; then
	if [ ! -e "tor-${VERSION}.tar.gz.asc" ]; then
		curl -O ${TOR_DIST_URL}tor-${VERSION}.tar.gz.asc
	fi
	echo "Using tor-${VERSION}.tar.gz.asc"
	if out=$(gpg --status-fd 1 --verify "tor-${VERSION}.tar.gz.asc" "tor-${VERSION}.tar.gz" 2>/dev/null) &&	echo "$out" | grep -qs "^\[GNUPG:\] VALIDSIG"; then
		echo "$out" | egrep "GOODSIG|VALIDSIG"
		echo "Verified GPG signature for source..."
	else
		echo "$out" >&2
		echo "COULD NOT VERIFY PACKAGE SIGNATURE..."
		exit 1
	fi
fi

# Unpack sources
OUTPUT=`pwd`/output
tar zxf tor-${VERSION}.tar.gz
cd tor-${VERSION}

# Compile fixes for Android
sed -i.old '1s;^;#include <sys/limits.h>\n;' src/ext/trunnel/trunnel.c
sed -i 's/pthread_condattr_setclock(&condattr, CLOCK_MONOTONIC)/0/g' src/common/compat_pthreads.c

# Setup compile flags for makefile
export CFLAGS="$CFLAGS --sysroot=$SYSROOT -O2 -Isrc/common -I../output/openssl/include -I$OUTPUT/libevent/include/event2"
export CPPFLAGS="$CPPFLAGS --sysroot=$SYSROOT -Isrc/common -I../output/openssl/include -I$OUTPUT/libevent/include/event2"
export LDFLAGS="$LDFLAGS -lz -lcrypto -levent -lssl -L$OUTPUT/openssl/lib -L$OUTPUT/libevent"

# Configure build
./configure --with-openssl-dir="$OUTPUT/openssl/" \
--with-libevent-dir="$OUTPUT/libevent" \
--disable-asciidoc --disable-transparent \
--host=arm-linux-androideabi --target=arm-linux-androideabi

# Build tor
make -j4

# Distribute artifacts
mkdir -p ../../built
rm -fr ../../built/*
cp src/or/tor ../../built
cp ../output/openssl/lib/libssl.so.1.0.0 ../../built
cp ../output/openssl/lib/libcrypto.so.1.0.0 ../../built
cp $REPOROOT/torrc ../../built