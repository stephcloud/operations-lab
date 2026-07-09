# Diagnostic Toolkit

Four small bash scripts that replace the same handful of commands I kept typing whenever a server needed a quick health check.

## What's here

- `bin/sysnap` — one-screen snapshot: host info, uptime, memory, top processes, disk usage, listening ports
- `bin/logscan` — searches journalctl for a pattern, with surrounding context, scoped to a time window or a specific service
- `bin/diskmap` — shows the largest files/folders under a given path
- `bin/netcheck` — checks connectivity to a few known hosts, DNS resolution, and outbound HTTPS

## Usage

```bash
chmod +x bin/*
./bin/sysnap
./bin/logscan "ssh" --since "today"
./bin/diskmap /var --top 10
./bin/netcheck
```

To install system-wide:

```bash
ln -sf "$(pwd)/bin/"* /usr/local/bin/
```

## Testing

```bash
./tests/smoke.sh
```

Runs shellcheck against all four scripts, then runs each one and prints its output, ending with `Smoke OK` if everything passed.

## Notes

All four scripts use `set -euo pipefail` and pass shellcheck with no warnings. Built and tested on a real EC2 instance (`bedrock-vm-01`, Ubuntu 26.04), not just locally.
