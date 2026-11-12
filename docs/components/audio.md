# Audio — Realtek ALC236

| Item | Value |
|---|---|
| Codec | Realtek ALC236 (`10EC:0236`) |
| HDA controller | Intel `8086:A348` |
| Layout | `layout-id = 15` on `PciRoot(0x0)/Pci(0x1f,0x3)` |
| Driver | AppleALC 1.9.9 (with Lilu) |
| Verified | Sonoma 14.8.9: speakers, headphones, microphone. Sequoia 15.8.2: speakers and microphone (headphones not separately tested) |

AppleALC gets the codec from the HDA controller and the layout decides which
pin configuration is used. Layout 15 matches the ALC236 wiring on this laptop:
internal speakers, headphone jack and the internal microphone. Layout 5, which
is commonly suggested for 236 codecs, is not correct here.

## Microphone gain

The internal microphone works on both systems but only at high input volume. At
the default gain it is effectively silent — measured at −69 dBFS RMS with a
sound source next to the machine, versus −38.9 dBFS at 100 %. Setup steps and
the Sonoma measurements are in
[Sonoma hardware support](../../Sonoma/docs/hardware-support.md#microphone-setup-set-input-volume-near-max).

## Reusing this on another laptop

AppleALC itself is generic, but `layout-id 15` is not. If your machine has an
ALC236, check the pin configuration in AppleALC's
[layout list](https://github.com/acidanthera/AppleALC/wiki/Supported-codecs)
and try the layouts listed for it — the codec name alone does not tell you which
layout your board wired. A different codec needs a different layout, and often
its own verb fixes.

Nothing about this layout should be presented as universal AppleALC support.
