#!/bin/bash
# lidwake-collect.sh — capture sleep/wake evidence from the unified log.
#
# Runs as root from com.hackintosh.lidwake (LaunchDaemon). Passive: it
# subscribes to a filtered log stream and reads pmset/ioreg state when power
# events appear. It creates no assertions and does not touch power settings.
#
# Output: /Library/Logs/lidwake/session-<timestamp>/
#   baseline.txt              state when the daemon started
#   events.log                filtered stream lines (bounded to ~5 MB)
#   event-NNN-<hhmmss>.txt    snapshot taken on a matched event
#   backfill-NNN.log          unified-log window around a wake event
#
# The stream is suspended while the machine sleeps. Events that happened
# during sleep are recovered from pmset's history and from log show backfill,
# not from the live stream.

set -u

OUT="${LIDWAKE_OUTDIR:-/Library/Logs/lidwake}"
mkdir -p "$OUT" 2>/dev/null
chmod 755 "$OUT" 2>/dev/null

STAMP=$(date +%Y%m%d-%H%M%S)
SESSION="$OUT/session-$STAMP"
mkdir -p "$SESSION"
chmod 755 "$SESSION"

# keep the 10 newest sessions
ls -dt "$OUT"/session-* 2>/dev/null | tail -n +11 | while read -r old; do
    rm -rf "$old"
done

now() { date '+%Y-%m-%d %H:%M:%S %z'; }

wifi_if() {
    /usr/sbin/networksetup -listallhardwareports 2>/dev/null \
        | awk '/Hardware Port: (Wi-Fi|AirPort)/{getline; print $2; exit}'
}

snapshot() {   # snapshot <label> <file>
    local label="$1" file="$2" wifi
    wifi=$(wifi_if)
    {
        echo "=== $label — $(now) ==="
        echo "--- boot time (changes only on reboot) ---"
        /usr/sbin/sysctl -n kern.boottime 2>/dev/null
        echo "--- clamshell ---"
        /usr/sbin/ioreg -r -k AppleClamshellState -d 4 2>/dev/null \
            | grep -E '"AppleClamshell(State|CausesSleep)" ='
        echo "--- display power (4 = on) ---"
        /usr/sbin/ioreg -n IODisplayWrangler -r -d 1 2>/dev/null \
            | grep -o '"CurrentPowerState"=[0-9]*'
        echo "--- backlight ---"
        /usr/sbin/ioreg -r -c AppleBacklightDisplay -d 2 2>/dev/null \
            | grep -o '"bklt"={[^}]*}' || echo "  (no bklt value)"
        echo "--- power source ---"
        /usr/bin/pmset -g batt 2>/dev/null | tail -2
        echo "--- assertions (summary) ---"
        /usr/bin/pmset -g assertions 2>/dev/null | sed -n '3,12p'
        echo "--- Wi-Fi power ---"
        if [ -n "$wifi" ]; then
            /usr/sbin/networksetup -getairportpower "$wifi" 2>/dev/null
        else
            echo "  (no Wi-Fi interface found)"
        fi
        echo "--- input devices ---"
        /usr/sbin/ioreg -r -c VoodooI2CHIDDevice -d 2 2>/dev/null \
            | grep -E "IOName|ReportInterval" | head -4
        echo "--- sleep/wake history (pmset) ---"
        /usr/bin/pmset -g log 2>/dev/null \
            | grep -E "Entering Sleep|Wake from" | tail -6
    } > "$file" 2>&1
}

# Recover the sleep window from the persistent log. The live stream is
# suspended during sleep, so a bounded log show window is the reliable part.
backfill() {   # backfill <n>
    /usr/bin/log show --last 3m --style compact --predicate '
        (process == "kernel" AND eventMessage CONTAINS "PMRD:")
        OR (process == "WindowServer" AND (eventMessage CONTAINS "displayDidWake" OR eventMessage CONTAINS "displayDidSleep"))
        OR (process == "airportd" AND eventMessage CONTAINS "System wake reason")
    ' 2>/dev/null > "$SESSION/backfill-$(printf '%03d' "$1").log"
}

rotate() {
    local f="$SESSION/events.log"
    [ -f "$f" ] || return 0
    if [ "$(stat -f%z "$f" 2>/dev/null || echo 0)" -gt 5242880 ]; then
        tail -n 20000 "$f" > "$f.tmp" 2>/dev/null && mv "$f.tmp" "$f"
    fi
}

snapshot "baseline" "$SESSION/baseline.txt"

n=0
last_snap=0

/usr/bin/log stream --style compact --predicate '
    (process == "kernel" AND (eventMessage CONTAINS "PMRD:" OR eventMessage CONTAINS[c] "VoodooI2C" OR eventMessage CONTAINS[c] "AppleMultitouchDevice" OR eventMessage CONTAINS[c] "ApplePS2"))
    OR (process == "WindowServer" AND (eventMessage CONTAINS "displayDidWake" OR eventMessage CONTAINS "displayDidSleep" OR eventMessage CONTAINS "displayWillSleep" OR eventMessage CONTAINS "CoreRCDisplayPowerNotification"))
    OR (process == "airportd" AND eventMessage CONTAINS "System wake reason")
    OR (process == "bluetoothd" AND eventMessage CONTAINS[c] "wake")
    OR (process == "corebrightnessd" AND (eventMessage CONTAINS "Woke Up" OR eventMessage CONTAINS "new state" OR eventMessage CONTAINS "BacklightControl"))
' 2>/dev/null | while IFS= read -r line; do
    printf '%s\n' "$line" >> "$SESSION/events.log"
    rotate

    case "$line" in
        *"sleep reason"*|*"displayDidWake"*|*"System wake reason"*|*"Wake from"*)
            t=$(date +%s)
            if [ $((t - last_snap)) -ge 5 ]; then
                last_snap=$t
                n=$((n + 1))
                snapshot "event $n" "$SESSION/event-$(printf '%03d' "$n")-$(date +%H%M%S).txt"
                case "$line" in
                    *"displayDidWake"*|*"System wake reason"*) backfill "$n" ;;
                esac
            fi
            ;;
    esac
done
