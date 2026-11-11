# Installing macOS Sequoia 15 — Dell G3 3579

This guide is for **Sequoia only**. For Sonoma, use
[Sonoma installation](../../Sonoma/docs/installation.md).

## Prerequisites

- Dell G3 3579 with the BIOS settings in [BIOS reference](../../docs/bios-reference.md).
- A USB drive (16 GB+) for the installer.
- The `Sequoia/EFI` from this repository — **it must keep `-igfxblr` in
  boot-args**, otherwise the panel stays black (see
  [display backlight](display-backlight.md)).
- Your own SMBIOS identity ([SMBIOS setup](../../docs/smbios.md)).
- A backup of any existing EFI and a recovery bootloader.

## 1. Prepare the installer

```
sudo /Applications/Install\ macOS\ Sequoia.app/Contents/Resources/createinstallmedia \
     --volume /Volumes/MyUSB
```

Format the USB as Mac OS Extended (Journaled) / GUID first; `createinstallmedia`
refuses APFS targets.

## 2. Put the EFI on the installer USB

Mount the USB's EFI partition and copy `Sequoia/EFI` into it as `EFI/`. Edit
`EFI/OC/config.plist` → `PlatformInfo/Generic` with your generated identity.

## 3. Boot the installer

- Boot from the USB (F12 → UEFI USB).
- Choose the macOS installer in OpenCore.
- If installing alongside an existing OS, select the correct target volume in
  Disk Utility and back up first.

## 4. Install and reboot

The installer reboots several times. Boot from the USB each time and select the
"macOS Installer" / target volume entry.

If the screen goes dark during these boots, press `Fn+Insert` to toggle the
display (see [display backlight](display-backlight.md)).

## 5. Make it boot without the USB

Copy the (personalized) `EFI/` to the internal disk's EFI partition, keeping a
backup of the previous EFI. On a multiboot disk, preserve the existing
`Microsoft/` and vendor folders.

## Recovery

If it fails to boot, use your recovery USB or the previous EFI. See
[known issues](known-issues.md).
