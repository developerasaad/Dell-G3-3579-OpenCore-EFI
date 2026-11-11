# Known Issues — macOS Sonoma

Current limitations on the Dell G3 3579, verified by testing.

## NVIDIA GTX 1050 — unsupported

Pascal has no macOS driver (NVIDIA web drivers stopped at High Sierra), and the
internal panel is wired to the iGPU anyway, so the dGPU cannot drive any display.
It is disabled with `SSDT-Disable_GPU_PEG0` to save power. Use Windows for the
dGPU.

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

## Sleep / wake — untested

Not tested. Assume unknown rather than working.

## Boot safety

If the machine fails to boot after an EFI change, recover by booting a USB
OpenCore stick or restoring the previous EFI. Always back up before changing the
EFI partition.
