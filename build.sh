#!/bin/bash -xv

gcc -g -O2 -fno-inline test.c -o test

strip --only-keep-debug test -o test.debug

strip test -o test.stripped

objcopy --add-gnu-debuglink=test.debug test.stripped

BUILD_ID=$(readelf -n test.stripped | grep "Build ID" | awk '{print $3}')
echo $BUILD_ID

FIRST2=${BUILD_ID:0:2}
REST=${BUILD_ID:2}

sudo mkdir -p /root/.debug/.build-id/$FIRST2


