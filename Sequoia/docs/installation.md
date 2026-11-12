# Installing macOS Sequoia 15.8.2 — Dell G3 3579

This guide is for **Sequoia only**. For Sonoma, use
[Sonoma installation](../../Sonoma/docs/installation.md).

The EFI in this repository is tested with **macOS Sequoia 15.8.2 (24H232)** on
this laptop. There are two ways to prepare the installer; pick one before you
touch the USB.

| | Online Recovery | Full offline installer |
|---|---|---|
| Initial download | small recovery image | many GB |
| Internet during installation | required | only for later setup and updates |
| Version installed | whatever Apple currently serves (usually the newest 15.x) | the exact build of the installer you keep |
| Repeat installs | download the recovery image again | reuse the same installer |
| Good for | first install, little storage | reproducing a build, avoiding repeated downloads |

The tested installation on this laptop used the **full installer**. Recovery is
supported and works the same way, but it will not necessarily give you 15.8.2 —
it serves whatever Sequoia build Apple currently offers for the board ID.

## Before you start

- BIOS settings: [BIOS reference](../../docs/bios-reference.md)
- The Sequoia EFI: [Dell-G3-3579-Sequoia-15.8.2-EFI.zip](https://github.com/developerasaad/Dell-G3-3579-Hackintosh/releases/download/v1.0.0/Dell-G3-3579-Sequoia-15.8.2-EFI.zip) or `Sequoia/EFI` in the repository — **keep `-igfxblr` in boot-args**, or the panel stays black ([display backlight](display-backlight.md))
- Your own SMBIOS identity: [SMBIOS setup](../../docs/smbios.md)
- A backup of the current EFI and a way to boot without the internal disk
- USB: 4 GB or more for Recovery, 16 GB or more for the full installer

## Option A — Online Recovery

Recovery boots a small image fetched from Apple and downloads the rest of macOS
while it installs. It therefore needs working internet **inside the installer** —
check that Wi-Fi or Ethernet works there before committing to this route. If
neither does, use the full installer instead.

1. Get `macrecovery.py` from `Utilities/macrecovery/` in OpenCorePkg and run it
   for the current release:

   ```bash
   python3 macrecovery.py -b Mac-937A206F2EE63C01 -m 00000000000000000 download
   ```

   On Windows use `py` instead of `python3`. That board ID is Dortania's “latest
   version” entry; confirmation and the full list are in
   [the installer guide](https://dortania.github.io/OpenCore-Install-Guide/installer-guide/mac-install.html#downloading-macos).

2. The script writes `BaseSystem.dmg` with its `.chunklist` (or
   `RecoveryImage.*`). That is the boot image only — much smaller than a full
   macOS installer.

3. Format the USB as MS-DOS (FAT32) with a GUID partition map. Create a folder
   named `com.apple.recovery.boot` at the root and copy both downloaded files
   into it.

4. Copy the `EFI` folder from this repository to the USB root as well, so the
   root contains `EFI/` and `com.apple.recovery.boot/`.

5. Boot from the USB (F12 → UEFI USB), select the recovery entry, and install.

The Sequoia build you end up with is whatever Apple currently serves; it may be
newer than 15.8.2. If you specifically need 15.8.2, use Option B with a full
installer of that build.

## Option B — Full offline installer

A full installer is a complete copy of macOS that can be written to a USB stick
and kept for later. It is the only way to reproduce an exact build.

1. Obtain the installer from Apple: [download macOS](https://support.apple.com/en-in/101578).
   On a compatible Mac, `softwareupdate --fetch-full-installer` is another route,
   but it does not offer every version on every host — check what it lists before
   relying on it.

2. Depending on the source you get either `Install macOS Sequoia.app` directly or
   an `InstallAssistant.pkg` that installs that app into `/Applications` when
   opened. Both end up as the same application.

3. Write it to the USB with Apple's tool
   ([create a bootable installer](https://support.apple.com/en-in/102662)):

   ```bash
   sudo /Applications/Install\ macOS\ Sequoia.app/Contents/Resources/createinstallmedia \
        --volume /Volumes/MyUSB
   ```

   Use a 16 GB or larger stick formatted Mac OS Extended (Journaled) with a GUID
   partition map. `createinstallmedia` refuses APFS targets and erases the volume
   it is given.

4. Mount the USB's EFI partition and copy this repository's `EFI` folder into it
   as `EFI/`.

5. Boot from the USB and install.

I keep a full installer on a separate drive. OpenCore experiments, macOS updates
and failed boots can mean reinstalling more than once, and downloading many
gigabytes again each time is wasteful — a local copy makes a reinstall much
quicker. It is optional, not a requirement.

"Offline" refers to the installer only: signing in, iCloud and updates still use
the network after installation.

## Booting the installer

- Boot from the USB (F12 → UEFI USB).
- In OpenCore, choose the macOS installer entry.
- If the screen goes dark during boot, press `Fn+Insert` to toggle the display —
  see [display backlight](display-backlight.md).
- If the installer hangs at `still waiting for root device`, the USB stick is on a
  port that `UTBMap.kext` prunes. Disable `UTBMap` in `Kernel → Add` for the
  installation and re-enable it afterwards; Bluetooth needs it to enumerate. See
  [fixes](fixes.md).
- If you install alongside another OS, select the correct target volume in Disk
  Utility and back up first. Do not erase a volume you need.

## Installing

The installer reboots several times. Boot from the USB each time and select the
“macOS Installer” or target-volume entry until setup completes.

## Making it boot without the USB

Copy the personalized `EFI/` to the internal disk's EFI partition. Keep a backup
of the previous EFI, and on a multiboot disk preserve the existing `Microsoft/`
and vendor folders.

## If it fails to boot

Boot the USB OpenCore stick or restore the previous EFI. See
[known issues](known-issues.md).
