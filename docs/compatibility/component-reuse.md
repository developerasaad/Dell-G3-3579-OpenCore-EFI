# Component Reuse on Other Machines

This repository targets the Dell G3 3579. Some parts are reusable on other
Hackintoshes; others are strictly machine-specific. This page classifies them so
you can adapt safely. **Sharing a CPU family does not make an EFI compatible.**

## Generally reusable (driver / kext level)

These work on any machine with the same *component*, independent of motherboard:

- **Lilu, VirtualSMC (+plugins), WhateverGreen, AppleALC, RestrictEvents** —
  standard Acidanthera stack.
- **VoodooPS2Controller** — any PS/2 keyboard.
- **VoodooI2C + VoodooI2CHID** — any I2C HID touchpad (but see ACPI below).
- **RealtekRTL8111** — any RTL8111/8168 Ethernet.
- **IntelBluetoothFirmware / IntelBTPatcher / BlueToolFixup** — Intel Bluetooth.
- **AirportItlwm / itlwm** — supported Intel Wi-Fi; pick the build for your macOS.
- **CtlnaAHCIPort** — unsupported Intel SATA AHCI controllers.

## OS-version-specific configuration

- **AirportItlwm build** must match the macOS release (2.3.0 Sonoma, 2.4.0 Sequoia).
- **Backlight boot-arg**: Sonoma uses `-igfxblt`; Sequoia needs `-igfxblr`
  (with the brightness-key trade-off). See each OS's configuration docs.
- **USB map necessity**: Sequoia requires the map for Bluetooth enumeration; both
  EFIs ship with `UTBMap` enabled.

## Motherboard-dependent ACPI (do not copy blindly)

These SSDTs/renames are tied to the Dell G3 3579 DSDT:

- `SSDT-PNLF` + `PNLF → XNLF` (backlight device)
- `SSDT-GPI0` + `GPI0 _STA → XSTA` (I2C GPIO)
- `SSDT-ALSD` + `ALSD _STA → XSTA` (ambient light)
- `SSDT-XOSI` + `_OSI → XOSI`, `OSID → XSID`
- `SSDT-Disable_GPU_PEG0` (NVIDIA disable)
- `SSDT-EC`, `SSDT-USBX`, `SSDT-PLUG`, `SSDT-PMC`, `SSDT-MCHC`, `SSDT-SBUS`

On another board, regenerate these from your own DSDT (e.g. with SSDTTime /
MaciASL). The *concepts* transfer; the exact patches do not.

## Device-specific injected properties

- `AAPL,ig-platform-id`, `framebuffer-*`, and the EDID override are specific to
  this panel/GPU. Re-derive for other displays.
- `layout-id 15` is specific to the ALC236 wiring here; other codecs/layouts differ.

## Machine-specific (never reuse)

- **`UTBMap.kext`** — a USB port map for this exact motherboard. Using it elsewhere
  will hide or mislabel ports. Generate your own with USBToolBox on the target
  machine (under Windows or macOS).
- **SMBIOS identity** — generate your own; see
  [SMBIOS and boot safety](../smbios.md).

## Rule of thumb

Reuse the *drivers*, re-derive the *ACPI and properties*, and regenerate the
*USB map and SMBIOS*. If a guide tells you to copy a whole EFI because "it's the
same CPU", treat that as a red flag.
