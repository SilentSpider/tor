#!/bin/bash

# Source environment
. ./source.sh

VERSION="0.2.7.6"
VERIFYGPG=true
TOR_DIST_URL="https://dist.torproject.org/"

set -e

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

OUTPUT=`pwd`/output
tar zxf tor-${VERSION}.tar.gz

export CFLAGS="$CFLAGS --sysroot=$SYSROOT -O2 -Isrc/common -I../output/openssl/include -I$OUTPUT/libevent/include/event2" \
export CPPFLAGS="$CPPFLAGS --sysroot=$SYSROOT -Isrc/common -I../output/openssl/include -I$OUTPUT/libevent/include/event2"

# sed -ie "s/tor_cv_can_use_curve25519_donna_c64=cross/tor_cv_can_use_curve25519_donna_c64=no/g" configure
# sed -ie "s/tor_cv_can_use_curve25519_donna_c64=yes/tor_cv_can_use_curve25519_donna_c64=no/g" configure

export PATH=/Applications/android-ndk-r10e/toolchains/arm-linux-androideabi-4.8/prebuilt/darwin-x86_64/bin:$PATH

./configure  --disable-threads --with-openssl-dir="$OUTPUT/openssl/" \
--with-libevent-dir="$OUTPUT/libevent" \
--disable-asciidoc --disable-transparent \
--host=arm-linux-androideabi --target=arm-linux-androideabi

export LDFLAGS="$LDFLAGS -arch armv7 -lz -lcrypto -levent -lssl -L$OUTPUT/openssl/lib -L$OUTPUT/libevent"

make -j4