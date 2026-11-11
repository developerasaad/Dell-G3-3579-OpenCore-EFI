# Hardware Support — macOS Sequoia 15.8.2

Statuses use: **Working** (verified on the laptop) · **Partial** ·
**Not working** (confirmed) · **Untested** (no reliable verification).

Verified on macOS Sequoia 15.8.2 (build 24H232).

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
| Microphone | Working | captures audio at high input volume — measured on 15.8.2: −38.9 dBFS RMS at 100 % vs −69.1 dBFS at the default gain, sound source beside the machine; setup steps in the Sonoma [hardware support](../../Sonoma/docs/hardware-support.md#microphone-setup--set-input-volume-near-max) |
| Wi-Fi (Intel AC 9462) | Working | AirportItlwm 2.4.0 (Sequoia build) |
| Bluetooth (Intel) | Working | requires the USB map — see [known issues](known-issues.md) |
| Ethernet (RTL8111) | Working | RealtekRTL8111 |
| Battery reporting | Partial | SMCBatteryManager present; not independently verified |
| USB ports | Working | UTBMap |
| Sleep / wake | Untested | — |
| HDMI output | **Not working** | HDMI is wired to the NVIDIA dGPU, which is disabled; verified — connecting a TV detects no external display |
| Webcam (incl. activity LED) | Working | native UVC, no kext — video works and the activity LED lights on 15.8.2; microphone capture, FaceTime/conferencing and other resolutions not tested |
| **SD reader (Realtek RTS, PCIe)** | **Working** | physically verified on 15.8.2 — 4 GB FAT32 card: detection, mount, file access, file copy; `RealtekCardReader` 0.9.7 |
| NVIDIA GTX 1050 | Not working | Pascal has no macOS driver; disabled |

Touchpad pointer feel is slightly less fluid than Sonoma on this hardware; the
input pipeline is identical (verified: same driver binding, 125 Hz report rate),
so the difference is Sequoia's compositor on UHD 630, not the trackpad.
