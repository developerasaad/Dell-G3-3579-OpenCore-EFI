# Configuration — macOS Sequoia

What each part of `EFI/OC/config.plist` does on this laptop. Shared background:
[hardware](../../docs/hardware-specifications.md) ·
[UHD 630](../../docs/intel-uhd-630.md) · [SMBIOS](../../docs/smbios.md).

## ACPI

Same set as Sonoma — see [Sonoma configuration](../../Sonoma/docs/configuration.md)
for the table of SSDTs and renames. All of these are required on Sequoia too, in
particular:

- `SSDT-PNLF` + `PNLF → XNLF` rename (backlight device)
- `SSDT-GPI0` + `GPI0 _STA → XSTA` (I2C touchpad)
- `SSDT-ALSD` + `ALSD _STA → XSTA` (ambient light sensor)
- `SSDT-Disable_GPU_PEG0` (NVIDIA disable)

## DeviceProperties

Identical to Sonoma: `AAPL,ig-platform-id 0x3EA50009`, framebuffer
stolen/fbmem patches, and the panel EDID override on
`PciRoot(0x0)/Pci(0x2,0x0)`; `layout-id = 15` on the HDA device.

## PlatformInfo

SMBIOS `MacBookPro15,2` with sample identity — see
[SMBIOS setup](../../docs/smbios.md). Generate a **separate** identity for
Sequoia if you keep both installs.

## Kernel → Add

Same stack as Sonoma, with two differences:

- **AirportItlwm 2.4.0** (Sequoia build) instead of 2.3.0.
- No `RealtekCardReader` / `XHCI-unsupported` (the G3's SD reader is USB and
  needs neither).

`CtlnaAHCIPort` is required — without it the SATA boot disk does not appear.

## NVRAM / boot-args

```
-igfxblr -cdfon -btlfxallowanyaddr -ibtallowanyaddr
```

`-igfxblr` is required on Sequoia. Do **not** replace it with `-igfxblt`: that
leaves the panel black at boot (measured, see
[display backlight](display-backlight.md)).

## Security

`SecureBootModel = Disabled`, `Vault = Optional`, `ScanPolicy = 0`,
`csr-active-config = 030a0000`.
