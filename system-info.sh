#!/usr/bin/env bash

set -u

echo "======================================"
echo "       LINUX SYSTEM INFORMATION"
echo "======================================"

echo
echo "Hostname: $(hostname)"
echo "Current User: $(whoami)"
echo "Date and Time: $(date)"
echo "Operating System:"

if [[ -r /etc/os-release ]]; then
    . /etc/os-release
    echo "${PRETTY_NAME:-Unknown Linux distribution}"
else
    echo "Unknown"
fi

echo "Kernel Version: $(uname -r)"
echo "Uptime: $(uptime -p 2>/dev/null || uptime)"

echo
echo "CPU INFORMATION"
if command -v lscpu >/dev/null 2>&1; then
    lscpu | grep -E '^(Architecture|CPU\(s\)|Model name):'
else
    grep -m 1 'model name' /proc/cpuinfo || echo "CPU information unavailable"
fi

echo
echo "MEMORY INFORMATION"
free -h

echo
echo "Current Working Directory: $(pwd)"

echo
echo "======================================"
echo "       END OF SYSTEM REPORT"
echo "======================================"
