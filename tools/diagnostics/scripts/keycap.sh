#!/bin/bash
# keycap.sh — capture what the brightness keys actually emit.
#
# Run manually (sudo bash keycap.sh) or let the LaunchAgent start it at
# login. The script asks you to press specific keys during a 40-second
# capture window, so you learn which HID usage each key produces instead of
# guessing. Useful when volume keys work but brightness keys do not.
#
# Configuration:
#   DIAG_OUTDIR   directory for reports   (default $HOME/Desktop)

OUTDIR="${DIAG_OUTDIR:-$HOME/Desktop}"
mkdir -p "$OUTDIR" 2>/dev/null

OUT="$OUTDIR/keycap-$(date +%H%M%S).txt"

{
echo "======================================================"
echo " brightness key capture   $(date '+%Y-%m-%d %H:%M:%S')"
echo "======================================================"
echo
echo "--- keyboard HID devices ---"
hidutil list 2>/dev/null | grep -iE "keyboard" | head -10
echo
echo "--- BrightnessKeys / AppleBacklight loaded? ---"
kmutil showloaded --list-only 2>/dev/null | grep -iE "BrightnessKeys|AppleBacklight"
} > "$OUT" 2>&1

if [ -t 1 ]; then
    # interactive run (typed in Terminal)
    echo
    echo "  Get ready. During the capture, press these ONE AT A TIME,"
    echo "  about 4 seconds apart, in this order:"
    echo
    echo "     1)  F11        (brightness down)"
    echo "     2)  F12        (brightness up)"
    echo "     3)  Fn + F11"
    echo "     4)  Fn + F12"
    echo "     5)  F1 (volume mute, for comparison - a working key)"
    echo
    echo "  Starting in 5 seconds... watch the brightness each time."
    for i in 5 4 3 2 1; do printf "  %d..." "$i"; sleep 1; done
    echo
    echo "  >>> CAPTURING FOR 40 SECONDS — press the keys now <<<"
    echo
else
    # launched by the login agent: no terminal, so prompt audibly + notification
    /usr/bin/say "Key capture. Press F 11, F 12, then Fn F 11, Fn F 12. Recording now." 2>/dev/null
    /usr/bin/osascript -e 'display notification "Press F11, F12, Fn+F11, Fn+F12 now — 40 s recording" with title "keycap" sound name "Ping"' 2>/dev/null
    sleep 12
fi

{
echo
echo "=== HID / brightness events, 40 s window ==="
} >> "$OUT"

log stream --style compact --timeout 40 2>/dev/null \
    --predicate 'eventMessage CONTAINS[c] "brightness" OR eventMessage CONTAINS[c] "NX_KEYTYPE" OR eventMessage CONTAINS[c] "BrightnessKeys" OR eventMessage CONTAINS[c] "Keyboard" OR eventMessage CONTAINS[c] "IOHIDEvent"' \
    >> "$OUT"

{
echo
echo "=== brightness AFTER capture (did any key change it?) ==="
ioreg -r -c AppleBacklightDisplay -d 2 2>/dev/null | grep -o '"bklt"={[^}]*}'
} >> "$OUT"

chmod 644 "$OUT" 2>/dev/null

echo
echo "  done -> $OUT"
