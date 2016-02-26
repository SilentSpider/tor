#!/bin/bash


VERSION="1.0.2f"
VERIFYGPG=true

# Setup some initial working dirs

REPOROOT=$(pwd)
# Where we'll end up storing things in the end
OUTPUTDIR="${REPOROOT}/dependencies"
mkdir -p ${OUTPUTDIR}/include
mkdir -p ${OUTPUTDIR}/lib
BUILDDIR="${REPOROOT}/build"

# where we will keep our sources and build from.

SRCDIR="${BUILDDIR}/src"
mkdir -p $SRCDIR
# where we will store intermediary builds
INTERDIR="${BUILDDIR}/built"
mkdir -p $INTERDIR

cd $SRCDIR

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