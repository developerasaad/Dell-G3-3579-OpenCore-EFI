# Lid sleep / wake diagnostics

Temporary LaunchDaemon that records what happens when the lid closes and opens.
It is passive: it subscribes to a filtered unified-log stream and reads
`pmset`/`ioreg` state when a power event appears. It creates no power assertions
and changes no power settings, so it cannot keep the machine awake.

## What it records

| File | Contents |
|---|---|
| `baseline.txt` | state when the daemon started: boot time, clamshell, display power, backlight, battery/AC, assertions, Wi-Fi, input devices, recent `pmset` history |
| `events.log` | filtered stream: `PMRD:` kernel power messages, WindowServer display wake/sleep, `airportd` wake reason, `bluetoothd` wake, `corebrightnessd` backlight state, VoodooI2C/PS2 initialisation |
| `event-NNN-<hhmmss>.txt` | a state snapshot taken when a matched event appears (5 s minimum between snapshots) |
| `backfill-NNN.log` | 3-minute `log show` window around a wake, to recover messages the live stream missed while suspended |

Location: `/Library/Logs/lidwake/session-<timestamp>/`. The newest ten sessions
are kept; `events.log` is truncated to the last 20 000 lines past ~5 MB.

## What it cannot tell you

- The stream is suspended during sleep. Sleep-time events are reconstructed from
  `pmset` history and the wake backfill, not from a live process.
- Whether the panel actually showed an image, brightness came back, or the
  keyboard and touchpad responded — that is user-visible behaviour and has to be
  reported after the test.
- Lid state is read from `AppleClamshellState`. There is no separate “lid opened”
  event, so wake time is used as the close of the cycle.

## Install

Needs root; do it with approval.

```bash
sudo install -m 755 lidwake-collect.sh /usr/local/bin/lidwake-collect.sh
sudo install -m 644 com.hackintosh.lidwake.plist /Library/LaunchDaemons/
sudo launchctl bootstrap system /Library/LaunchDaemons/com.hackintosh.lidwake.plist
```

Check it started:

```bash
sudo launchctl print system/com.hackintosh.lidwake | head -20
ls -l /Library/Logs/lidwake/session-*/
```

## Run a test

1. Note the start time and keep the machine as you normally use it.
2. Close the lid for the agreed duration, then open it.
3. After wake, generate the report:

   ```bash
   bash lidwake-report.sh
   ```

4. Report what you actually saw: display on, brightness normal, keyboard and
   touchpad working, Wi-Fi back, audio working — and whether it rebooted.

## Reading the report

- `Entering Sleep state due to 'Clamshell Sleep'` — the lid triggered sleep.
- `Wake from Normal Sleep [..] : due to ...` — wake reason, with the time asleep.
- Snapshot with `AppleClamshellState = No`, `CurrentPowerState=4` and a `bklt`
  value means the display stack was up at the moment of capture. It is not proof
  that you saw an image.
- More than one boot time in the report means the machine rebooted.

## Uninstall

```bash
sudo launchctl bootout system/com.hackintosh.lidwake
sudo rm -f /Library/LaunchDaemons/com.hackintosh.lidwake.plist \
           /usr/local/bin/lidwake-collect.sh \
           /var/log/lidwake.out /var/log/lidwake.err
sudo rm -rf /Library/Logs/lidwake      # only after collecting the evidence
```

## Status — Sonoma

Installed on Sonoma 14.8.9 (23J631) and run through three instrumented lid cycles
(30 s, ~7 min, >10 min), on top of three earlier cycles already in `pmset`
history:

- Every cycle slept on `Clamshell Sleep` and woke on `PBTN/UserActivity`.
- Sleep entry was delayed after lid close — 16 s and 30 s (twice) — although the
  display went dark immediately.
- Wake to `displayDidWake`: 1.4 s; brightness restored at ~2.0 s; first window
  visible between 1.4 s and 2.2 s across the three cycles (the blank screen seen
  on wake).
- No reboot, no DarkWake between sleep and wake, trackpad events within ~4 s of
  wake.

A WindowServer coordinated-notification timeout and phantom display IDs
(`3f003d`–`3f0043`) appear in the wake window; both are non-fatal.

## Status — Sequoia

Sequoia 15.8.2 (24H232) was tested once with a 14 min lid sleep: it slept on
`Clamshell Sleep` and woke on `PBTN/UserActivity`, display awake 1.4 s after
wake, no reboot. Two differences from Sonoma:

- sleep entry was blocked for 14.8 s by `System sleep prevented by
  kPMCPUAssertion` (external USB media was mounted and the lid was closed 55 s
  after boot), then completed;
- the backlight returned at `52316` instead of `65403`.

Only one Sequoia cycle has been captured. Overnight sleep and other sleep
triggers are untested on both systems.
