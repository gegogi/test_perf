# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

This project tests Linux `perf` profiling with split debug symbols using the GNU debuglink approach. The goal is to profile a stripped binary while keeping debug info in a separate `.debug` file, resolving symbols via a build-ID-based debug cache (`~/.debug/.build-id/`).

## Workflow

### 1. Build

```bash
bash build.sh
```

Compiles `test.c` with debug info (`-g -O2 -fno-inline`), extracts debug symbols to `test.debug`, strips the binary to `test.stripped`, and embeds a GNU debuglink. Prints the build ID and creates the build-ID directory under `/root/.debug/.build-id/` — but does **not** copy `test.debug` into place (that is handled by `profile.sh`).

### 2. Setup (one-time, non-root perf)

```bash
bash setup.sh
```

Sets `kernel.perf_event_paranoid=1` persistently and grants `cap_perfmon` to the `perf` binary so profiling can be done without `sudo`.

### 3. Profile (attach + flamegraph)

```bash
# In one terminal — run the target:
./test.stripped

# In another terminal — attach, record, and generate flamegraph:
bash profile.sh
```

`profile.sh` does the following:
1. Finds the PID of `test.stripped` via `pgrep`
2. Copies `test.debug` into `~/.debug/.build-id/<first2>/<rest>.debug` (debug symbol cache)
3. Attaches `perf record --call-graph dwarf` for 5 seconds then stops
4. Runs `perf script` → `stackcollapse-perf.pl` → `flamegraph.pl` → `flamegraph.svg`

Requires FlameGraph scripts at `/home/gegogi/Projects/FlameGraph`.

## Architecture

| File | Description |
|------|-------------|
| `test.c` | Infinite loop: `main` → `fa()` → `fb()`, each with a busy computation loop and `printf` |
| `build.sh` | Build pipeline: compile → split debug → strip → embed debuglink → print build ID |
| `setup.sh` | One-time perf permission setup (paranoid level + cap_perfmon) |
| `profile.sh` | Attach perf to running process, update debug cache, generate flamegraph |
| `test` | Full binary (debug info, not stripped) |
| `test.debug` | Debug-only ELF (symbols + DWARF, no code) |
| `test.stripped` | Stripped binary with GNU debuglink pointing to `test.debug` |
| `perf.data` | Latest perf profile |
| `perf.data.old` | Previous perf profile |
| `perf.script` | Raw `perf script` output (input to flamegraph pipeline) |
| `flamegraph.svg` | Generated flamegraph (open in browser) |

## Notes

- Debug symbols are resolved from `~/.debug/.build-id/` (user home), not `/root/.debug/.build-id/`.
- `profile.sh` re-copies `test.debug` into the cache on every run, so rebuilding and re-profiling is safe.
- `perf record` uses `--call-graph dwarf` for accurate call graphs with inlined/optimized code.
