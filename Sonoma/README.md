# macOS Sonoma 14 — Dell G3 3579

OpenCore configuration for **macOS Sonoma 14.8.9 (23J631)** on the Dell G3 3579.

- **OpenCore:** 1.0.8
- **SMBIOS:** `MacBookPro15,2` (sample identity — replace with your own for Apple services)
- **Status:** boot-tested; this is the daily-driver configuration on the laptop

This EFI is macOS-only: on a multiboot machine, keep the existing `Microsoft/` and
vendor folders on your live EFI partition.

## Documentation

- [Installation](docs/installation.md)
- [Hardware support](docs/hardware-support.md)
- [Configuration](docs/configuration.md)
- [Fixes](docs/fixes.md)
- [Known issues](docs/known-issues.md)

Shared references: [hardware](../docs/hardware-specifications.md) ·
[UHD 630](../docs/intel-uhd-630.md) · [kexts](../docs/kext-reference.md) ·
[BIOS](../docs/bios-reference.md) · [SMBIOS/safety](../docs/smbios.md)

## Feature summary

Working: Intel graphics acceleration, internal display, brightness (slider and
keys), keyboard, touchpad, audio, Wi-Fi, Bluetooth, Ethernet, USB.
Not working: NVIDIA GTX 1050 (disabled, unsupported).
Untested: sleep/wake, HDMI, webcam, SD reader, microphone.

See [hardware support](docs/hardware-support.md) for the full table.

## Key boot arguments

```
-igfxblt -cdfon -btlfxallowanyaddr -ibtallowanyaddr
```

`-igfxblt` is the backlight registers fix that works on Sonoma and keeps the
brightness keys functional. (Sequoia needs a different argument — do not copy
this EFI to Sequoia.)

## Before you boot

Generate your own SMBIOS identity and review the USB map and framebuffer.
See [SMBIOS and boot safety](../docs/smbios.md).
