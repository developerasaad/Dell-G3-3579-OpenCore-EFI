# Dell G3 3579 Hackintosh

OpenCore EFI configurations for the **Dell G3 3579** (Intel Coffee Lake,
i5-8300H / UHD 630), covering **macOS Sonoma 14** and **macOS Sequoia 15**.

Each macOS version has its own complete EFI and its own documentation. The two
are not interchangeable: Sequoia needs a different graphics backlight argument,
and its Bluetooth depends on the USB map being loaded.

| OS | Directory |
|----|-----------|
| macOS Sonoma 14.8.9 (23J631) | [`Sonoma/`](Sonoma/README.md) |
| macOS Sequoia 15.8.2 (24H232) | [`Sequoia/`](Sequoia/README.md) |

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

Per-OS details: [Sonoma](Sonoma/docs/hardware-support.md) ·
[Sequoia](Sequoia/docs/hardware-support.md).

## Shared references

- [Hardware specifications](docs/hardware-specifications.md)
- [Intel UHD 630](docs/intel-uhd-630.md)
- [Component reuse on other machines](docs/component-reuse.md)
- [Kext reference](docs/kext-reference.md)
- [BIOS reference](docs/bios-reference.md)
- [SMBIOS setup](docs/smbios.md)
- [Development and debugging](docs/development.md)
- [Diagnostic tools](tools/README.md) — optional boot-time collectors
  and a guided microphone test

## Credits

[Acidanthera OpenCore](https://github.com/acidanthera/OpenCorePkg) and the
Acidanthera kexts (Lilu, WhateverGreen, VirtualSMC, AppleALC, BrightnessKeys,
RestrictEvents), [VoodooI2C](https://github.com/VoodooI2C/VoodooI2C),
[VoodooPS2](https://github.com/acidanthera/VoodooPS2),
[OpenIntelWireless](https://github.com/OpenIntelWireless/itlwm),
[USBToolBox](https://github.com/USBToolBox/kext), and
[RealtekRTL8111](https://github.com/Mieze/RTL8111_driver_for_OS_X).
Per-kext details: [kext reference](docs/kext-reference.md).

## License

Original documentation is released under the MIT license (see `LICENSE`).
The included kexts, ACPI binaries and OpenCore keep their own licenses —
see [kext reference](docs/kext-reference.md).

## Disclaimer

Hackintoshing is not supported by Apple and violates the macOS EULA. These EFIs
are provided as-is for educational use. They are specific to this hardware; if
you adapt them, verify everything on your own machine.
