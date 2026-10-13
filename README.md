# Assignment 1: Linux, Bash and Networking

A Bash-based Linux diagnostic toolkit for collecting system
information, checking disk usage and testing network connectivity.

## Requirements

- Linux or WSL running Ubuntu
- Bash
- Standard Linux system utilities
- Git

## Setup

Clone the repository, then enter its directory.

Make the scripts executable:

    chmod +x *.sh

## Usage

Display system information:

    ./system-info.sh

Check disk usage against an 80% threshold:

    ./disk-check.sh 80 /

Check connectivity to a host:

    ./network-check.sh example.com

Check connectivity to a host on TCP port 443:

    ./network-check.sh example.com 443

## Logging

Diagnostic operations will write timestamped entries to the logs/
directory.

## Testing

Run the supplied grading script:

    ./grade.sh

## Assumptions

- Scripts run in a Linux environment.
- System information is collected at runtime.
- Network checks depend on DNS, network access and target availability.
- No cloud deployment is required.
