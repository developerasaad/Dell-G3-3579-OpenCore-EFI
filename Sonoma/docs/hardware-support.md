# Hardware Support — macOS Sonoma 14.8.9

Statuses use: **Working** (verified on the laptop) · **Partial** ·
**Not working** (confirmed) · **Untested** (no reliable verification).

| Feature | Status | Notes |
|---------|--------|-------|
| Intel UHD 630 acceleration | Working | Metal 3, framebuffer `0x3EA50009` |
| Internal display (LGD053F 1080p) | Working | EDID override injected |
| Brightness — slider | Working | `AppleBacklight` binds to `LCD_` |
| Brightness — keys (F11/F12) | Working | `-igfxblt` + BrightnessKeys |
| Keyboard (PS/2) | Working | VoodooPS2Controller |
| Touchpad (I2C HID) | Working | VoodooI2C + VoodooI2CHID |
| Volume keys | Working | VoodooPS2 ADB codes |
| Audio (ALC236, layout 15) | Working | AppleALC |
| Microphone | Untested | — |
| Wi-Fi (Intel AC 9462) | Working | AirportItlwm 2.3.0 |
| Bluetooth (Intel) | Working | IntelBluetoothFirmware + BlueToolFixup |
| Ethernet (RTL8111) | Working | RealtekRTL8111 |
| Battery reporting | Partial | SMCBatteryManager present; not independently verified |
| USB ports | Working | UTBMap (Dell-specific map) |
| Sleep / wake | Untested | — |
| HDMI | Untested | likely wired to the disabled dGPU |
| Webcam | Untested | enumerates as USB UVC |
| SD reader (Realtek RTS, PCIe) | Working | verified with a 4 GB FAT32 card — mounts via RealtekCardReader |
| NVIDIA GTX 1050 | Not working | Pascal has no macOS driver; disabled |

See [configuration](configuration.md) for the settings behind these.
