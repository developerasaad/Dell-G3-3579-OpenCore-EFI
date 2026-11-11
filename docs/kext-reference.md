# Kext Reference and Upstream Sources

Kexts actually present in the two public EFIs, with versions as shipped. Both
configurations share the same core; differences are noted.

Licenses: most Acidanthera kexts are BSD-3-Clause; VoodooI2C is GPL-2.0;
VoodooPS2 is APSL/BSD; OpenIntelWireless is GPL-2.0; USBToolBox is BSD-3;
RealtekRTL8111 is GPL-2.0. The repository license covers original documentation
only — it does **not** relicense these binaries. Preserve upstream notices when
redistributing.

## Core (both OSes)

| Kext | Version | Purpose | Upstream |
|------|---------|---------|----------|
| Lilu | 1.7.3 | Kernel patching framework | [acidanthera/Lilu](https://github.com/acidanthera/Lilu) |
| VirtualSMC | 1.3.9 | SMC emulation | [acidanthera/VirtualSMC](https://github.com/acidanthera/VirtualSMC) |
| SMCProcessor | 1.3.9 | CPU temperature/SMC | same repo |
| SMCSuperIO | 1.3.9 | Fan/SMC super-I/O | same repo |
| SMCBatteryManager | 1.3.9 | Battery reporting | same repo |
| SMCLightSensor | 1.3.9 | Ambient light sensor | same repo |
| SMCDellSensors | 1.3.9 | Dell-specific SMC sensors | same repo |
| WhateverGreen | 1.7.2 | GPU framebuffer/backlight | [acidanthera/WhateverGreen](https://github.com/acidanthera/WhateverGreen) |
| AppleALC | 1.9.9 | HDA audio (ALC236, layout 15) | [acidanthera/AppleALC](https://github.com/acidanthera/AppleALC) |
| BrightnessKeys | 1.0.4 | ACPI brightness keys | [acidanthera/BrightnessKeys](https://github.com/acidanthera/BrightnessKeys) |
| RestrictEvents | 1.1.7 | Restrict unsupported events | [acidanthera/RestrictEvents](https://github.com/acidanthera/RestrictEvents) |
| VoodooPS2Controller | 2.3.8 | PS/2 keyboard | [acidanthera/VoodooPS2](https://github.com/acidanthera/VoodooPS2) |
| VoodooI2C | 2.9.1 | I2C touchpad | [VoodooI2C/VoodooI2C](https://github.com/VoodooI2C/VoodooI2C) |
| VoodooI2CHID | 1.0 | I2C HID satellite | same repo |
| USBToolBox | 1.2.0 | USB port mapping loader | [USBToolBox/kext](https://github.com/USBToolBox/kext) |
| UTBMap | 1.1 | **Dell-specific** USB map | generated with [USBToolBox/tool](https://github.com/USBToolBox/tool) |
| CtlnaAHCIPort | 341.0.2 | Unsupported Intel SATA AHCI | [Ctlna/CtlnaAHCIPort](https://github.com/Ctlna/CtlnaAHCIPort) |
| RealtekRTL8111 | 2.4.2 | RTL8111 Ethernet | [Mieze/RTL8111_driver_for_OS_X](https://github.com/Mieze/RTL8111_driver_for_OS_X) |
| IntelBluetoothFirmware | 2.5.0 | Intel BT firmware | [OpenIntelWireless/IntelBluetoothFirmware](https://github.com/OpenIntelWireless/IntelBluetoothFirmware) |
| IntelBTPatcher | 2.5.0 | Intel BT patching | same repo |
| BlueToolFixup | 2.7.3 | BT stack fixup | [acidanthera/BrcmPatchRAM](https://github.com/acidanthera/BrcmPatchRAM) |

## Version-specific

| Kext | Sonoma | Sequoia | Note |
|------|--------|---------|------|
| AirportItlwm | 2.3.0 | 2.4.0 | Wi-Fi; build must match the macOS release |

## Sonoma-only (present but optional/disabled)

| Kext | Version | Note |
|------|---------|------|
| RealtekCardReader | 0.9.7 | PCIe SD reader; the G3's reader is USB, so this is not required |
| XHCI-unsupported | 0.9.2 | Disabled; not needed on this XHCI |

## Dependencies

- Everything above that patches the kernel requires **Lilu** loaded first.
- `VirtualSMC` plugins require `VirtualSMC`.
- `VoodooI2CHID` requires `VoodooI2C`; the touchpad also needs the GPIO/ACPI
  patches in each OS's configuration.
- `UTBMap` requires `USBToolBox`. **Do not reuse this map on other machines.**
