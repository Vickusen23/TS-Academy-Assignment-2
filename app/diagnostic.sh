#!/usr/bin/env bash
set -u

show_help() {
  echo "Diagnostic CLI Tool"
  echo "Usage: diagnostic <command> [arguments]"
  echo
  echo "Available Commands:"
  echo "  system           Display useful Linux system information."
  echo "  network <host>   Check connectivity to the supplied host."
  echo "  disk             Display disk usage information."
  echo "  help             Display this help message."
}

if [[ $# -lt 1 ]]; then
  echo "Error: Missing command."
  show_help
  exit 2
fi

COMMAND="$1"
shift

case "$COMMAND" in
  system)
    echo "=== System Information ==="
    echo "Hostname: $(hostname)"
    echo "User: $(whoami)"
    echo "Kernel: $(uname -r)"
    echo "Uptime: $(uptime -p 2>/dev/null || uptime)"
    ;;

  network)
    if [[ $# -lt 1 ]]; then
      echo "Error: Host argument is required for network command."
      exit 2
    fi
    HOST="$1"
    echo "=== Network Check for $HOST ==="
    if ping -c 2 "$HOST" >/dev/null 2>&1; then
      echo "Status: Reachable ($HOST)"
      exit 0
    else
      echo "Status: Unreachable ($HOST)"
      exit 1
    fi
    ;;

  disk)
    echo "=== Disk Information ==="
    df -h /
    ;;

  help|--help|-h)
    show_help
    exit 0
    ;;

  *)
    echo "Error: Invalid command '$COMMAND'."
    show_help
    exit 2
    ;;
esac
