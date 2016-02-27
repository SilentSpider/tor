#!/bin/bash

# Source environment
. ./source.sh

VERSION="2.0.22-stable"
VERIFYGPG=true

# Exit the script if an error happens
set -e

if [ ! -e "libevent-${VERSION}.tar.gz" ]; then
	echo "Downloading libevent-${VERSION}.tar.gz"
	#curl -LO https://github.com/downloads/libevent/libevent/libevent-${VERSION}.tar.gz
	curl -LO https://sourceforge.net/projects/levent/files/libevent/libevent-2.0/libevent-${VERSION}.tar.gz
fi
echo "Using libevent-${VERSION}.tar.gz"

# up to you to set up `gpg` and add keys to your keychain
# may have to import from link on http://www.wangafu.net/~nickm/ or http://www.citi.umich.edu/u/provos/
if $VERIFYGPG; then
	if [ ! -e "${SRCDIR}/libevent-${VERSION}.tar.gz.asc" ]; then
		#curl -LO https://github.com/downloads/libevent/libevent/libevent-${VERSION}.tar.gz.asc
		curl -LO https://sourceforge.net/projects/levent/files/libevent/libevent-2.0/libevent-${VERSION}.tar.gz.asc
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

