# Contributing

Thanks for your interest in this project.

## What belongs here

- Hardware-specific fixes and documentation for the **Dell G3 3579**.
- Corrections to the compatibility tables, backed by what you actually observed.
- Improvements to the installation and troubleshooting guides.

## What does not belong

- Changes that enable the NVIDIA GTX 1050 — there is no macOS driver for Pascal.
- Kexts not required by the two EFI configurations.
- Personal logs, SMBIOS data, or machine-specific USB maps generated for other
  hardware.

## Testing before contributing

Any EFI change should be validated with `ocvalidate` matching the OpenCore
version used, and boot-tested on real hardware. Please describe what you tested
when proposing a configuration change — a config that "should work" is not
useful to other users.

## Style

Keep documentation practical: hardware, configuration, verification, and
limitations. Prefer accurate tables over prose, and say clearly when something
is untested.
