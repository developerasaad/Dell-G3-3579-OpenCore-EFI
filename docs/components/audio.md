# Audio — Realtek ALC236

| Item | Value |
|---|---|
| Codec | Realtek ALC236 (`10EC:0236`) |
| HDA controller | Intel `8086:A348` |
| Layout | `layout-id = 100` on `PciRoot(0x0)/Pci(0x1f,0x3)` (Sonoma), `15` (Sequoia) |
| Driver | AppleALC 1.9.9 with Lilu; the Sonoma EFI ships a custom build, 83,000 bytes |
| Verified | Sonoma 14.8.9: speakers, headphones, internal microphone, CTIA headset microphone. Sequoia 15.8.2: speakers and microphone (headphones not separately tested) |

AppleALC gets the codec from the HDA controller and the layout decides which
pin configuration is used. Layout 100 matches the ALC236 wiring on this laptop:
internal speakers, headphone jack, internal microphone, and the combo-jack
headset microphone through pin `0x19` retasked to Mic In. Layout 15, still used
by the Sequoia EFI, maps that pin as Line In, so a headset microphone does not
capture. Layout 5, which is commonly suggested for 236 codecs, is not correct
here either.

## Microphone gain

The internal microphone works on both systems but only at high input volume. At
the default gain it is effectively silent — measured at −69 dBFS RMS with a
sound source next to the machine, versus −38.9 dBFS at 100 %. Setup steps and
the Sonoma measurements are in
[Sonoma hardware support](../../Sonoma/docs/hardware-support.md#microphone-setup-set-input-volume-near-max).

## Reusing this on another laptop

AppleALC itself is generic, but layout 100 is not — it describes this board's
pin wiring. If your machine has an
ALC236, check the pin configuration in AppleALC's
[layout list](https://github.com/acidanthera/AppleALC/wiki/Supported-codecs)
and try the layouts listed for it — the codec name alone does not tell you which
layout your board wired. A different codec needs a different layout, and often
its own verb fixes.

Nothing about this layout should be presented as universal AppleALC support.
