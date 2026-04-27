#!/bin/bash
set -e

FLAMEGRAPH_DIR=/home/gegogi/Projects/FlameGraph

PID=$(pgrep -x test.stripped)
echo "Attaching to PID $PID"

BUILD_ID=$(readelf -n test.stripped | grep "Build ID" | awk '{print $3}')
mkdir -p ~/.debug/.build-id/${BUILD_ID:0:2}
cp test.debug ~/.debug/.build-id/${BUILD_ID:0:2}/${BUILD_ID:2}.debug
echo "Build ID: $BUILD_ID (cache updated)"

timeout --signal=SIGINT 5 perf record --call-graph dwarf -p "$PID"; true

perf script > perf.script
$FLAMEGRAPH_DIR/stackcollapse-perf.pl perf.script | $FLAMEGRAPH_DIR/flamegraph.pl > flamegraph.svg

echo "Done: flamegraph.svg"

perf report --stdio > perf.report
echo "Done: perf.report"
