#!/bin/bash
# seqdiag.sh — boot-time Bluetooth diagnostics.
#
# Started at boot as root by launchd/com.hackintosh.seqdiag.plist. Captures
# the Bluetooth stack state and a 60-second live log window. log show does
# not work this early in boot, log stream does — that is why the collector
# streams instead of querying history.
#
# Configuration:
#   DIAG_OUTDIR   directory for reports      (default /Library/Logs/hackdiag)
#   DIAG_OWNER    user:group to own reports  (default: none)

OUTDIR="${DIAG_OUTDIR:-/Library/Logs/hackdiag}"
OWNER="${DIAG_OWNER:-}"

mkdir -p "$OUTDIR" 2>/dev/null
[ -n "$OWNER" ] && chown "$OWNER" "$OUTDIR" 2>/dev/null

OUT="$OUTDIR/seqdiag-$(date +%Y-%m-%d_%H%M%S).txt"

# give the Bluetooth stack time to come up
sleep 8

{
echo "======================================================"
echo " Boot diagnostics   $(date '+%Y-%m-%d %H:%M:%S')"
echo " macOS $(sw_vers -productVersion)  build $(sw_vers -buildVersion)"
echo " root=$(df -h / | tail -1 | awk '{print $1}')"
echo "======================================================"
echo
echo "--- Bluetooth / backlight kexts loaded ---"
kmutil showloaded --list-only 2>/dev/null | grep -iE "BlueTool|IntelBT|Bluetooth|BrightnessKeys|AppleBacklight"
echo
echo "--- boot-args ---"
nvram -p 2>/dev/null | grep boot-args
echo
echo "--- USB devices (internal BT is USB) ---"
system_profiler SPUSBDataType 2>/dev/null | grep -iE "Bluetooth|Product ID|Vendor ID|8087" | head -12
echo
echo "--- Bluetooth controller state ---"
system_profiler SPBluetoothDataType 2>/dev/null | head -25
echo
echo "--- backlight binding (sanity) ---"
ioreg -r -c AppleBacklightDisplay -d 2 2>/dev/null | grep -o '"bklt"={[^}]*}'
} > "$OUT" 2>&1

[ -n "$OWNER" ] && chown "$OWNER" "$OUT" 2>/dev/null
chmod 644 "$OUT" 2>/dev/null

# --- live capture: 60 s of BT + HID messages (log show is useless this early) ---
{
echo
echo "=== LIVE LOG STREAM — first 60 s after boot ==="
} >> "$OUT"

log stream --style compact --timeout 60 2>/dev/null \
    --predicate 'eventMessage CONTAINS[c] "bluetooth" OR eventMessage CONTAINS[c] "IntelFirmware" OR eventMessage CONTAINS[c] "BlueTool" OR eventMessage CONTAINS[c] "BrightnessKeys"' \
    >> "$OUT"

[ -n "$OWNER" ] && chown "$OWNER" "$OUT" 2>/dev/null
exit 0
