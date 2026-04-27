#!/bin/bash
set -e

CPU_CLOCK=""
for arg in "$@"; do
    if [ "$arg" = "--cpu-clock" ]; then
        CPU_CLOCK="-e cpu-clock"
    fi
done

if [ -z "$1" ] || [ "$1" = "--cpu-clock" ]; then
    echo "Usage: $0 [--cpu-clock] <pid> <duration>"
    exit 1
fi

if [ -z "$2" ] || [ "$2" = "--cpu-clock" ]; then
    echo "Usage: $0 [--cpu-clock] <pid> <duration>"
    exit 1
fi

PID=$1
DURATION=$2

FLAMEGRAPH_DIR=$(dirname "$0")/FlameGraph

if ! kill -0 "$PID" 2>/dev/null; then
    echo "Error: process '$PID' not found"
    exit 1
fi
echo "Attaching to PID $PID"

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
