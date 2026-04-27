#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <app_prefix>"
    exit 1
fi

echo "Reading Build ID from $1..."
BUILD_ID=$(readelf -n "$1" | grep "Build ID" | awk '{print $3}')
echo "Build ID: $BUILD_ID"

FIRST2=${BUILD_ID:0:2}
REST=${BUILD_ID:2}

echo "Creating debug directory /root/.debug/.build-id/$FIRST2..."
sudo mkdir -p /root/.debug/.build-id/$FIRST2
echo "Done."
