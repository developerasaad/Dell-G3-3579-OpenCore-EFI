# Installing macOS Sonoma 14 — Dell G3 3579

This guide is for **Sonoma only**. For Sequoia, use
[Sequoia installation](../../Sequoia/docs/installation.md).

## Prerequisites

- Dell G3 3579 with the BIOS settings in [BIOS reference](../../docs/bios-reference.md).
- A USB drive (16 GB+) for the installer.
- The `Sonoma/EFI` from this repository.
- Your own SMBIOS identity ([SMBIOS and boot safety](../../docs/smbios.md)).
- A backup of any existing EFI, and a recovery bootloader.

## 1. Prepare the installer

On a Mac (or existing Hackintosh):

```
# download the Sonoma installer, then:
sudo /Applications/Install\ macOS\ Sonoma.app/Contents/Resources/createinstallmedia \
     --volume /Volumes/MyUSB
```

The USB must be formatted Mac OS Extended (Journaled) / GUID before running
`createinstallmedia`; it refuses APFS targets.

## 2. Put the EFI on the installer USB

Mount the USB's EFI partition and copy `Sonoma/EFI` into it as `EFI/`.
Edit `EFI/OC/config.plist` → `PlatformInfo/Generic` with your generated identity.

## 3. Boot the installer

- Boot from the USB (F12 → UEFI USB).
- In OpenCore, choose the macOS installer.
- If installing alongside an existing OS, **select the correct target volume** in
  Disk Utility. Back up first; do not erase a volume you need.

## 4. Install and reboot

The installer reboots several times. Each time, boot from the USB and select the
"macOS Installer" / target volume entry until setup completes.

## 5. Make it boot without the USB

Copy the (personalized) `EFI/` to the internal disk's EFI partition. Keep a backup
of the previous EFI. On a multiboot disk, preserve the existing `Microsoft/` and
vendor folders.

## Recovery

If it fails to boot, boot from your recovery USB / previous EFI. See
[troubleshooting in known issues](known-issues.md).
