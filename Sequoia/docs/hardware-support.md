# Hardware Support — macOS Sequoia 15.8.2

Statuses use: **Working** (verified on the laptop) · **Partial** ·
**Not working** (confirmed) · **Untested** (no reliable verification).

| Feature | Status | Notes |
|---------|--------|-------|
| Intel UHD 630 acceleration | Working | Metal 3, framebuffer `0x3EA50009` |
| Internal display (LGD053F 1080p) | Working | requires `-igfxblr` (see [display backlight](display-backlight.md)) |
| Brightness — slider | Working | `AppleBacklight` binds to `LCD_` |
| Brightness — keys (F11/F12) | Not working | trade-off of `-igfxblr`; see [display backlight](display-backlight.md) and [known issues](known-issues.md) |
| Keyboard (PS/2) | Working | VoodooPS2Controller |
| Volume keys | Working | VoodooPS2 ADB codes |
| Touchpad (I2C HID) | Working | VoodooI2C + VoodooI2CHID (less fluid than Sonoma) |
| Audio (ALC236, layout 15) | Working | AppleALC |
| Microphone | Untested | verified working on Sonoma; same AppleALC stack expected |
| Wi-Fi (Intel AC 9462) | Working | AirportItlwm 2.4.0 (Sequoia build) |
| Bluetooth (Intel) | Working | requires the USB map — see [known issues](known-issues.md) |
| Ethernet (RTL8111) | Working | RealtekRTL8111 |
| Battery reporting | Partial | SMCBatteryManager present; not independently verified |
| USB ports | Working | UTBMap |
| Sleep / wake | Untested | — |
| HDMI output | **Not working** | HDMI is wired to the NVIDIA dGPU, which is disabled; verified — connecting a TV detects no external display |
| Webcam | **Not working — sensor defective** | same dead sensor confirmed on Windows; the UVC pipeline itself was verified working on Sonoma |
| **SD reader (Realtek RTS, PCIe)** | **Not working** | `RealtekCardReader.kext` is missing from this EFI — the Sonoma EFI has it |
| NVIDIA GTX 1050 | Not working | Pascal has no macOS driver; disabled |

Touchpad pointer feel is slightly less fluid than Sonoma on this hardware; the
input pipeline is identical (verified: same driver binding, 125 Hz report rate),
so the difference is Sequoia's compositor on UHD 630, not the trackpad.
