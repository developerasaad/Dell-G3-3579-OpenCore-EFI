# Similar laptops

Only one machine has been tested with this EFI: the **Dell G3 3579** running
Sonoma 14.8.9 (23J631) and Sequoia 15.8.2 (24H232). Everything else on this page
is hardware overlap, not a compatibility claim.

## How to read this page

| Label | Meaning |
|---|---|
| **Tested EFI** | The complete configuration in this repository has been boot-tested on that machine. |
| **Similar hardware** | The laptop shares the CPU generation, iGPU and roughly the same platform, but this EFI has never been booted on it. Expect to redo ACPI, the USB map and audio layout. |
| **Component reference** | Only specific parts of the repository are likely to be useful (a kext, a framebuffer approach, a method), not the EFI as a whole. |

No machine below except the G3 3579 has been booted with these files. Do not read
a row in this table as "supports Sequoia".

## 2018 Coffee Lake-H laptops

These are the 15-inch gaming laptops from the same generation as the G3 3579.
All use 8th-gen Coffee Lake-H CPUs with UHD Graphics 630 and switchable NVIDIA
graphics; the Dell G-series models share Dell's 2018 chassis family.

| Model | CPU options | iGPU | dGPU | Overlap with this repository |
|---|---|---|---|---|
| **Dell G3 3579** | i5-8300H, i7-8750H | UHD 630 | GTX 1050, 1050 Ti | **Tested EFI** — Sonoma 14.8.9 and Sequoia 15.8.2 |
| Dell G3 3779 | i5-8300H, i7-8750H | UHD 630 | GTX 1050, 1050 Ti | **Similar hardware** — 17-inch version of the same G3 platform, HM370 |
| Dell G5 5587 | i5-8300H, i7-8750H | UHD 630 | GTX 1050, 1050 Ti, 1060 Max-Q | **Similar hardware** — same generation G-series |
| Dell G7 7588 | i7-8750H | UHD 630 | GTX 1060, 1060 Max-Q | **Similar hardware** — same generation G-series |
| Dell XPS 15 9570 | i5-8300H, i7-8750H, i9-8950HK | UHD 630 | GTX 1050, 1050 Ti | **Component reference** — different audio, touchpad and thermal design |
| Lenovo Legion Y530-15ICH | i5-8300H, i7-8750H | UHD 630 | GTX 1050 Ti, 1060 | **Similar hardware** — Lenovo lists HM370 |
| Lenovo IdeaPad 330-15ICH | i5-8300H, i7-8750H | UHD 630 | GTX 1050 (2/4 GB) | **Similar hardware** |
| Acer Nitro 5 AN515-52 | i5-8300H, i7-8750H | UHD 630 | GTX 1050, 1050 Ti | **Similar hardware** |
| HP Pavilion Gaming 15-cx | i5-8300H, i7-8750H (8th-gen models) | UHD 630 | GTX 1050, 1050 Ti | **Similar hardware** — the series also shipped 9th-gen variants; check yours |
| ASUS TUF Gaming FX504GE | i7-8750H | UHD 630 | GTX 1050 Ti | **Similar hardware** |
| MSI GS65 Stealth 8RF | i7-8750H | UHD 630 | GTX 1070 Max-Q | **Similar hardware** — MSI lists HM370 |

Model specifications were checked against vendor documentation (Dell setup and
specification PDFs, Lenovo PSREF, MSI product pages) and independent spec
databases. Variants exist within every series — the CPU, panel and even the
touchpad controller can differ between SKUs of the same model number. Verify your
own machine before assuming a row applies.

## What actually transfers

For the machines above, the useful parts are the **methods and the kext stack**,
not the EFI:

- The Acidanthera stack (Lilu, VirtualSMC, WhateverGreen, AppleALC) and the
  loaded-kext order described in [configuration](../../Sequoia/docs/configuration.md).
- The UHD 630 approach — `AAPL,ig-platform-id 0x3EA50009` for this panel and
  stolen/fbmem compensation. Other panels need their own framebuffer and EDID;
  see [Coffee Lake](coffee-lake.md) and [UHD 630](../intel-uhd-630.md).
- The I2C touchpad pattern (VoodooI2C + VoodooI2CHID, GPIO SSDT + `_STA` rename),
  re-derived from your own DSDT — see [input](../components/input.md).
- The SD reader kext if your machine has a supported Realtek RTS controller —
  see [SD reader](../components/sd-reader.md).
- Audio only if your codec matches; `layout-id 15` is specific to the ALC236
  wiring here.

Nothing ACPI-related transfers: `SSDT-PNLF`, `SSDT-GPI0`, `SSDT-ALSD`,
`SSDT-XOSI`, `SSDT-Disable_GPU_PEG0` and the five renames are written for this
DSDT. The USB map is machine-specific by definition.

## About the NVIDIA GPU

Every laptop in the table has a Pascal dGPU (GTX 1050 through 1070 Max-Q) and is
therefore in the same situation as this one: no macOS driver, disabled with an
SSDT, and any HDMI port wired to it stays dead under macOS. See
[known issues](../../Sonoma/docs/known-issues.md).

## External references

No laptop-specific Hackintosh EFI was used as a source for this repository.
The upstream projects that matter are linked from
[kext reference](../kext-reference.md). If you are adapting this to another
machine, start from the
[OpenCore documentation](https://dortania.github.io/OpenCore-Install-Guide/)
and generate the ACPI and USB map for your own hardware.
