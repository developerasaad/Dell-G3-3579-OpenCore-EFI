# Diagnostic tools

Small launchd-based collectors for troubleshooting a Hackintosh when the
problematic macOS installation cannot be used interactively — for example a
panel that stays dark for minutes after boot, or Bluetooth that never
enumerates. You install them into the broken installation from a working one,
reboot, and read the reports back from the working system.

They are independent of OpenCore: nothing in the EFI installs, loads or
depends on them, and a normal installation does not need them.

## What each tool captures

| Script | Runs | Captures |
|---|---|---|
| `hackdiag.sh` | at boot, as root | display and backlight state sampled three times per boot (start, +10 s, +60 s): `AppleBacklightDisplay`/`AppleBacklight` properties, framebuffer state, EDID presence, `backlight-level` NVRAM value (decoded), boot-args, loaded display kexts, power settings. Also appends a one-line summary per boot to `history.log`, so a dull boot and a normal boot can be compared at a glance. |
| `seqdiag.sh` | at boot, as root | Bluetooth stack state: loaded Intel BT / BlueTool / backlight kexts, USB enumeration of the BT controller, `SPBluetoothDataType`, boot-args, plus a 60-second **live** log stream filtered to Bluetooth and backlight messages. |
| `i2cdiag.sh` | at boot, as root (also runs manually) | trackpad / I2C snapshot intended to be run on both a known-good and a problematic installation and diffed: pointer preferences, `VoodooI2CHIDDevice` properties (report interval, transport), interrupt-vs-polling evidence, GPIO controller, recent VoodooI2C kernel log, HID device list, power settings. |
| `keycap.sh` | at login (LaunchAgent) or manually | HID/brightness event capture. It asks you to press F11, F12, Fn+F11, Fn+F12 and the volume-mute key during a 40-second window, and records what the system actually receives. Useful when the volume keys work but the brightness keys do not. |
| `mic-test.sh` | manually | Guided four-step microphone check: quiet and sound-source recordings at the current input volume, then the same pair at 100 %. Reports RMS/peak dBFS per step and a verdict. |

The `launchd/` plists run the first three at boot and the last at login;
`mic-test.sh` is manual only. All of them are optional — pick the ones matching
your problem.

## Microphone test

`mic-test.sh` needs the `mic-test` helper: either a compiled binary beside the
script, or `mic-test.swift` plus `swiftc` — the script compiles it on first run.

```bash
cd tools/diagnostics/scripts
swiftc -O mic-test.swift -o mic-test      # once
bash mic-test.sh
```

It runs four numbered tests and waits for Enter before each: quiet and sound
source at the current input volume, then quiet and sound source at 100 %. Each
step prints RMS and peak dBFS; the summary prints a verdict and offers to replay
the last recording. WAV files stay in `~/Desktop/mic-test-<timestamp>/`.

On this laptop the microphone only produces a usable level at high input volume —
documented ALC236 behaviour, not a fault. Measured here: `-38.9` dBFS RMS at
100 % versus `-69.1` dBFS at the default gain, with a sound source next to the
machine. See
[Sonoma hardware support](../../Sonoma/docs/hardware-support.md#microphone-setup--set-input-volume-near-max)
for the setup steps.

## How the cross-OS install works

A launchd job placed in the **target** volume's `/Library/LaunchDaemons` starts
when that volume boots, regardless of which volume you used to copy it there.
The collector writes its report into the target volume, so you boot back into
your working system (or just mount the target volume) and read the files with
no need to operate the broken installation's UI.

`log stream` is used instead of `log show` on purpose: during early boot the
unified log is not yet queryable, but a live stream captures what happens from
that point onward.

## Installing

Assume you are booted from a working macOS installation and the target volume
is mounted at `/Volumes/Sequoia`. Replace the user name in the two places
marked below.

```bash
TARGET="/Volumes/Sequoia"
TARGET_USER="yourusername"

# scripts
sudo cp scripts/hackdiag.sh scripts/seqdiag.sh scripts/i2cdiag.sh scripts/keycap.sh "$TARGET/usr/local/bin/"
sudo chmod 755 "$TARGET/usr/local/bin/"{hackdiag,seqdiag,i2cdiag,keycap}.sh

# boot daemons (system domain)
sudo cp launchd/com.hackintosh.hackdiag.plist \
        launchd/com.hackintosh.seqdiag.plist \
        launchd/com.hackintosh.i2cdiag.plist \
        "$TARGET/Library/LaunchDaemons/"

# login agent (user domain)
mkdir -p "$TARGET/Users/$TARGET_USER/Library/LaunchAgents"
cp launchd/com.hackintosh.keycap.plist "$TARGET/Users/$TARGET_USER/Library/LaunchAgents/"
```

### Point the reports somewhere readable

By default the reports go to `/Library/Logs/hackdiag` on the target volume.
That is fine when you read them later from the other OS, but if you want them
in the user's Desktop (handy when you can log in but the display is bad), edit
the `EnvironmentVariables` dictionary in the three daemon plists:

```xml
<key>DIAG_OUTDIR</key>
<string>/Users/yourusername/Desktop/hackdiag</string>
<key>DIAG_OWNER</key>
<string>yourusername:staff</string>
<key>DIAG_USER</key>
<string>yourusername</string>   <!-- i2cdiag only: whose pointer settings to read -->
```

`DIAG_OWNER` hands the files to your user so you can open and delete them
without sudo. `i2cdiag` needs `DIAG_USER` because root's own preference domain
contains no trackpad settings.

If you install while booted **inside** the target system, copy the same files
to the same paths and load them immediately:

```bash
sudo launchctl bootstrap system /Library/LaunchDaemons/com.hackintosh.hackdiag.plist
sudo launchctl bootstrap system /Library/LaunchDaemons/com.hackintosh.seqdiag.plist
sudo launchctl bootstrap system /Library/LaunchDaemons/com.hackintosh.i2cdiag.plist
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.hackintosh.keycap.plist
```

## Reading the results

- `history.log` — one line per boot: boot number, OpenCore version, decoded
  `backlight-level`, the brightness node value, number of EDID entries and the
  root device. Comparing a bad boot against a good one usually shows the
  difference immediately.
- `boot-NNN-<timestamp>.log` — full per-boot report with the three samples.
- `seqdiag-<timestamp>.txt` — Bluetooth state plus the 60 s live log window.
- `i2cdiag-<osversion>.txt` — one file per macOS version, so the two reports
  are directly diffable.
- `keycap-<hhmmss>.txt` — HID/brightness events and the `bklt` value before
  and after the capture window.

## Uninstalling

Booted inside the target system:

```bash
sudo launchctl bootout system/com.hackintosh.hackdiag 2>/dev/null
sudo launchctl bootout system/com.hackintosh.seqdiag 2>/dev/null
sudo launchctl bootout system/com.hackintosh.i2cdiag 2>/dev/null
launchctl bootout gui/$(id -u)/com.hackintosh.keycap 2>/dev/null

sudo rm -f /Library/LaunchDaemons/com.hackintosh.hackdiag.plist \
           /Library/LaunchDaemons/com.hackintosh.seqdiag.plist \
           /Library/LaunchDaemons/com.hackintosh.i2cdiag.plist
rm -f ~/Library/LaunchAgents/com.hackintosh.keycap.plist

sudo rm -f /usr/local/bin/hackdiag.sh /usr/local/bin/seqdiag.sh \
           /usr/local/bin/i2cdiag.sh /usr/local/bin/keycap.sh

sudo rm -rf /Library/Logs/hackdiag
sudo rm -f /var/log/hackdiag.out /var/log/hackdiag.err \
           /var/log/seqdiag.out /var/log/seqdiag.err \
           /var/log/i2cdiag.out /var/log/i2cdiag.err \
           /tmp/keycap.out /tmp/keycap.err
```

From another OS with the target volume mounted, delete the same paths under
`/Volumes/<target>` — nothing can be running there while it is not booted, so
the `launchctl` steps are unnecessary.

macOS's own unified logging, crash reports and diagnostics are untouched by
any of this.

## Where these come from

These scripts were written and run on this machine while bringing up Sequoia.
`hackdiag.sh`, `seqdiag.sh` and `i2cdiag.sh` produced the boot-time reports that
the [known issues](../../Sequoia/docs/known-issues.md) and
[display backlight](../../Sequoia/docs/display-backlight.md) notes are based on;
`keycap.sh` confirmed that the brightness keys emit no HID event on Sequoia, and
`mic-test.sh` produced the input-volume measurements behind the microphone notes
on both installations.

For publication I replaced the hardcoded paths and private service labels with
the `DIAG_*` variables and `com.hackintosh.*` labels above. The capture commands
are unchanged from what ran on real hardware. These copies pass `bash -n` and
their plists pass `plutil -lint`, but they have not been run on a live install
since that change, so treat the first deployment as a smoke test — a new
`history.log` line is enough to confirm a collector ran.
