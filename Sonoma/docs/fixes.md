# Fixes — macOS Sonoma

Verified solutions implemented in this EFI, each with the reason it exists.

## SATA boot disk not appearing

**Cause:** the SATA controller (`8086:A353`) is not natively supported by
`AppleAHCIPort`.

**Fix:** `CtlnaAHCIPort.kext` (341.0.2) in `Kernel/Add`.

Without it the installer cannot see the internal SSD at all.

## I2C touchpad conflict

**Cause:** the firmware's GPI0 GPIO controller claims the I2C device, so
VoodooI2C cannot bind.

**Fix:** `SSDT-GPI0` plus the `GPI0 _STA → XSTA` rename. Both are required — the
rename alone or the SSDT alone does nothing.

## Backlight device

**Cause:** the native backlight device (`PNLF`) conflicts with an injected one.

**Fix:** `SSDT-PNLF` plus the `PNLF → XNLF` rename. With both, the brightness
slider and keys work via `AppleBacklight`.

## NVIDIA GPU conflicts

**Cause:** the GTX 1050 (Pascal) has no macOS driver and would draw power and
interfere with the iGPU.

**Fix:** `SSDT-Disable_GPU_PEG0` disables the dGPU at `PEG0`. There is no need to
change BIOS settings for it.

## Audio layout

**Cause:** macOS picks a default layout that doesn't match the ALC236 wiring.

**Fix:** inject `layout-id = 15` on `PciRoot(0x0)/Pci(0x1f,0x3)`. Verified for
speakers, headphones and the internal microphone. The microphone only produces a
usable signal at high input volume (see
[hardware support](hardware-support.md)); layout 5 is **not** correct for this
codec.

## Dell sensors / EC

`SMCDellSensors` provides fan and EC data on Dells; loaded alongside the standard
VirtualSMC plugins.
