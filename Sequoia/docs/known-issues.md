# Known Issues — macOS Sequoia

Current limitations on the Dell G3 3579, verified by testing.

## Brightness keys do not work

F11/F12 and Fn+F11/Fn+F12 produce no brightness change and no HUD. The brightness
slider works normally.

This is a **trade-off of the boot-backlight fix**: `-igfxblr` lights the panel at
boot but disables the ACPI brightness-key path. Switching to `-igfxblt` keeps the
ACPI path intact but leaves the panel black at boot. Measured and documented in
[display backlight](display-backlight.md).

**Workaround:** adjust brightness with the slider or Control Center.

If a future WhateverGreen or BrightnessKeys release resolves this, test it with a
brightness measurement (`AppleBacklightDisplay` → `bklt`) before committing — see
[known limitations](#known-limitations-of-static-testing).

## SD reader does not work

The internal SD reader is a Realtek RTS **PCIe** controller that needs
`RealtekCardReader.kext` (0.9.7). That kext is present in the Sonoma EFI but is
**missing from this Sequoia EFI**, so inserted cards do not mount.

Fixing it requires adding `RealtekCardReader.kext` to `EFI/OC/Kexts` and to
`Kernel/Add` — but verify its Sequoia compatibility first; version 0.9.7 is
tested on Sonoma only.

## NVIDIA GTX 1050 — unsupported

Pascal has no macOS driver and the internal panel is wired to the iGPU, so the
dGPU cannot be used for the internal display at all. Disabled via
`SSDT-Disable_GPU_PEG0`.

## Touchpad feel

The input pipeline is identical to Sonoma (same driver binding, same 125 Hz
report rate), but the pointer feels less fluid on Sequoia. That is Sequoia's
compositor on UHD 630, not the trackpad. Try Reduce Transparency / Reduce Motion
in Accessibility settings.

## Features not verified

Sleep/wake, HDMI output, microphone, webcam capture, and the SD reader are
untested. Assume unknown rather than broken.

## Boot safety

If the machine fails to boot after an EFI change, recover by booting a USB
OpenCore stick or restoring the previous EFI. Back up before changing the EFI
partition.
