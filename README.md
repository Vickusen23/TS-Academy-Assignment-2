# Assignment 2 — Dockerized Diagnostic CLI

A containerized Bash diagnostic CLI tool built using Alpine Linux and Docker.

## Project Structure
- `app/diagnostic.sh`: Primary diagnostic CLI script.
- `app/health-check.sh`: Internal container health verification script.
- `Dockerfile`: Multi-stage Alpine-based container build file.
- `compose.yaml`: Local Docker Compose service configuration.
- `.dockerignore`: Excludes non-essential files from build context.
- `test.sh`: Automated test suite for container functionality.

## Usage

### Direct Docker Run
```bash
docker build -t diagnostic-tool .

# System info
docker run --rm diagnostic-tool system

# Disk info
docker run --rm diagnostic-tool disk

# Network check
docker run --rm diagnostic-tool network 127.0.0.1

# Help
docker run --rm diagnostic-tool help
