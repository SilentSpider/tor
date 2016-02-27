#!/bin/bash

# Source environment
. ./source.sh

VERSION="1.0.2f"
VERIFYGPG=true

# Exit the script if an error happens
set -e

if [ ! -e "${SRCDIR}/openssl-${VERSION}.tar.gz" ]; then
	echo "Downloading openssl-${VERSION}.tar.gz"
	curl -O http://www.openssl.org/source/openssl-${VERSION}.tar.gz
fi
echo "Using openssl-${VERSION}.tar.gz"

if $VERIFYGPG; then
	if [ ! -e "${SRCDIR}/openssl-${VERSION}.tar.gz.asc" ]; then
		curl -O http://www.openssl.org/source/openssl-${VERSION}.tar.gz.asc
	fi
	echo "Using openssl-${VERSION}.tar.gz.asc"
	gpg --recv-keys D9C4D26D0E604491
	if out=$(gpg --status-fd 1 --verify "openssl-${VERSION}.tar.gz.asc" "openssl-${VERSION}.tar.gz" 2>/dev/null) &&
	echo "$out" | grep -qs "^\[GNUPG:\] VALIDSIG"; then
		echo "$out" | egrep "GOODSIG|VALIDSIG"
		echo "Verified GPG signature for source..."
	else
		echo "$out" >&2
		echo "COULD NOT VERIFY PACKAGE SIGNATURE..."
		exit 1
	fi
fi

tar zxf openssl-${VERSION}.tar.gz -C $SRCDIR
cd "${SRCDIR}/openssl-${VERSION}"

./config shared no-ssl2 no-ssl3 no-comp no-hw --openssldir=`pwd`/../output/openssl
make depend
make all
make install
