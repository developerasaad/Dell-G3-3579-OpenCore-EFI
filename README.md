# Dell G3 3579 Hackintosh — OpenCore EFI for macOS Sonoma 14.8.9 and Sequoia 15.8.2

OpenCore EFI configurations for the **Dell G3 3579** (Intel Coffee Lake,
i5-8300H / UHD 630), tested on this laptop. Each macOS version has its own
complete EFI and its own documentation; the two are not interchangeable.

The repository also carries reference material that applies beyond this
machine: Coffee Lake and UHD 630 notes, I2C touchpad and SD reader details, a
list of similar 2018 laptops, and the diagnostic tools used to bring Sequoia up.

| OS | Tested build | EFI |
|---|---|---|
| macOS Sonoma 14.8.9 | `23J631` | [`Sonoma/`](Sonoma/README.md) — OpenCore 1.0.8 RELEASE |
| macOS Sequoia 15.8.2 | `24H232` | [`Sequoia/`](Sequoia/README.md) — OpenCore 1.0.9 RELEASE |

No other macOS release has been tested. Do not read "Sonoma 14" or "Sequoia 15"
as a claim about every patch release.

## Hardware

- Dell G3 3579, Intel HM370, BIOS 1.25.0
- Intel Core i5-8300H (Coffee Lake-H, 4C/8T), 8 GB RAM
- Intel UHD Graphics 630 (`8086:3E9B`) — internal display (eDP, 1920×1080)
- NVIDIA GeForce GTX 1050 (Pascal, `10DE:1C8D`) — unsupported, disabled in macOS
- Realtek ALC236 audio · Intel Wireless-AC 9462 Wi-Fi · Intel Bluetooth (USB)
- Realtek RTL8111 Ethernet · I2C HID touchpad · PS/2 keyboard
- SATA SSD (Intel `8086:A353`) · Realtek RTS PCIe SD reader

Full details: [hardware specifications](docs/hardware-specifications.md).

## Compatibility

| Feature | Sonoma | Sequoia |
|---------|--------|---------|
| Intel graphics acceleration | Working | Working |
| Internal display / brightness slider | Working | Working |
| Brightness keys | Working | Not working |
| Keyboard / volume keys | Working | Working |
| Touchpad | Working | Working |
| Audio | Working | Working |
| Microphone | Working (input-volume quirk) | Working (input-volume quirk) |
| Wi-Fi / Bluetooth | Working | Working |
| Ethernet | Working | Working |
| NVIDIA GTX 1050 | Not working | Not working |
| Sleep / wake | Untested | Untested |
| Webcam (incl. activity LED) | Working | Working |
| HDMI output | Not working | wired to the disabled NVIDIA dGPU (verified: no external display detected) |
| SD reader | Working | Working |

Per-OS detail: [Sonoma](Sonoma/docs/hardware-support.md) ·
[Sequoia](Sequoia/docs/hardware-support.md).

## Beyond this laptop

- [Similar laptops](docs/compatibility/similar-laptops.md) — 2018 Coffee Lake-H
  machines that share the platform, and what does or does not transfer.
- [Intel Coffee Lake](docs/compatibility/coffee-lake.md) — laptop versus desktop,
  what is reusable.
- [Component reuse](docs/compatibility/component-reuse.md) — drivers versus
  machine-specific ACPI and maps.
- Component notes: [input](docs/components/input.md) ·
  [audio](docs/components/audio.md) ·
  [networking](docs/components/networking.md) ·
  [SD reader](docs/components/sd-reader.md) ·
  [USB mapping](docs/components/usb-mapping.md)

Only the G3 3579 rows have been boot-tested. Everything else is hardware
overlap, not a compatibility claim.

## Documentation

- [Hardware specifications](docs/hardware-specifications.md)
- [Intel UHD 630](docs/intel-uhd-630.md)
- [Kext reference](docs/kext-reference.md)
- [BIOS reference](docs/bios-reference.md)
- [SMBIOS setup](docs/smbios.md)
- [Development and debugging](docs/development.md)
- [Diagnostic tools](tools/README.md) — optional boot-time collectors and a
  guided microphone test

Installation is per OS: [Sonoma](Sonoma/docs/installation.md) ·
[Sequoia](Sequoia/docs/installation.md).

## Credits

[Acidanthera OpenCore](https://github.com/acidanthera/OpenCorePkg) and the
Acidanthera kexts (Lilu, WhateverGreen, VirtualSMC, AppleALC, BrightnessKeys,
RestrictEvents), [VoodooI2C](https://github.com/VoodooI2C/VoodooI2C),
[VoodooPS2](https://github.com/acidanthera/VoodooPS2),
[OpenIntelWireless](https://github.com/OpenIntelWireless/itlwm),
[USBToolBox](https://github.com/USBToolBox/kext),
[RealtekRTL8111](https://github.com/Mieze/RTL8111_driver_for_OS_X) and
[RealtekCardReader](https://github.com/0xFireWolf/RealtekCardReader).
Per-kext details: [kext reference](docs/kext-reference.md).

## License

Original documentation is released under the MIT license (see `LICENSE`).
The included kexts, ACPI binaries and OpenCore keep their own licenses — see
[kext reference](docs/kext-reference.md).

## Disclaimer

Hackintoshing is not supported by Apple and violates the macOS EULA. These EFIs
are provided as-is for educational use. They are specific to this hardware; if
you adapt them, verify everything on your own machine.
