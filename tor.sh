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

# see https://www.torproject.org/docs/verifying-signatures.html.en
# and https://www.torproject.org/docs/signing-keys.html.en
# up to you to set up `gpg` and add keys to your keychain
if $VERIFYGPG; then
	if [ ! -e "tor-${VERSION}.tar.gz.asc" ]; then
		curl -O ${TOR_DIST_URL}tor-${VERSION}.tar.gz.asc
	fi
	echo "Using tor-${VERSION}.tar.gz.asc"
	if out=$(gpg --status-fd 1 --verify "tor-${VERSION}.tar.gz.asc" "tor-${VERSION}.tar.gz" 2>/dev/null) &&
	echo "$out" | grep -qs "^\[GNUPG:\] VALIDSIG"; then
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