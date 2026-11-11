# Dell G3 3579 — Hardware Specifications

Hardware as detected on this laptop via `system_profiler`, `ioreg`, and a Windows
hardware report (ACPI/PCI enumeration). PCI/USB IDs are as detected.

## Platform

| Item | Value |
|------|-------|
| Model | Dell G3 3579 |
| Chipset | Intel HM370 (Cannon Lake PCH) |
| BIOS | 1.25.0, UEFI, Secure Boot disabled |
| CPU | Intel Core i5-8300H, Coffee Lake-H, 4 cores / 8 threads, 2.3 GHz |
| CPU features | SSE4.2, AVX, AVX2 |
| Memory | 8 GB |

## Graphics

| Device | ID | Notes |
|--------|----|-------|
| Intel UHD Graphics 630 | `8086:3E9B` | Integrated; drives the internal panel; Metal 3 |
| NVIDIA GeForce GTX 1050 | `10DE:1C8D` (Pascal) | Discrete; **unsupported on macOS**, disabled via `SSDT-Disable_GPU_PEG0` |

Internal display: LG Display `LGD053F`, 1920×1080, eDP, connected to the iGPU
(Optimus — the panel is not wired to the NVIDIA GPU).

## Audio

| Item | Value |
|------|-------|
| Codec | Realtek ALC236 (`10EC:0236`) |
| Controller | Intel `8086:A348` HDA |
| AppleALC layout | 15 |

## Network

| Device | ID | Driver |
|--------|----|--------|
| Intel Wireless-AC 9462 (CNVi) | `8086:A370` (subsys `42A4`) | AirportItlwm / itlwm |
| Intel Bluetooth | USB `8087:0AAA` | IntelBluetoothFirmware + BlueToolFixup |
| Realtek RTL8111/8168 Ethernet | `10EC:8168` | RealtekRTL8111 |

## Input

| Device | Bus | Driver |
|--------|-----|--------|
| Touchpad | I2C HID (`DELL086F`) | VoodooI2C + VoodooI2CHID |
| Keyboard | PS/2 (`DLLK086F`) | VoodooPS2Controller |
| Webcam (with activity LED) | USB UVC (`0BDA:568A`) | native UVC — no kext |

## Storage / USB

| Item | Value |
|------|-------|
| SATA controller | Intel `8086:A353` AHCI (needs `CtlnaAHCIPort` on macOS) |
| Boot drive | SATA SSD |
| USB controller | Intel `8086:A36D` XHCI |
| SD reader | Realtek RTS PCIe reader (shows as USB `0BDA:0129` on Windows); needs `RealtekCardReader` on macOS |

## Notes for adapters

- The NVIDIA GPU is Pascal; no macOS driver exists beyond High Sierra web drivers.
  It is disabled, not accelerated. Do not expect HDMI output if HDMI is wired to it.
- The SATA controller is not natively supported by `AppleAHCIPort`; `CtlnaAHCIPort`
  is required or the boot disk will not appear.
- The touchpad is I2C, not PS/2; it needs the GPIO/ACPI patches described in the
  per-OS configuration docs, not just the VoodooI2C kext.
