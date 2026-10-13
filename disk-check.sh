#!/bin/bash

THRESHOLD="$1"
MOUNT_POINT="${2:-/}"

# 1. Validate that threshold is provided, is an integer, and falls between 1 and 100
if [[ -z "$THRESHOLD" ]] || ! [[ "$THRESHOLD" =~ ^[0-9]+$ ]] || [ "$THRESHOLD" -lt 1 ] || [ "$THRESHOLD" -gt 100 ]; then
    echo "Error: threshold must be an integer from 1 to 100."
    exit 2
fi

# 2. Get current disk usage percentage for the specified mount point
DISK_USAGE=$(df -h "$MOUNT_POINT" 2>/dev/null | awk 'NR==2 {print $5}' | tr -d '%')

# Verify mount point validity
if [[ -z "$DISK_USAGE" ]]; then
    echo "Error: invalid mount point '$MOUNT_POINT'."
    exit 2
fi

# 3. Print execution output
echo "Path: $MOUNT_POINT"
echo "Disk usage: ${DISK_USAGE}%"
echo "Threshold: ${THRESHOLD}%"

# 4. Create log directory if it does not exist
mkdir -p logs

# 5. Check threshold status and log output
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

if [ "$DISK_USAGE" -gt "$THRESHOLD" ]; then
    echo "CRITICAL: disk usage is above the threshold."
    echo "[$TIMESTAMP] Path: $MOUNT_POINT | Usage: ${DISK_USAGE}% | Threshold: ${THRESHOLD}% | Status: CRITICAL" >> logs/disk-check.log
    exit 1
else
    echo "OK: disk usage is below the threshold."
    echo "[$TIMESTAMP] Path: $MOUNT_POINT | Usage: ${DISK_USAGE}% | Threshold: ${THRESHOLD}% | Status: OK" >> logs/disk-check.log
    exit 0
fi
