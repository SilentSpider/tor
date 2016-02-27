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

