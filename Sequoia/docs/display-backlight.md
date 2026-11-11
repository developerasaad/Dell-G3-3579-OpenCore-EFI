# Intel UHD 630 Display Backlight on Sequoia — Dell G3 3579

Why the internal panel goes black at boot on macOS Sequoia, why the brightness
keys stop working, and why the configuration here uses `-igfxblr`.

## Symptoms

| Configuration | Boot | Brightness keys |
|---------------|------|-----------------|
| `-igfxblt` (Sonoma's argument) | panel **black** | n/a — cannot test |
| `-igfxblr` (this EFI) | panel **bright** | **do not work** (no HUD, no change) |

Brightness via the slider / Control Center works with `-igfxblr`.

## Affected configuration

- Intel UHD Graphics 630 (`8086:3E9B`, Coffee Lake-H), eDP panel driven by the iGPU
- macOS Sequoia 15.8.2 (`AppleBacklight 180.12`)
- WhateverGreen backlight registers fixes

## Cause

macOS 15 (`AppleBacklight 180.12`) requires the WhateverGreen backlight-registers
fix to initialise the eDP backlight:

- `-igfxblt` — the *alternative* registers fix — works on Sonoma
  (`AppleBacklight 180.9`) but **does not initialise the panel** on Sequoia. The
  boot logo renders, then the panel goes dark as the kernel takes over.
- `-igfxblr` — the classic Backlight Registers Fix for KBL/CFL/ICL — lights the
  panel correctly.

The same registers fix that lights the panel also disables the ACPI brightness-key
path: `BrightnessKeys` performs its adjustment through the standard ACPI backlight
methods, which `-igfxblr` overrides. Measured with an in-boot sampler
(`AppleBacklightDisplay` → `bklt`): the value does not change on key press with
`-igfxblr`, on a panel that lights correctly.

## Firmware side (verified from the DSDT)

The Dell EC handles brightness through a single query method, `_Q66`, which routes
to `NEVT` and then to `\_SB.PCI0.LPCB.ECDV.VGBI.VBDS` — a vendor-specific brightness
method. The DSDT emits the standard ACPI Video-Extension notifications to the
display device:

```
Notify(\_SB.PCI0.GFX0.LCD_, 0x86)   // increase brightness
Notify(\_SB.PCI0.GFX0.LCD_, 0x87)   // decrease brightness
```

So the firmware does its part. The failure is in macOS 15's handling of those
notifications when the registers fix is active.

## Solution

Use `-igfxblr` and accept the brightness-key trade-off. Everything else that was
tested and rejected is documented below.

## Tested and rejected

| Change | Result |
|--------|--------|
| Full ACPI/kext parity with the working Sonoma EFI (`SSDT-ALSD`, `SMCLightSensor`, exact Sonoma boot-args) | panel still black with `-igfxblt`; keys still dead with `-igfxblr` |
| Aligning `com.apple.keyboard.fnState` with Sonoma | no effect on keys |
| `hidutil` remap of F11/F12 to brightness usages | no effect — the keys are ACPI EC events, not HID events |
| Re-enabling the USB map | fixed Bluetooth (unrelated), keys unaffected |

A manual `bklt` reading showed the driver value stays at its maximum while the
panel is dark — macOS requests full brightness and the hardware does not follow,
a register-path failure rather than a policy problem.

## Applicability to other systems

This applies to Coffee Lake laptops whose panel is driven by the iGPU and whose
EC handles brightness in firmware. The working argument depends on the macOS
release: `-igfxblt` was introduced for the 13.4 regression on CFL and still works
on Sonoma here; Sequoia needs `-igfxblr`. Other machines may differ — measure, do
not copy.

## References

- [WhateverGreen](https://github.com/acidanthera/WhateverGreen) — boot arguments
  `-igfxblr`, `-igfxblt`, `-igfxbls` and the Intel HD FAQ.
- [BrightnessKeys](https://github.com/acidanthera/BrightnessKeys) — ACPI
  brightness key handling.
