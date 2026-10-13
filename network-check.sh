#!/usr/bin/env bash

set -u

usage() {
    echo "Usage: $0 <hostname-or-IP> [port]"
}

# Validate the number of arguments.
if (( $# < 1 || $# > 2 )); then
    usage
    exit 2
fi

host="$1"
port="${2:-}"

# Reject empty values, options, whitespace and unsafe host characters.
if [[ -z "$host" || "$host" == -* ]] ||
   [[ ! "$host" =~ ^[A-Za-z0-9][A-Za-z0-9.-]*$ &&
      ! "$host" =~ ^[0-9A-Fa-f:]+$ ]]; then
    echo "Error: invalid hostname or IP address."
    exit 2
fi

# Validate an optional TCP port.
if [[ -n "$port" ]]; then
    if [[ ! "$port" =~ ^[0-9]+$ ]] ||
       (( ${#port} > 5 )) ||
       (( 10#$port < 1 || 10#$port > 65535 )); then
        echo "Error: port must be an integer from 1 to 65535."
        exit 2
    fi
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
log_dir="$script_dir/logs"
mkdir -p "$log_dir"
log_file="$log_dir/network-check.log"

log() {
    printf '%s - %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" \
        >> "$log_file"
}

echo "======================================"
echo "         NETWORK CHECK"
echo "======================================"
echo "Target: $host"
log "Started network check for host=$host port=${port:-not-specified}"

# Resolve the hostname or IP.
resolved="$(getent ahosts "$host" 2>/dev/null | awk '!seen[$1]++ {print $1}' || true)"

if [[ -z "$resolved" ]]; then
    echo "DNS/address lookup: FAILED"
    echo "Error: could not resolve the target."
    log "Address lookup failed for host=$host"
    exit 1
fi

echo
echo "Resolved address(es):"
printf '%s\n' "$resolved"
log "Address lookup succeeded for host=$host addresses=$(printf '%s' "$resolved" | tr '\n' ' ')"

# Basic ICMP connectivity test. Some networks block ping.
echo
if ping -c 1 -W 2 "$host" >/dev/null 2>&1; then
    echo "Ping connectivity: SUCCESS"
    log "Ping succeeded for host=$host"
else
    echo "Ping connectivity: FAILED or blocked"
    log "Ping failed or was blocked for host=$host"
fi

# Show available network interfaces and addresses.
echo
echo "Network interfaces:"
if command -v ip >/dev/null 2>&1; then
    ip -brief address show 2>/dev/null || ip address show
else
    echo "The 'ip' command is unavailable."
fi

# Test an optional TCP port.
if [[ -n "$port" ]]; then
    echo
    echo "Testing TCP port $port..."
    if timeout 5 bash -c 'exec 3<>"/dev/tcp/$1/$2"' _ "$host" "$port" \
        2>/dev/null; then
        echo "TCP connectivity to $host:$port: SUCCESS"
        log "TCP connection succeeded for host=$host port=$port"
    else
        echo "TCP connectivity to $host:$port: FAILED"
        log "TCP connection failed for host=$host port=$port"
        exit 1
    fi
fi

echo
echo "Network check completed."
log "Completed network check for host=$host port=${port:-not-specified}"
exit 0
