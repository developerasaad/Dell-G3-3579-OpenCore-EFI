#!/bin/bash
# i2cdiag.sh — trackpad / I2C snapshot for comparing two macOS installations.
#
# Run it once on a known-good installation and once on the problematic one,
# then diff the two reports. The output is plain text with the same sections
# in the same order, so the diff is readable.
#
# Configuration:
#   DIAG_OUTDIR   directory for reports   (default /Library/Logs/hackdiag)
#   DIAG_OWNER    user:group to own them  (default: none)
#   DIAG_USER     whose global preferences to read when running as root
#                 (root's own domain has no pointer settings)

OUTDIR="${DIAG_OUTDIR:-/Library/Logs/hackdiag}"
OWNER="${DIAG_OWNER:-}"
DIAG_USER="${DIAG_USER:-}"

mkdir -p "$OUTDIR" 2>/dev/null
[ -n "$OWNER" ] && chown "$OWNER" "$OUTDIR" 2>/dev/null

OUT="$OUTDIR/i2cdiag-$(sw_vers -productVersion).txt"

# when launched by the boot daemon, give the driver time to bind
sleep 10

# Read a global preference correctly whether we run as root (LaunchDaemon)
# or as the user (manual run).
read_g() {
    if [ "$(id -u)" -eq 0 ] && [ -n "$DIAG_USER" ]; then
        defaults read "/Users/$DIAG_USER/Library/Preferences/.GlobalPreferences" "$1" 2>/dev/null
    else
        defaults read -g "$1" 2>/dev/null
    fi
}

{
echo "=========================================================="
echo " trackpad / I2C snapshot"
echo " macOS $(sw_vers -productVersion)  build $(sw_vers -buildVersion)"
echo " $(date '+%Y-%m-%d %H:%M:%S')"
echo "=========================================================="
echo
echo "--- POINTER SETTINGS (user-level, NOT in EFI) ---"
echo -n "  trackpad.scaling   = "; read_g com.apple.trackpad.scaling || echo "(unset)"
echo -n "  trackpad.scrolling = "; read_g com.apple.trackpad.scrolling || echo "(unset)"
echo -n "  mouse.scaling      = "; read_g com.apple.mouse.scaling || echo "(unset)"
echo -n "  forceClick         = "; defaults read com.apple.AppleMultitouchTrackpad ForceClick 2>/dev/null || echo "(unset)"
echo -n "  dragLock           = "; defaults read com.apple.AppleMultitouchTrackpad DragLock 2>/dev/null || echo "(unset)"
echo
echo "--- TRACKPAD HARDWARE / DRIVER ---"
ioreg -r -c VoodooI2CHIDDevice -d 2 2>/dev/null \
    | grep -iE "IOName|ReportInterval|MaxInputReportSize|Product|Transport|HIDDefault" | head -15
echo
echo "--- INTERRUPT vs POLLING EVIDENCE (ioreg) ---"
ioreg -lw0 2>/dev/null | grep -iE "VoodooI2C.*(Interrupt|Polling|Mode)" | head -10
ioreg -r -c VoodooI2CController -d 1 2>/dev/null | grep -iE "Interrupt|Polling|Mode" | head -10
echo
echo "--- GPIO CONTROLLER ---"
ioreg -r -c VoodooGPIO -d 1 2>/dev/null | grep -iE "IOName|Interrupt|Base|Class" | head -10
echo
echo "--- KERNEL LOG: VoodooI2C since boot ---"
log show --last 30m --predicate 'eventMessage CONTAINS "VoodooI2C" OR eventMessage CONTAINS "VoodooGPIO"' 2>/dev/null \
    | grep -viE "^Timestamp|^Filtering" | tail -40
echo
echo "--- HID DEVICE LIST ---"
hidutil list 2>/dev/null | grep -iE "Trackpad|Touch|Voodoo" | head -10
echo
echo "--- POWER (usb/i2c idle behaviour) ---"
pmset -g 2>/dev/null | grep -iE "hibernate|standby|powernap|autopoweroff"
} > "$OUT" 2>&1

# root writes these; hand them back to the user when an owner is configured
[ -n "$OWNER" ] && chown "$OWNER" "$OUT" 2>/dev/null
chmod 644 "$OUT" 2>/dev/null

echo "written: $OUT"
echo
sed -n '1,40p' "$OUT"

# --- one-line summary so logins can be compared like display boots ---
SC=$(read_g com.apple.trackpad.scaling || echo unset)
RI=$(ioreg -r -c VoodooI2CHIDDevice -d 2 2>/dev/null \
     | grep -oE '"ReportInterval" = [0-9]+' | head -1 | grep -oE '[0-9]+$')
DRV=$(log show --last 5m --style compact --predicate 'eventMessage CONTAINS "VoodooI2C"' 2>/dev/null \
     | grep -c "VoodooI2CPrecisionTouchpadHIDEventDriver")
echo "$(date '+%F %T') | macos=$(sw_vers -productVersion) | scaling=$SC | reportInterval=${RI:-n/a} | driverLines=$DRV" \
    >> "$OUTDIR/i2cdiag-history.log"
[ -n "$OWNER" ] && chown "$OWNER" "$OUTDIR/i2cdiag-history.log" 2>/dev/null
