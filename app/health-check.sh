#!/usr/bin/env bash
set -u

echo "Running container health check..."
/app/diagnostic.sh system >/dev/null 2>&1 && /app/diagnostic.sh disk >/dev/null 2>&1
