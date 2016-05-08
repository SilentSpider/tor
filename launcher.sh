#!/bin/bash

# Source environment
. ./source.sh
cd ../..
$CROSS_COMPILE$HOSTCC -o build/built/launcher launcher.c