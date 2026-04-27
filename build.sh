#!/bin/bash -xv

gcc -g -O2 -fno-inline test.c -o test.with_g

strip --only-keep-debug test.with_g -o test.debug

strip test.with_g -o test

objcopy --add-gnu-debuglink=test.debug test

BUILD_ID=$(readelf -n test | grep "Build ID" | awk '{print $3}')
echo $BUILD_ID

FIRST2=${BUILD_ID:0:2}
REST=${BUILD_ID:2}

sudo mkdir -p /root/.debug/.build-id/$FIRST2


