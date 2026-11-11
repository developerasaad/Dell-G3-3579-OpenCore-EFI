#!/bin/bash
# hackdiag.sh — boot-time display and backlight diagnostics.
#
# Started at boot as root by launchd/com.hackintosh.hackdiag.plist. Samples
# the display/backlight path three times (at start, +10 s, settled) and
# appends a one-line summary to history.log, so a boot with a dark or dull
# panel can be compared against a normal one.
#
# Configuration (environment variables, set in the launchd job):
#   DIAG_OUTDIR   directory for reports      (default /Library/Logs/hackdiag)
#   DIAG_OWNER    user:group to own reports  (default: none)

OUTDIR="${DIAG_OUTDIR:-/Library/Logs/hackdiag}"
OWNER="${DIAG_OWNER:-}"

mkdir -p "$OUTDIR" 2>/dev/null
[ -n "$OWNER" ] && chown "$OWNER" "$OUTDIR" 2>/dev/null

BOOTID=$(cat /var/db/hackdiag.bootid 2>/dev/null || echo 0)
BOOTID=$((BOOTID + 1))
echo "$BOOTID" > /var/db/hackdiag.bootid 2>/dev/null

STAMP=$(date "+%Y-%m-%d_%H%M%S")
LOG="$OUTDIR/boot-$(printf %03d "$BOOTID")-$STAMP.log"

snapshot() {
    local label="$1"
    echo ""
    echo "############ SAMPLE: $label  ($(date '+%H:%M:%S')) ############"
    echo "--- AppleBacklightDisplay ---"
    ioreg -r -c AppleBacklightDisplay -d 3 2>/dev/null | grep -iE "brightness|value|current|max" | head -20
    echo "--- AppleBacklight (full properties) ---"
    ioreg -r -c AppleBacklight -d 1 2>/dev/null | head -25
    echo "--- AppleDisplay ---"
    ioreg -r -c AppleDisplay -d 2 2>/dev/null | grep -iE "brightness|value|current" | head -10
    echo "--- framebuffer / connector ---"
    ioreg -rc AppleIntelFramebuffer 2>/dev/null | grep -iE "CurrentDisplay|Enabled|Framebuffer" | head -10
    echo "--- displays ---"
    system_profiler SPDisplaysDataType 2>/dev/null | grep -iE "Resolution|Chipset|VRAM|Metal|Connection Type"
}

{
    echo "=== hackdiag boot #$BOOTID — $(date '+%Y-%m-%d %H:%M:%S') ==="
    echo ""
    echo "--- boot time ---"
    sysctl -n kern.boottime 2>/dev/null
    sw_vers 2>/dev/null
    echo ""
    echo "--- root volume ---"
    df -h / 2>/dev/null | tail -1
    echo ""
    echo "--- OpenCore version ---"
    nvram 4D1FDA02-38C7-4A6A-9CC6-4BCCA8B30102:opencore-version 2>/dev/null
    echo ""
    echo "--- NVRAM: boot-args / csr / revpatch ---"
    nvram -p 2>/dev/null | grep -E "boot-args|csr-active-config|revpatch"
    echo ""
    echo "--- NVRAM: brightness / backlight / display keys ---"
    nvram -p 2>/dev/null | grep -iE "bright|backlight|display|AAPL" \
        | grep -viE "fmm-mobileme-token|authToken|personID|adsid|iCloud|userid"
    echo ""
    echo "--- NVRAM: backlight-level as HEX (the persisted state) ---"
    BLHEX=$(nvram -x backlight-level 2>/dev/null | sed -n '/<data>/,/<\/data>/p' \
            | grep -v data | tr -d ' \t\n' | base64 -D 2>/dev/null | xxd -p | tr -d '\n')
    if [ -n "$BLHEX" ]; then
        echo "  backlight-level hex = $BLHEX"
        echo "  big-endian    = $((16#$BLHEX))  (of 65535)"
    else
        echo "  backlight-level = <absent>"
    fi
    nvram -x ForceDisplayRotationInEFI 2>/dev/null
    echo ""
    echo "--- EDID entries (override present?) ---"
    ioreg -lw0 2>/dev/null | grep -oE '"IODisplayEDID" = <[0-9a-f]+>' | head -3
    echo ""
    echo "--- display / backlight kexts loaded ---"
    kmutil showloaded --list-only 2>/dev/null | grep -iE "lilu|whatevergreen|smclightsensor|applebac|voodooi2c|virtualsmc|brightnesskeys"
    echo ""
    echo "--- input devices ---"
    ioreg -rc VoodooI2CHIDDevice 2>/dev/null | grep -iE "IOName|class" | head -5
    ioreg -rc ApplePS2Controller 2>/dev/null | grep -iE "IOName|class" | head -5
    echo ""
    echo "--- power settings ---"
    pmset -g 2>/dev/null | head -20

    snapshot "boot +5s"
    sleep 5
    snapshot "boot +10s"
    sleep 50
    snapshot "boot +60s (settled)"
} > "$LOG" 2>&1

[ -n "$OWNER" ] && chown "$OWNER" "$LOG" 2>/dev/null
chmod 644 "$LOG" 2>/dev/null

BRIGHT=$(ioreg -r -c AppleBacklightDisplay -d 3 2>/dev/null \
         | grep -oiE '"brightness"[^0-9]*[0-9]+' | head -1 | grep -oE '[0-9]+$')
[ -z "$BRIGHT" ] && BRIGHT="n/a"
BL=$(nvram -x backlight-level 2>/dev/null | sed -n '/<data>/,/<\/data>/p' \
     | grep -v data | tr -d ' \t\n' | base64 -D 2>/dev/null | xxd -p | tr -d '\n')
[ -z "$BL" ] && BL="none"
EDID_N=$(ioreg -lw0 2>/dev/null | grep -c IODisplayEDID)
OCV=$(nvram 4D1FDA02-38C7-4A6A-9CC6-4BCCA8B30102:opencore-version 2>/dev/null | awk '{print $2}')
VOL=$(df -h / 2>/dev/null | tail -1 | awk '{print $1}')

echo "$(date '+%F %T') | boot#$BOOTID | oc=$OCV | backlight_level=$BL | brightness_node=$BRIGHT | edid=$EDID_N | root=$VOL" \
    >> "$OUTDIR/history.log"
[ -n "$OWNER" ] && chown "$OWNER" "$OUTDIR/history.log" 2>/dev/null

exit 0
