# Networking — Wi-Fi, Bluetooth, Ethernet

| Interface | Hardware | Driver | Verified |
|---|---|---|---|
| Wi-Fi | Intel Wireless-AC 9462 (CNVi, `8086:A370`, subsys `42A4`) | AirportItlwm 2.3.0 (Sonoma), 2.4.0 (Sequoia) | both systems |
| Bluetooth | Intel, USB `8087:0AAA` | IntelBluetoothFirmware 2.5.0 + IntelBTPatcher 2.5.0 + BlueToolFixup 2.7.3 | both systems |
| Ethernet | Realtek RTL8111/8168 (`10EC:8168`) | RealtekRTL8111 2.4.2 | Sonoma |

## Wi-Fi

The 9462 is a CNVi part: the radio is on the chipset, the card itself only holds
the antenna connectors. AirportItlwm replaces the native airport stack and is
**built per macOS release** — 2.3.0 for Sonoma, 2.4.0 for Sequoia. Loading the
wrong build gives an interface that never appears or a kernel panic.

The configs pin this with `MinKernel`/`MaxKernel`: `23.0.0–23.99.99` on Sonoma,
`24.2.0–24.99.99` on Sequoia, so a wrong pairing is rejected before the kext
loads.

## Bluetooth

The Intel Bluetooth controller is a USB device, and the three kexts split the job:

- `IntelBluetoothFirmware` — uploads the firmware.
- `IntelBTPatcher` — patches the stack for non-Apple controllers.
- `BlueToolFixup` — fixes the BlueTool handshake on newer macOS releases.

Bluetooth only enumerates when the controller's XHCI port is present in the USB
map. On this laptop that is **HS14**; if the map is disabled or omits the port,
macOS shows a placeholder controller and `IntelBluetoothFirmware` never loads.
After installing, keep `UTBMap.kext` enabled. See
[USB mapping](usb-mapping.md).

## Ethernet

`RealtekRTL8111` covers the RTL8111/8168 family. It is a self-contained driver
with no Lilu dependency. Verified on Sonoma; Sequoia has not been tested with a
cable.

## Reusing this on another machine

- AirportItlwm supports a specific list of Intel cards; check
  [OpenIntelWireless](https://github.com/OpenIntelWireless/itlwm) for your model
  and pick the build for your macOS version.
- The three Bluetooth kexts are generic for Intel USB controllers, but the port
  must exist in your USB map.
- RealtekRTL8111 works on any RTL8111/8168 variant; other Realtek parts (RTL8125,
  for instance) need a different driver.
- Broadcom cards need none of this — they are supported natively up to the point
  Apple removed them.
