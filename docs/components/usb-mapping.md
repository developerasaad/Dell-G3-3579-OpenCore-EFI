# USB mapping — USBToolBox and UTBMap

Two kexts, two different jobs:

| Kext | Version | Role |
|---|---|---|
| `USBToolBox.kext` | 1.2.0 | Loader that reads a port map and applies it. Generic — identical on any machine. |
| `UTBMap.kext` | 1.1 | The map itself: which ports exist, their type and their internal/external role. **Specific to this motherboard.** |

Both are enabled in the Sonoma and Sequoia configs. `UTBMap` is generated with
the [USBToolBox tool](https://github.com/USBToolBox/tool) on the machine it is
meant for.

## Why the map matters here

Without a map macOS guesses port properties from the firmware. On this laptop
that produces two concrete problems:

- **Bluetooth never enumerates.** The Intel Bluetooth controller sits on XHCI
  **HS14**, and macOS only exposes it once the port is declared. See
  [networking](networking.md).
- **The installer cannot find its own drive.** While installing Sequoia the map
  had to be disabled because the USB stick sat on a port the map pruned; the
  result was a `still waiting for root device` hang. After installing, the map is
  re-enabled and the boot drive must be on a declared port.

The Sequoia EFI therefore requires the map for normal operation; the Sonoma EFI
ships it enabled as well.

## Do not copy this map

`UTBMap.kext` describes this Dell G3 3579 down to the port count and the
internal header assignments. Using it on another board will hide ports, mislabel
them, or break boot entirely — the same class of failure as the installer hang
above.

Generate your own map on the target machine with USBToolBox, then keep
`USBToolBox.kext` (generic) and replace only `UTBMap.kext`.

## Checking the result

After booting with a new map, `ioreg -r -c AppleUSBHostController` lists the
declared ports, and System Information → USB shows what is attached where. If a
device disappears after a map change, the port it uses was pruned.
