# Hardware Support — macOS Sonoma 14.8.9

Statuses use: **Working** (verified on the laptop) · **Partial** ·
**Not working** (confirmed) · **Untested** (no reliable verification).

Verified on macOS Sonoma 14.8.9 (build 23J631).

| Feature | Status | Notes |
|---------|--------|-------|
| Intel UHD 630 acceleration | Working | Metal 3, framebuffer `0x3EA50009` |
| Internal display (LGD053F 1080p) | Working | EDID override injected |
| Brightness — slider | Working | `AppleBacklight` binds to `LCD_` |
| Brightness — keys (F11/F12) | Working | `-igfxblt` + BrightnessKeys |
| Keyboard (PS/2) | Working | VoodooPS2Controller |
| Touchpad (I2C HID) | Working | VoodooI2C + VoodooI2CHID — pointer, gestures and scrolling fully tested |
| Volume keys | Working | VoodooPS2 ADB codes |
| Audio (ALC236, layout 15) | Working | AppleALC |
| Microphone | Working | verified — but only at high input volume; see [microphone setup](#microphone-setup-set-input-volume-near-max) below |
| Wi-Fi (Intel AC 9462) | Working | AirportItlwm 2.3.0 |
| Bluetooth (Intel) | Working | IntelBluetoothFirmware + BlueToolFixup |
| Ethernet (RTL8111) | Working | RealtekRTL8111 |
| Battery reporting | Partial | SMCBatteryManager present; not independently verified |
| USB ports | Working | UTBMap (Dell-specific map) |
| Lid sleep / wake | Working | lid-close sleep and lid-open wake tested at 30 s, ~7 min and >10 min; every cycle slept on `Clamshell Sleep` and woke on `PBTN/UserActivity`; overnight sleep and hibernation not tested |
| HDMI output | **Not working** | HDMI is wired to the NVIDIA dGPU, which is disabled; verified — connecting a TV detects no external display |
| Webcam (incl. activity LED) | Working | native UVC, no kext — video works and the activity LED lights; microphone capture, FaceTime/conferencing and other resolutions not tested |
| SD reader (Realtek RTS, PCIe) | Working | verified with a 4 GB FAT32 card — mounts via RealtekCardReader |
| NVIDIA GTX 1050 | Not working | Pascal has no macOS driver; disabled |

See [configuration](configuration.md) for the settings behind these.

## Microphone setup: set input volume near max

The internal microphone works, but **not at the default input volume**. At the
default 51 % it captures almost nothing — measured on this laptop, music playing
right next to the machine produced no usable signal. Only after raising the
input volume to 100 % did the microphone clearly capture audio:

| macOS input volume | Captured level (RMS / peak) | Verdict |
|---|---|---|
| 51 % (default) | −75 dBFS / −53 dBFS | near-digital-silence |
| 100 % | −42.8 dBFS / −1.8 dBFS | clear signal |

This is a quirk of how AppleALC maps macOS input volume to analog gain on the
ALC236 — moderate slider positions behave like a broken microphone.

**Setup:**

1. System Settings → Sound → **Input** → select *Built-in Microphone*
2. Drag **Input volume** to 100 % (75 %+ at minimum)
3. Speak normally and watch the level meter — the bars should move
4. Quick end-to-end check without any extra tools: QuickTime Player →
   File → **New Audio Recording**, record a few seconds and play it back

If the level meter stays flat at high volume, that is a real microphone problem
— otherwise the capture path is fine and only the gain needed adjusting.
