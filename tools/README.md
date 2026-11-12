# Diagnostic tools

Small collectors for troubleshooting a Hackintosh when the affected macOS
installation cannot be used interactively — a panel that stays dark after boot,
Bluetooth that never enumerates, a touchpad that feels wrong, or a microphone
that seems dead.

The tools are grouped by the hardware they examine. Each directory holds the
script and, where one exists, the launchd job that runs it:

```
tools/
├── graphics/     hackdiag.sh + com.hackintosh.hackdiag.plist
├── bluetooth/    seqdiag.sh  + com.hackintosh.seqdiag.plist
├── keyboard/     keycap.sh   + com.hackintosh.keycap.plist
├── touchpad/     i2cdiag.sh  + com.hackintosh.i2cdiag.plist
├── microphone/   mic-test.sh + mic-test.swift
└── power/
    └── lid-wake/ lidwake-collect.sh + com.hackintosh.lidwake.plist + lidwake-report.sh
```

They are independent of OpenCore: nothing in the EFI installs, loads or depends
on them, and a normal installation does not need them.

## What each tool captures

| Domain | Tool | Runs | Captures |
|---|---|---|---|
| `graphics/` | `hackdiag.sh` | at boot, as root | display and backlight state sampled three times per boot (start, +10 s, +60 s): `AppleBacklightDisplay`/`AppleBacklight` properties, framebuffer state, EDID presence, decoded `backlight-level` NVRAM value, boot-args, loaded display kexts, power settings. Appends a one-line summary per boot to `history.log`. |
| `bluetooth/` | `seqdiag.sh` | at boot, as root | loaded Intel BT / BlueTool kexts, USB enumeration of the BT controller, `SPBluetoothDataType`, boot-args, backlight `bklt` sanity check, plus a 60-second **live** log stream filtered to Bluetooth and backlight messages. |
| `keyboard/` | `keycap.sh` | at login (LaunchAgent) or manually | HID/brightness event capture. Asks you to press F11, F12, Fn+F11, Fn+F12 and the volume-mute key during a 40-second window and records what the system actually receives. |
| `touchpad/` | `i2cdiag.sh` | at boot, as root (also runs manually) | trackpad / I2C snapshot meant to be run on a known-good and a problematic installation and diffed: pointer preferences, `VoodooI2CHIDDevice` properties, interrupt-vs-polling evidence, GPIO controller, recent VoodooI2C log, HID device list, power settings. |
| `microphone/` | `mic-test.sh` | manually | guided four-step microphone check: quiet and sound-source recordings at the current input volume, then the same pair at 100 %. Reports RMS/peak dBFS per step and a verdict. |
| `power/lid-wake/` | `lidwake-collect.sh` | at boot, as root | lid sleep/wake evidence: filtered `PMRD:` power events, WindowServer display wake, `airportd` wake reason, plus a `pmset`/`ioreg` snapshot on each event and a 3-minute wake backfill. `lidwake-report.sh` summarises a session. |

## How the cross-OS install works

A launchd job placed in the **target** volume's `/Library/LaunchDaemons`, or in a
user's `Library/LaunchAgents`, starts when that volume boots, regardless of which
volume you used to copy it there. The collector writes its report into the target
volume, so you boot back into your working system (or just mount the target
volume) and read the files without operating the broken installation's UI.

`log stream` is used instead of `log show` on purpose: during early boot the
unified log is not yet queryable, but a live stream captures what happens from
that point onward. The broader technique is described in
[cross-os automatic logging](../docs/debugging/cross-os-automatic-logging.md).

## Installing

Assume you are booted from a working macOS installation, the target volume is
mounted at `/Volumes/Sequoia`, and your shell is in `tools/`. Replace the user
name below.

```bash
TARGET="/Volumes/Sequoia"
TARGET_USER="yourusername"

# scripts -> /usr/local/bin on the target
sudo cp graphics/hackdiag.sh bluetooth/seqdiag.sh touchpad/i2cdiag.sh keyboard/keycap.sh \
        "$TARGET/usr/local/bin/"
sudo chmod 755 "$TARGET/usr/local/bin/"{hackdiag,seqdiag,i2cdiag,keycap}.sh

# boot daemons (system domain)
sudo cp graphics/com.hackintosh.hackdiag.plist \
        bluetooth/com.hackintosh.seqdiag.plist \
        touchpad/com.hackintosh.i2cdiag.plist \
        "$TARGET/Library/LaunchDaemons/"

# login agent (user domain)
mkdir -p "$TARGET/Users/$TARGET_USER/Library/LaunchAgents"
cp keyboard/com.hackintosh.keycap.plist "$TARGET/Users/$TARGET_USER/Library/LaunchAgents/"
```

The repository paths above (e.g. `graphics/hackdiag.sh`) are the **source**
locations. Once installed they live at `/usr/local/bin/<tool>.sh` on the target
volume, which is what the plists reference — keep that layout when editing.

The sleep/wake collector in `power/lid-wake/` installs the same way but keeps its
own instructions in
[power/lid-wake/README.md](power/lid-wake/README.md); it writes to
`/Library/Logs/lidwake` and needs no `DIAG_*` variables.

### Point the reports somewhere readable

By default the reports go to `/Library/Logs/hackdiag` on the target volume. That
is fine when you read them later from the other OS, but if you want them in the
user's Desktop (handy when you can log in but the display is bad), edit the
`EnvironmentVariables` dictionary in the three daemon plists:

```xml
<key>DIAG_OUTDIR</key>
<string>/Users/yourusername/Desktop/hackdiag</string>
<key>DIAG_OWNER</key>
<string>yourusername:staff</string>
<key>DIAG_USER</key>
<string>yourusername</string>   <!-- i2cdiag only: whose pointer settings to read -->
```

`DIAG_OWNER` hands the files to your user so you can open and delete them without
sudo. `i2cdiag` needs `DIAG_USER` because root's own preference domain contains
no trackpad settings.

If you install while booted **inside** the target system, copy the same files to
the same runtime paths and load them immediately:

```bash
sudo launchctl bootstrap system /Library/LaunchDaemons/com.hackintosh.hackdiag.plist
sudo launchctl bootstrap system /Library/LaunchDaemons/com.hackintosh.seqdiag.plist
sudo launchctl bootstrap system /Library/LaunchDaemons/com.hackintosh.i2cdiag.plist
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.hackintosh.keycap.plist
```

## Microphone test

`microphone/mic-test.sh` is manual and has no launchd job. It needs the
`mic-test` helper, either compiled once from the source next to it or built
automatically on first run if `swiftc` is present:

```bash
cd tools/microphone
swiftc -O mic-test.swift -o mic-test      # once
bash mic-test.sh
```

Four numbered tests, Enter before each:

```
1)  quiet,       default volume
2)  make noise,  default volume
3)  quiet,       100% volume
4)  make noise,  100% volume
```

Each step reports RMS and peak dBFS; the summary prints a verdict and offers to
replay the last recording. WAV files stay in `~/Desktop/mic-test-<timestamp>/`.

On this laptop the microphone only produces a usable level at high input volume —
documented ALC236 behaviour, not a fault. Setup steps and the measured table are
in [Sonoma hardware support](../Sonoma/docs/hardware-support.md#microphone-setup--set-input-volume-near-max).

## Reading the results

- `history.log` — one line per boot: boot number, OpenCore version, decoded
  `backlight-level`, brightness node value, EDID entry count and root device.
- `boot-NNN-<timestamp>.log` — full graphics/backlight report with three samples.
- `seqdiag-<timestamp>.txt` — Bluetooth state plus the 60 s live log window.
- `i2cdiag-<osversion>.txt` — one file per macOS version, directly diffable.
- `keycap-<hhmmss>.txt` — HID/brightness events and the `bklt` value before and
  after the capture window.

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
`/Volumes/<target>` — nothing can be running there while it is not booted, so the
`launchctl` steps are unnecessary.

macOS's own unified logging, crash reports and diagnostics are untouched by any
of this.

## Where these come from

These scripts were written and run on this machine while bringing up Sequoia.
`graphics/hackdiag.sh`, `bluetooth/seqdiag.sh` and `touchpad/i2cdiag.sh` produced
the boot-time reports that the [Sequoia known issues](../Sequoia/docs/known-issues.md)
and [display backlight](../Sequoia/docs/display-backlight.md) notes are based on;
`keyboard/keycap.sh` confirmed that the brightness keys emit no HID event on
Sequoia, and `microphone/mic-test.sh` produced the input-volume measurements
behind the microphone notes on both installations.

For publication I replaced the hardcoded paths and private service labels with
the `DIAG_*` variables and `com.hackintosh.*` labels above. The capture commands
are unchanged from what ran on real hardware. These copies pass `bash -n` and
their plists pass `plutil -lint`, but they have not been run on a live install
since the reorganization, so treat the first deployment as a smoke test — a new
`history.log` line is enough to confirm a collector ran.
