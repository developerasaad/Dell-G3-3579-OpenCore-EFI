# Intel Coffee Lake

This repository is built around an **8th-generation Coffee Lake-H** laptop:
Intel Core i5-8300H, HM370 chipset, UHD Graphics 630. The CPU and platform
material here transfers to other Coffee Lake machines only at the level of
configuration method and driver stack.

## The two Coffee Lake families

| | Coffee Lake-H (this laptop) | Coffee Lake-S (desktop) |
|---|---|---|
| Example CPUs | i5-8300H, i7-8750H | i5-8400, i5-8600K, i7-8700, i7-8700K |
| Graphics | UHD 630 (`8086:3E9B`) | UHD 630 (`8086:3E9B`) |
| Chipset | HM370 | Z370, B360, H370, Z390 |
| Display | internal eDP panel, backlight control | external monitor, no backlight |
| Typical SMBIOS | `MacBookPro15,2` (here) | `iMac19,1` / `iMac18,3` |

Same CPU generation and the same iGPU device ID, but not the same machine. An
EFI that boots a Coffee Lake desktop will not boot this laptop, and the reverse
is also true.

## What is reusable

- **CPU power management** — `SSDT-PLUG` (plugin-type = 1 on the first CPU
  thread) plus `AppleXcpmCfgLock` for locked CFG. The same approach applies to
  both families; see [configuration](../../Sonoma/docs/configuration.md).
- **Graphics stack** — Lilu + WhateverGreen with the framebuffer properties
  described in [UHD 630](../intel-uhd-630.md). The driver side is identical;
  the injected values are not.
- **Kext order** — Lilu first, VirtualSMC and its plugins, then WhateverGreen,
  AppleALC and the rest. The order is in each OS's configuration page.

## What is not reusable

- **`AAPL,ig-platform-id`** — this laptop uses the mobile `0x3EA50009`. Desktop
  boards normally use `0x3EA50000` (the default) or `0x3E9B0007`; the mobile ID
  has no meaning on a desktop connector layout. Copying it is the usual reason a
  desktop build ends up with a black screen or no acceleration.
- **`AAPL00,override-no-connect`** — that 128-byte value is the EDID of *this*
  panel (`LGD053F`). It is meaningless on any other display.
- **Backlight** — `SSDT-PNLF`, the `PNLF → XNLF` rename and the
  `-igfxblr`/`-igfxblt` arguments exist because this is a laptop panel driven by
  the iGPU. A desktop has no backlight device and should not carry any of it.
- **Battery, EC and sensors** — `SSDT-EC`, `SSDT-USBX`,
  `SMCBatteryManager`/`SMCDellSensors` and the `_STA` renames are laptop-specific.
- **USB map** — see [USB mapping](../components/usb-mapping.md).

## HEDT and Xeon note

Coffee Lake-W/Xeon E parts are a different platform with different power
management and no UHD 630. Nothing on this page applies to them.

## Where to start for another Coffee Lake machine

1. Build the EFI from the OpenCore guide for your exact platform.
2. Reuse the kext stack from [kext reference](../kext-reference.md), choosing
   the Wi-Fi build that matches your macOS version.
3. Derive the framebuffer from your own panel or monitor — do not copy this one.
4. Generate a USB map on the target machine.
5. Replace the SMBIOS identity with one that matches your hardware class; see
   [SMBIOS](../smbios.md).

The UHD 630 specifics, including the laptop-versus-desktop differences in more
detail, are in [UHD 630](../intel-uhd-630.md).
