#!/usr/bin/env bash
set -u

IMAGE_NAME="diagnostic-tool-test"
FAIL=0

echo "Building Docker image for testing..."
docker build -t "$IMAGE_NAME" . >/dev/null 2>&1 || { echo "Docker build failed"; exit 1; }

run_test() {
  local description="$1"
  local expected_exit="$2"
  shift 2

  echo -n "Test: $description ... "
  docker run --rm "$IMAGE_NAME" "$@" >/dev/null 2>&1
  local actual_exit=$?

  if [[ $actual_exit -eq $expected_exit ]]; then
    echo "PASS"
  else
    echo "FAIL (Expected exit $expected_exit, got $actual_exit)"
    FAIL=$((FAIL+1))
  fi
}

echo "=== Running Diagnostic CLI Test Suite ==="
run_test "Help command" 0 help
run_test "System command" 0 system
run_test "Disk command" 0 disk
run_test "Network valid host (localhost)" 0 network 127.0.0.1
run_test "Invalid command" 2 invalid-command
run_test "Network missing host argument" 2 network

docker image rm "$IMAGE_NAME" >/dev/null 2>&1 || true

if [[ $FAIL -eq 0 ]]; then
  echo "All tests passed successfully!"
  exit 0
else
  echo "$FAIL test(s) failed."
  exit 1
fi
