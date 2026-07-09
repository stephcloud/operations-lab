#!/usr/bin/env bash
# tests/smoke.sh: confirms all scripts run and shows their output.
set -euo pipefail

echo "### shellcheck ###"
shellcheck bin/*
echo "shellcheck: clean"

echo
echo "### sysnap ###"
bin/sysnap

echo
echo "### diskmap /tmp --top 5 ###"
bin/diskmap /tmp --top 5

echo
echo "### netcheck ###"
bin/netcheck

echo
echo "Smoke OK"
