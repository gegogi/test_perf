#!/bin/bash
set -e

echo "=== perf non-root setup ==="

# perf_event_paranoid을 1로 낮춤 (user-space + 커널 통계 허용)
echo "Setting kernel.perf_event_paranoid=1 ..."
sudo sysctl kernel.perf_event_paranoid=1

echo "Making it persistent ..."
echo 'kernel.perf_event_paranoid=1' | sudo tee /etc/sysctl.d/99-perf.conf

# perf 바이너리에 CAP_PERFMON 권한 부여 (커널 5.8+)
echo "Granting cap_perfmon to perf binary ..."
sudo setcap cap_perfmon+ep $(which perf)

echo ""
echo "Done. perf can now be run without sudo."
