#!/bin/bash

echo "Compiling test.c..."
gcc -g -O2 -fno-inline test.c -o test.with_g

echo "Extracting debug symbols..."
strip --only-keep-debug test.with_g -o test.debug

echo "Stripping binary..."
strip test.with_g -o test

echo "Adding debug link..."
objcopy --add-gnu-debuglink=test.debug test

echo "Done: test, test.debug"
