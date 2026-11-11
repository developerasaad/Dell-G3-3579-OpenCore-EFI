# Known Issues — macOS Sonoma

Current limitations on the Dell G3 3579.

## NVIDIA GTX 1050 — unsupported

Pascal has no macOS driver (web drivers stopped at High Sierra, and the internal
panel is wired to the iGPU anyway). The GPU is disabled with `SSDT-Disable_GPU_PEG0`
to save power. Use Windows for the dGPU.

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

## Features not verified

The following have not been tested and should be assumed unknown rather than
broken: sleep/wake, HDMI output, microphone, webcam video capture, SD reader.

## Microphone

Not verified. The codec is ALC236 (layout 15); internal mic behaviour is untested
on this configuration.

## SD reader

The reader is a **USB** Realtek (`0BDA:0129`), not PCIe — `RealtekCardReader.kext`
is not required and is not included in this EFI.

## Boot safety

If the machine fails to boot after an EFI change, recover by booting a USB
OpenCore stick or restoring the previous EFI. Always back up before changing the
EFI partition.
