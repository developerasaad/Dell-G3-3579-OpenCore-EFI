# Fixes — macOS Sequoia

Verified solutions implemented in this EFI. Shared background:
[UHD 630](../../docs/intel-uhd-630.md).

## Panel black at boot (backlight not initialised)

**Cause:** macOS 15 requires the WhateverGreen Backlight Registers Fix
(`-igfxblr`) to initialise the eDP backlight on Coffee Lake. `-igfxblt` — which
works on Sonoma — does not initialise the panel on 15.

**Fix:** use `-igfxblr` in boot-args. Details and measurements:
[display backlight](display-backlight.md).

## Bluetooth not detected

**Cause:** with the USB map disabled, the Intel Bluetooth device (on XHCI port
HS14) does not enumerate, so `IntelBluetoothFirmware` never loads and macOS
reports a placeholder controller.

**Fix:** keep `UTBMap.kext` enabled. During installation the map had to be
disabled because the installer drive sat on a port the map pruned (causing
"still waiting for root device"); re-enable it after installing. The boot drive
must be on a port the map declares.

## Touchpad conflict

**Cause:** the firmware's GPI0 GPIO controller claims the I2C device.

**Fix:** `SSDT-GPI0` plus the `GPI0 _STA → XSTA` rename — identical to Sonoma.

## SATA boot disk not appearing

**Cause:** the SATA controller (`8086:A353`) is not natively supported.

**Fix:** `CtlnaAHCIPort.kext` — required, or the installer cannot see the SSD.

## Backlight device

**Fix:** `SSDT-PNLF` plus the `PNLF → XNLF` rename. Both required for the
slider to work.

## Audio layout

**Fix:** inject `layout-id = 15` on the HDA device (ALC236). Verified for
speakers and headphones; the internal microphone is Sonoma-verified only (see
[Sonoma hardware support](../../Sonoma/docs/hardware-support.md)).
