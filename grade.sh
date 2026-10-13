#!/usr/bin/env bash

set -u

PASS=0
FAIL=0
WARN=0

pass() {
    echo "[PASS] $1"
    ((PASS += 1))
}

fail() {
    echo "[FAIL] $1"
    ((FAIL += 1))
}

warn() {
    echo "[WARN] $1"
    ((WARN += 1))
}

echo "======================================"
echo "      ASSIGNMENT 1 SELF-GRADER"
echo "======================================"
echo

# Check required files.
for file in README.md system-info.sh disk-check.sh network-check.sh grade.sh logs/.gitkeep; do
    if [[ -f "$file" ]]; then
        pass "Required file exists: $file"
    else
        fail "Missing required file: $file"
    fi
done

echo
echo "--- Bash syntax ---"

for file in system-info.sh disk-check.sh network-check.sh grade.sh; do
    if [[ -f "$file" ]] && bash -n "$file" 2>/dev/null; then
        pass "Valid Bash syntax: $file"
    else
        fail "Bash syntax error or missing script: $file"
    fi
done

echo
echo "--- Executable permissions ---"

for file in system-info.sh disk-check.sh network-check.sh grade.sh; do
    if [[ -x "$file" ]]; then
        pass "Executable: $file"
    else
        fail "Not executable: $file"
    fi
done

echo
echo "--- System information ---"

if [[ -x system-info.sh ]]; then
    system_output="$(./system-info.sh 2>&1)"
    if [[ "$system_output" == *"Hostname:"* &&
          "$system_output" == *"Current User:"* &&
          "$system_output" == *"Kernel Version:"* &&
          "$system_output" == *"Current Working Directory:"* ]]; then
        pass "System report contains expected information"
    else
        fail "System report is missing expected information"
    fi
else
    fail "Cannot test system report because system-info.sh is not executable"
fi

echo
echo "--- Disk-check validation ---"

if [[ -x disk-check.sh ]]; then
    if ./disk-check.sh abc / >/dev/null 2>&1; then
        fail "Invalid disk threshold was incorrectly accepted"
    else
        rc=$?
        if (( rc == 2 )); then
            pass "Invalid disk threshold returns exit code 2"
        else
            fail "Invalid disk threshold returned exit code $rc instead of 2"
        fi
    fi

    if ./disk-check.sh 100 / >/dev/null 2>&1; then
        pass "Valid disk check runs successfully"
    else
        fail "Valid disk check failed"
    fi
else
    fail "Cannot test disk-check.sh because it is not executable"
fi

echo
echo "--- Network-check validation ---"

if [[ -x network-check.sh ]]; then
    if ./network-check.sh example.com 70000 >/dev/null 2>&1; then
        fail "Invalid network port was incorrectly accepted"
    else
        rc=$?
        if (( rc == 2 )); then
            pass "Invalid network port returns exit code 2"
        else
            fail "Invalid network port returned exit code $rc instead of 2"
        fi
    fi

    if ./network-check.sh >/dev/null 2>&1; then
        fail "Missing network target was incorrectly accepted"
    else
        rc=$?
        if (( rc == 2 )); then
            pass "Missing network target returns exit code 2"
        else
            fail "Missing network target returned exit code $rc instead of 2"
        fi
    fi

    if ./network-check.sh localhost >/dev/null 2>&1; then
        pass "Network check runs against localhost"
    else
        fail "Network check against localhost failed"
    fi
else
    fail "Cannot test network-check.sh because it is not executable"
fi

echo
echo "--- Logging ---"

if [[ -s logs/disk-check.log ]]; then
    pass "Disk-check log exists and is not empty"
else
    fail "Disk-check log is missing or empty"
fi

if [[ -s logs/network-check.log ]]; then
    pass "Network-check log exists and is not empty"
else
    fail "Network-check log is missing or empty"
fi

echo
echo "--- Git history ---"

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    commits="$(git rev-list --count HEAD 2>/dev/null || echo 0)"
    if (( commits >= 5 )); then
        pass "Git history contains at least five commits ($commits)"
    else
        warn "Git history currently has $commits commit(s); aim for at least five meaningful commits"
    fi

    branch="$(git branch --show-current)"
    echo "Current branch: $branch"

    if git branch --list main | grep -q main; then
        pass "Main branch exists"
    else
        warn "No local main branch found"
    fi
else
    fail "This directory is not a Git repository"
fi

echo
echo "======================================"
echo "              SUMMARY"
echo "======================================"
echo "Passed:   $PASS"
echo "Failed:   $FAIL"
echo "Warnings: $WARN"
echo

if (( FAIL > 0 )); then
    echo "RESULT: NOT YET READY - fix the failed checks."
    exit 1
else
    echo "RESULT: CORE CHECKS PASSED"
    if (( WARN > 0 )); then
        echo "Review the warnings before submission."
    fi
    exit 0
fi
