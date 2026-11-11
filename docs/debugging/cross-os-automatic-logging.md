# Cross-OS Automatic Logging (Sonoma → Sequoia)

During development, the Sequoia boot display was dark or unusable for several
minutes after login. Collecting diagnostics from a live Sequoia session therefore
wasn't practical early on.

The workaround: prepare diagnostic scripts in Sonoma, install them into the
**Sequoia** volume while booted in Sonoma, and register them as launchd services.
They then run automatically at every Sequoia boot, write their results to the
user's Desktop, and can be read back from Sonoma afterwards — without depending
on the display being usable.

These collectors are **temporary troubleshooting tools**. Nothing in the EFI or
the operating system depends on them, and a normal installation does not need
them. Install them for a specific investigation and remove them when it is
finished (see [Removing](#removing)).

Reusable, sanitized versions of the scripts and their launchd jobs live in
[`tools/diagnostics/`](../../tools/diagnostics/README.md) — that directory has
the install, configure and uninstall instructions; this page describes the
approach and what it found.

## Design

| Service | Type | Runs | Captures |
|---------|------|------|----------|
| `com.<username>.seqdiag` | LaunchDaemon (root, boot) | at boot, ~70 s window | Bluetooth/backlight kexts, USB enumeration, controller state, live 60 s log stream |
| `com.<username>.i2cdiag` | LaunchDaemon (root, boot) | at boot | I2C trackpad state, report interval, pointer settings |
| `com.<username>.keycap` | LaunchAgent (user, login) | ~12 s after login | spoken prompt + 40 s HID/brightness log capture while keys are pressed |
| `brightness-test.sh` | one-shot | manual | driver `bklt` value before/after each key combination, with verdict |

All output lands in `~/Desktop` on Sequoia, which is readable from Sonoma once the
other drive is mounted.

Two implementation details matter:

1. **`log show` does not work this early.** `logd` isn't ready seconds after boot,
   so the collector uses `log stream` with a timeout instead — it attaches
   immediately and records whatever arrives.
2. **Files are written as root**, so the collector chowns them back to the user
   account, otherwise they can't be read from Sonoma without sudo.

## The boot collector

`/usr/local/bin/seqdiag.sh`:

```bash
#!/bin/bash
OUT="/Users/<user>/Desktop/seqdiag-$(date +%Y-%m-%d_%H%M%S).txt"
sleep 8

{
echo "=== Sequoia boot diagnostics ==="
kmutil showloaded --list-only 2>/dev/null | \
    grep -iE "BlueTool|IntelBT|Bluetooth|BrightnessKeys|AppleBacklight"
nvram -p 2>/dev/null | grep boot-args
system_profiler SPUSBDataType 2>/dev/null | \
    grep -iE "Bluetooth|Product ID|Vendor ID|8087" | head -12
system_profiler SPBluetoothDataType 2>/dev/null | head -25
ioreg -r -c AppleBacklightDisplay -d 2 2>/dev/null | grep -o '"bklt"={[^}]*}'
} > "$OUT" 2>&1

chown <user>:staff "$OUT" 2>/dev/null

# log show is unreliable this early — use log stream instead
log stream --style compact --timeout 60 2>/dev/null \
    --predicate 'eventMessage CONTAINS[c] "bluetooth" OR \
                 eventMessage CONTAINS[c] "IntelFirmware" OR \
                 eventMessage CONTAINS[c] "BlueTool" OR \
                 eventMessage CONTAINS[c] "BrightnessKeys"' \
    >> "$OUT"

chown <user>:staff "$OUT" 2>/dev/null
exit 0
```

`/Library/LaunchDaemons/com.<username>.seqdiag.plist`:

```xml
<dict>
    <key>Label</key><string>com.<username>.seqdiag</string>
    <key>ProgramArguments</key>
    <array><string>/bin/bash</string><string>/usr/local/bin/seqdiag.sh</string></array>
    <key>RunAtLoad</key><true/>
    <key>UserName</key><string>root</string>
    <key>StandardOutPath</key><string>/var/log/seqdiag.out</string>
    <key>StandardErrorPath</key><string>/var/log/seqdiag.err</string>
</dict>
```

## The key-press capture

`BrightnessKeys` reacts to ACPI brightness events, so diagnosing the keys meant
recording what happens while they are pressed — which requires interaction. The
login agent `com.<username>.keycap` runs a 40-second capture right after login and
announces the window with `say` and a notification:

```bash
/usr/bin/say "Key capture. Press F 11, F 12, then Fn F 11, Fn F 12. Recording now."
log stream --style compact --timeout 40 2>/dev/null \
    --predicate 'eventMessage CONTAINS[c] "brightness" OR \
                 eventMessage CONTAINS[c] "NX_KEYTYPE" OR \
                 eventMessage CONTAINS[c] "BrightnessKeys" OR \
                 eventMessage CONTAINS[c] "Keyboard"' \
    >> "$OUT"
ioreg -r -c AppleBacklightDisplay -d 2 2>/dev/null | grep -o '"bklt"={[^}]*}' >> "$OUT"
```

The agent plist is the same structure with `LimitLoadToSessionType = Aqua`
(login session, not boot) and no `UserName`, so it runs as the logged-in user and
`say`/notifications are heard.

## Installing from Sonoma

The trick that makes this "automatic" is that the Sequoia Data volume is mounted
while Sonoma runs, so the services can be installed without booting Sequoia:

```bash
V="/Volumes/<Sequoia Data volume>"   # mount point of the Sequoia Data volume

sudo cp seqdiag.sh    "$V/usr/local/bin/seqdiag.sh"
sudo chmod 755        "$V/usr/local/bin/seqdiag.sh"
sudo cp com.<username>.seqdiag.plist "$V/Library/LaunchDaemons/"

sudo cp keycap.sh     "$V/usr/local/bin/keycap.sh"
sudo cp com.<username>.keycap.plist "$V/Users/<user>/Library/LaunchAgents/"
```

`launchd` scans `Library/LaunchDaemons` and the user's `Library/LaunchAgents` on
boot, so nothing else is needed — the next Sequoia boot runs the collectors.

## Reading the results

Boot Sequoia once, then in Sonoma:

```bash
ls ~/Desktop   # from the Sequoia volume, mounted as a secondary volume
cat seqdiag-*.txt
```

## Removing

```bash
sudo launchctl bootout system/com.<username>.seqdiag 2>/dev/null
sudo rm /Library/LaunchDaemons/com.<username>.seqdiag.plist /usr/local/bin/seqdiag.sh
launchctl bootout gui/$(id -u)/com.<username>.keycap 2>/dev/null
rm ~/Library/LaunchAgents/com.<username>.keycap.plist /usr/local/bin/keycap.sh
```

## What it found on this machine

- `AppleBacklightDisplay` → `bklt` stayed at its maximum during the dark-screen
  period, while macOS requested full brightness — pointing at the backlight
  register path rather than a brightness policy. See
  [display backlight](../../Sequoia/docs/display-backlight.md).
- With the USB map disabled, the Intel Bluetooth device (XHCI port HS14) did not
  enumerate at all, and `IntelBluetoothFirmware` consequently never loaded. See
  [known issues](../../Sequoia/docs/known-issues.md).
