# Input: I2C touchpad and PS/2 keyboard

Two input devices, two completely different driver paths.

## Touchpad — I2C HID

| Item | Value |
|---|---|
| ACPI device | `DELL086F` (I2C HID) |
| Keystack | VoodooI2C 2.9.1 + VoodooI2CHID 1.0 (+ `VoodooInput` plugin inside VoodooI2C) |
| ACPI support | `SSDT-GPI0` + `GPI0 _STA → XSTA` rename |
| Interrupt mode | GPIO interrupt, reported by the `i2cdiag` snapshot on both Sonoma and Sequoia |
| Verified | pointer working on both systems; gestures and scrolling not separately tested |

The `_STA` rename detaches the firmware's GPIO controller so VoodooGPIO can own
the interrupt; the injected `SSDT-GPI0` then describes the same controller
without the firmware methods. Neither half works alone.

The diagnostics collected on this machine show the touchpad bound in **GPIO
interrupt** mode on both systems — that is the mode VoodooI2C reports for this
controller. An earlier suspicion that Sequoia had fallen back to polling is not
supported by the data and should not be repeated. The pointer does feel slightly
less fluid on Sequoia; that matches the same driver binding and the same report
interval on both systems, so it is a compositor difference on UHD 630, not an
input-mode problem.

The plugin layout matters: `VoodooPS2Controller` ships its own `VoodooInput`
plugin, and it is **disabled** in both configs so that only VoodooI2C's copy
loads. Two copies of `VoodooInput` will fight over the same HID events.

### Reusing this on another laptop

VoodooI2C and VoodooI2CHID are generic; the ACPI is not. The GPIO device name,
the interrupt pin and the `_STA` path all come from your own DSDT, so regenerate
`SSDT-GPI0` and the rename for your machine. Check the
[VoodooI2C documentation](https://voodooi2c.github.io/) for the supported
controller families.

## Keyboard — PS/2

| Item | Value |
|---|---|
| ACPI device | `DLLK086F` (PS/2) |
| Driver | VoodooPS2Controller 2.3.8 (+ Keyboard, Mouse, Trackpad plugins) |
| Verified | keyboard, Fn combinations and volume keys on both systems |

Brightness keys are a separate story: they are ACPI EC events handled by
`BrightnessKeys`, not HID events, and they do not work on Sequoia. That is
documented with the measurements in
[Sequoia display backlight](../../Sequoia/docs/display-backlight.md) and
[known issues](../../Sequoia/docs/known-issues.md).

### Reusing this on another laptop

VoodooPS2Controller is generic for PS/2 controllers. Laptops with an I2C
keyboard (rare on this generation) need a different approach entirely, and
machines with a USB keyboard need nothing at all.
