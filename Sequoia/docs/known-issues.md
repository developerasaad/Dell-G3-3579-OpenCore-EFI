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

If a future WhateverGreen or BrightnessKeys release resolves this, verify with a
brightness measurement (`AppleBacklightDisplay` → `bklt`) before committing.

## HDMI output does not work

Connecting an external display over HDMI produces no image: macOS detects no
external display (`system_profiler SPDisplaysDataType` shows only the internal
eDP panel).

The HDMI port on the G3 3579 is wired to the NVIDIA dGPU, which is disabled
(`SSDT-Disable_GPU_PEG0`) and unsupported (Pascal has no macOS driver). This is
the same Optimus design that keeps the internal panel on the iGPU, so no
framebuffer patch can enable it.

**Workaround:** use the HDMI port under Windows, where the GTX 1050 has full
driver support.

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

Sleep/wake is untested on this OS. Assume unknown rather than broken. Webcam
video, the microphone and the SD reader are verified working (see
[hardware support](hardware-support.md)); HDMI output is verified not working
(dGPU-wired).

## Boot safety

If the machine fails to boot after an EFI change, recover by booting a USB
OpenCore stick or restoring the previous EFI. Back up before changing the EFI
partition.
