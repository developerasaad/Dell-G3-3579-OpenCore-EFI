# SD card reader — Realtek RTS (PCIe)

| Item | Value |
|---|---|
| Controller | Realtek RTS PCIe reader (RTS5227 family) |
| macOS device | reported as `Built In SDXC Reader`, protocol `Secure Digital` |
| Windows device | enumerates as USB `0BDA:0129` |
| Driver | RealtekCardReader 0.9.7, bundle ID `science.firewolf.rtsx` |
| Upstream | [0xFireWolf/RealtekCardReader](https://github.com/0xFireWolf/RealtekCardReader) (BSD-3-Clause) |
| Config | `MinKernel 18.0.0`, no `MaxKernel` |
| Verified | Sonoma 14.8.9 and Sequoia 15.8.2 — 4 GB FAT32 card: detection, mount, file access, copy |

macOS has no native driver for these controllers. Without the kext the reader
simply never appears; there is no partially working state.

The same controller shows up differently depending on the OS — a PCIe SD host
controller under macOS, a USB card reader under Windows. That is why the
hardware inventory lists both `0BDA:0129` and the RTS name.

## Supported controllers

From the upstream project, the kext covers these PCIe parts:

`RTS5209`, `RTS5227`, `RTS522A`, `RTS5229`, `RTS5249`, `RTS524A`, `RTS525A`,
`RTS5260`, `RTS5286`, `RTS5287`, `RTS5289`

It does **not** implement `RTS5228` or `RTS5261`. The USB variants `RTS5129`,
`RTS5139` and `RTS5179` are also supported by the same kext.

## About the version fence

The upstream release documents Monterey and older as tested. On this machine the
kext loads and works on Sonoma 14.8.9 and Sequoia 15.8.2 with no upper kernel
fence, which is why the Sequoia entry has `MaxKernel` empty and the Sonoma entry
is limited to `23.99.99` (it is not needed twice on one system). If a future
macOS release changes a kernel KPI this kext uses, it will fail to load — that is
the first thing to check if cards stop mounting after an update.

## Limits of the verification

Only one 4 GB FAT32 card was tested. exFAT, NTFS, SDHC/SDXC capacities, UHS
speeds and hot-plug during sleep were not tested.

## Reusing this on another machine

Check the controller ID first. On Windows, Device Manager shows the reader under
either a PCIe or a USB device; on macOS you can read the PCI ID from
`ioreg` before installing anything. If it is one of the supported RTS parts, the
kext should work as-is; if it is an RTS5228 or RTS5261, it will not.

Do not assume that "Realtek card reader" means compatible — the family has many
controllers and only some are implemented.
