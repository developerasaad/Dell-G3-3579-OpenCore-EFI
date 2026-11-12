# Intel UHD 630 (Coffee Lake) — Graphics Reference

Shared reference for the integrated GPU. OS-specific framebuffer/backlight
settings live in each OS's `docs/configuration.md` and, for Sequoia,
`Sequoia/docs/display-backlight.md`. Platform-level reuse (laptop versus
desktop, what transfers) is covered in [Coffee Lake](compatibility/coffee-lake.md).

## Device

- Intel UHD Graphics 630, PCI `8086:3E9B` (Coffee Lake-H).
- Driven by `WhateverGreen` + `Lilu`; macOS native `AppleIntelCFLGraphicsFramebuffer`.
- Metal 3 capable; hardware acceleration works on Sonoma and Sequoia.

## Framebuffer

This configuration injects, on `PciRoot(0x0)/Pci(0x2,0x0)`:

| Property | Value | Purpose |
|----------|-------|---------|
| `AAPL,ig-platform-id` | `0x3EA50009` (`0900A53E` LE) | Coffee Lake mobile framebuffer |
| `framebuffer-patch-enable` | `01000000` | enable framebuffer patching |
| `framebuffer-stolenmem` | `00003001` | 19 MB stolen memory |
| `framebuffer-fbmem` | `00009000` | 9 MB framebuffer memory |
| `AAPL00,override-no-connect` | panel EDID | force the internal panel's EDID |

The stolen/fbmem values compensate for the BIOS DVMT pre-allocated memory being
too small for the macOS framebuffer. The EDID override pins the internal panel's
timings.

> These are **device-specific injected properties**. Another laptop with UHD 630
> may need a different `ig-platform-id`, connector layout, or EDID. Do not copy
> them blindly because the GPU family matches.

## Backlight

Backlight behaviour differs by macOS version and is the main Sonoma/Sequoia
difference:

- Sonoma: `-igfxblt` (alternative backlight registers fix) works; brightness keys
  function.
- Sequoia: `-igfxblt` leaves the panel black at boot; `-igfxblr` (backlight
  registers fix) lights the panel but disables the ACPI brightness-key path.
  See [Sequoia display-backlight](../Sequoia/docs/display-backlight.md).

Both rely on `SSDT-PNLF` plus the `PNLF → XNLF` ACPI rename so the injected
backlight device binds.

## NVIDIA discrete GPU

The GTX 1050 (Pascal) has no macOS driver. It is disabled with
`SSDT-Disable_GPU_PEG0` to avoid power drain and conflicts. It cannot be used for
acceleration or, where HDMI is wired to it, for external display output.

## Upstream

- [WhateverGreen](https://github.com/acidanthera/WhateverGreen) — framebuffer and
  backlight patching; see its Intel HD FAQ for the registers-fix boot arguments.
- [Lilu](https://github.com/acidanthera/Lilu) — patching framework.
