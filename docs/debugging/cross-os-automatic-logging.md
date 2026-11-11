# Cross-OS Automatic Logging

While bringing up Sequoia, its display stayed dark for several minutes after
login, which made it impractical to collect logs from a live session. The
workaround was to prepare the collectors in Sonoma, install them into the Sequoia
volume while it was mounted, and let launchd run them at Sequoia boot. The
reports land on the Sequoia volume and can be read back from Sonoma without
touching the broken display.

The ready-to-use scripts and their launchd jobs are in
[`tools/diagnostics/`](../../tools/diagnostics/README.md), with install,
configure and uninstall steps. Start there; this page only records the technique
and the two results it produced on this machine.

## The technique

- Prepare the scripts on a working macOS installation.
- Copy them to the target volume's `/usr/local/bin`, its `/Library/LaunchDaemons`
  (system domain) and the user's `Library/LaunchAgents` — all while the target
  volume is mounted.
- launchd scans those folders at the target's next boot, so the collectors run
  with no configuration needed inside the broken installation.

Two implementation details matter:

1. `log show` is unreliable in the first seconds after boot — `logd` is not
   ready — so the collectors use `log stream` with a timeout, which attaches
   immediately and records whatever arrives.
2. The daemons run as root, so they write their output where the user can read
   it (or chown it back), otherwise the files are only readable with sudo from
   the working system.

## What this found on the G3 3579

- `AppleBacklightDisplay` → `bklt` stayed at its maximum while macOS requested
  full brightness during the dark-screen period — the failure was in the
  backlight register path, not in brightness policy. See
  [Sequoia display backlight](../../Sequoia/docs/display-backlight.md).
- With the USB map disabled, the Intel Bluetooth device (XHCI port HS14) did not
  enumerate and `IntelBluetoothFirmware` never loaded. See
  [Sequoia known issues](../../Sequoia/docs/known-issues.md).
