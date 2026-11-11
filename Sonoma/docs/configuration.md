# Configuration — macOS Sonoma

What each part of `EFI/OC/config.plist` does on this laptop. Shared background:
[hardware](../../docs/hardware-specifications.md) ·
[UHD 630](../../docs/intel-uhd-630.md) · [SMBIOS](../../docs/smbios.md).

## ACPI

| SSDT / patch | Purpose |
|--------------|---------|
| `SSDT-EC` | fake EC device |
| `SSDT-USBX` | USB power properties |
| `SSDT-PLUG` | XCPM CPU power management |
| `SSDT-PMC` | native NVRAM on 300-series |
| `SSDT-MCHC`, `SSDT-SBUS` | memory controller / SMBus |
| `SSDT-PNLF` + `PNLF → XNLF` rename | backlight device (required for the slider) |
| `SSDT-GPI0` + `GPI0 _STA → XSTA` | GPIO for the I2C touchpad |
| `SSDT-ALSD` + `ALSD _STA → XSTA` | ambient light sensor |
| `SSDT-XOSI` + `_OSI → XOSI`, `OSID → XSID` | OS detection shim |
| `SSDT-Disable_GPU_PEG0` | disables the NVIDIA GPU at `PEG0` |

The renames are required — without `PNLF → XNLF` the injected backlight device
never binds, and without `GPI0 _STA → XSTA` the touchpad conflicts with firmware.

## DeviceProperties

`PciRoot(0x0)/Pci(0x2,0x0)` (UHD 630):

```
AAPL,ig-platform-id      0x3EA50009
framebuffer-patch-enable 01000000
framebuffer-stolenmem    00003001
framebuffer-fbmem        00009000
AAPL00,override-no-connect  <panel EDID>
```

`PciRoot(0x0)/Pci(0x1f,0x3)` (HDA): `layout-id = 15` (ALC236).

## PlatformInfo

SMBIOS `MacBookPro15,2` with sample identity — see
[SMBIOS setup](../../docs/smbios.md). `UpdateSMBIOSMode = None` with
`CustomSMBIOSGuid = true`, so Windows on the same disk keeps the real Dell DMI.

## Kernel → Add

Lilu → VirtualSMC (+SMC plugins) → WhateverGreen → AppleALC → BrightnessKeys →
RestrictEvents → CtlnaAHCIPort → RealtekRTL8111 → AirportItlwm → Intel BT kexts →
USBToolBox/UTBMap → VoodooI2C(+plugins) → VoodooI2CHID → VoodooPS2Controller.

Note `CtlnaAHCIPort` — without it the SATA boot disk does not appear.

## NVRAM / boot-args

```
-igfxblt -cdfon -btlfxallowanyaddr -ibtallowanyaddr
```

`-igfxblt` is the Sonoma-appropriate backlight registers fix; it keeps both the
boot display and the brightness keys working.

## Security

`SecureBootModel = Disabled`, `Vault = Optional`, `ScanPolicy = 0`,
`csr-active-config = 030a0000`.
