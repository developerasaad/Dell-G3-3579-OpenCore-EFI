#!/bin/bash
# lidwake-report.sh — summarize one lidwake session.
# Usage: bash lidwake-report.sh [session-dir]
# Reads only from /Library/Logs/lidwake; no privileges required if the
# session files are world-readable (they are, mode 755).

set -u
BASE="${LIDWAKE_OUTDIR:-/Library/Logs/lidwake}"
S="${1:-$(ls -dt "$BASE"/session-* 2>/dev/null | head -1)}"

if [ -z "${S:-}" ] || [ ! -d "$S" ]; then
    echo "no session directory under $BASE" >&2
    exit 1
fi

start=$(sed -n '2p' "$S/baseline.txt" 2>/dev/null | sed 's/^ *//')
[ -z "${start:-}" ] && start="1970-01-01 00:00:00"

echo "# lidwake session $(basename "$S")"
echo
echo "- started: $start"
echo "- OS now:  $(sw_vers -productVersion) ($(sw_vers -buildVersion))"
echo "- files:   $(ls "$S" | wc -l | tr -d ' ')"
echo

echo "## Sleep / wake entries since session start"
echo
echo '```'
pmset -g log 2>/dev/null \
    | grep -E "Entering Sleep|Wake from" \
    | awk -v s="$start" '$0 >= s'
echo '```'
echo

echo "## Snapshots"
for f in "$S"/event-*.txt; do
    [ -f "$f" ] || continue
    echo
    echo "### $(basename "$f")"
    echo '```'
    grep -E "^===|AppleClamshellState|CurrentPowerState|\"bklt\"|Now drawing|Entering Sleep|Wake from" "$f" | head -14
    echo '```'
done

echo
echo "## Boot time(s) observed (more than one means a reboot)"
echo
echo '```'
grep -h "{ sec =" "$S"/*.txt 2>/dev/null | sed 's/^ *//' | sort -u
echo '```'

echo
echo "## Raw files"
echo
ls -1 "$S"
