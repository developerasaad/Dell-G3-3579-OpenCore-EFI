# macOS Sequoia 15.8.2 — Dell G3 3579

OpenCore configuration for **macOS Sequoia 15.8.2 (24H232)** on the Dell G3 3579.

- **OpenCore:** 1.0.9 RELEASE (`REL-109-2026-11-08`)
- **SMBIOS:** `MacBookPro15,2` (sample identity — replace with your own for Apple services)
- **Status:** boot-tested on this laptop under macOS 15.8.2 (24H232) with
  OpenCore 1.0.9 RELEASE; SD reader, webcam (including its activity LED),
  microphone and lid sleep/wake verified working. Brightness keys are the main
  remaining limitation — see [known issues](docs/known-issues.md).
- **Tested vs. shipped config:** the boot-tested EFI has `Misc → Debug`
  disabled. This repository's copy is otherwise identical — same binaries,
  kexts and ACPI — but still carries the original debug flags, which are inert
  in a RELEASE build.

This EFI is macOS-only: on a multiboot machine, keep the existing `Microsoft/` and
vendor folders on your live EFI partition.

## Documentation

- [Installation](docs/installation.md)
- [Hardware support](docs/hardware-support.md)
- [Configuration](docs/configuration.md)
- [Fixes](docs/fixes.md)
- [Known issues](docs/known-issues.md)
- [Display backlight on Sequoia](docs/display-backlight.md)

Shared references: [hardware](../docs/hardware-specifications.md) ·
[UHD 630](../docs/intel-uhd-630.md) · [kexts](../docs/kext-reference.md) ·
[BIOS](../docs/bios-reference.md) · [SMBIOS](../docs/smbios.md)

Beyond this machine: [similar laptops](../docs/compatibility/similar-laptops.md) ·
[component reuse](../docs/compatibility/component-reuse.md).

## How Sequoia differs from Sonoma

- **Backlight boot argument:** Sequoia needs `-igfxblr`; `-igfxblt` (used on
  Sonoma) leaves the panel black. See
  [display backlight](docs/display-backlight.md).
- **Wi-Fi kext build:** AirportItlwm 2.4.0 instead of 2.3.0.
- **USB map required:** Bluetooth does not enumerate without it. On Sonoma this
  is optional.
- Everything else (ACPI, kext stack, framebuffer, audio layout) matches Sonoma.

## Key boot arguments

```
-igfxblr -cdfon -btlfxallowanyaddr -ibtallowanyaddr
```

## Before you boot

Generate your own SMBIOS identity and review the USB map and framebuffer. See
[SMBIOS setup](../docs/smbios.md).
