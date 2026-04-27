#!/bin/bash
set -e

CPU_CLOCK=""
for arg in "$@"; do
    if [ "$arg" = "--cpu-clock" ]; then
        CPU_CLOCK="-e cpu-clock"
    fi
done

if [ -z "$1" ] || [ "$1" = "--cpu-clock" ]; then
    echo "Usage: $0 [--cpu-clock] <proc_name> <duration>"
    exit 1
fi

if [ -z "$2" ] || [ "$2" = "--cpu-clock" ]; then
    echo "Usage: $0 [--cpu-clock] <proc_name> <duration>"
    exit 1
fi

DURATION=$2

FLAMEGRAPH_DIR=$(dirname "$0")/FlameGraph

PID=$(pgrep -x $1)
echo "Attaching to PID $PID"

BUILD_ID=$(readelf -n $1 | grep "Build ID" | awk '{print $3}')
mkdir -p ~/.debug/.build-id/${BUILD_ID:0:2}
cp $1.debug ~/.debug/.build-id/${BUILD_ID:0:2}/${BUILD_ID:2}.debug
echo "Build ID: $BUILD_ID (cache updated)"

echo "Recording for $DURATION seconds..."
timeout --signal=SIGINT $DURATION perf record -F 99 --call-graph dwarf,65528 --mmap-pages=512 $CPU_CLOCK -p "$PID" || true

echo "Extracting script..."
perf script > perf.script

echo "Generating flamegraph..."
$FLAMEGRAPH_DIR/stackcollapse-perf.pl perf.script | $FLAMEGRAPH_DIR/flamegraph.pl > flamegraph.svg
echo "Done: flamegraph.svg"

echo "Generating report..."
perf report --stdio > perf.report
echo "Done: perf.report"
