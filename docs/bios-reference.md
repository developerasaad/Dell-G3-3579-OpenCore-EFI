# Dell G3 3579 — BIOS Reference

Settings verified on the reference machine (BIOS 1.25.0). Apply these before
installing either macOS version.

## Required

| Setting | Value | Reason |
|---------|-------|--------|
| Boot mode | UEFI | OpenCore is UEFI-only |
| Secure Boot | **Disabled** | OpenCore is not signed by Microsoft/Apple |
| SATA operation | AHCI | macOS needs AHCI, not RAID/RST |
| Fast Boot | Disabled (recommended) | ensures USB/EFI enumeration |

## Recommended

| Setting | Value | Reason |
|---------|-------|--------|
| VT-d | Disabled, or use `DisableIoMapper` | avoids IOMMU conflicts |
| CFG Lock | Disabled, or use `AppleXcpmCfgLock` | required for CPU power management |
| Legacy Option ROMs | Disabled | pure UEFI boot |
| Wake on LAN | Disabled | avoids sleep issues |

## Notes

- The reference config uses the `AppleXcpmCfgLock` and `DisableIoMapper` quirks, so
  it tolerates CFG Lock / VT-d being enabled. Disabling them in BIOS is cleaner.
- The NVIDIA GPU can be left enabled in BIOS; macOS disables it via
  `SSDT-Disable_GPU_PEG0`. There is no need to change a "discrete graphics" BIOS
  option for macOS.
- BIOS version differences can change ACPI layout. If your BIOS is not 1.25.0,
  re-verify the ACPI patches (especially `PNLF`, `GPI0`, `_OSI`) against your DSDT.
