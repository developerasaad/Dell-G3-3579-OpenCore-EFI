# Security Policy

This repository is a personal Hackintosh configuration, not a product. It is
maintained on a best-effort basis and carries no guarantee of updates or fixes.

## Supported configurations

- macOS Sonoma 14.8.9 (23J631) — `Sonoma/EFI`
- macOS Sequoia 15.8.2 (24H232) — `Sequoia/EFI`

Both target the Dell G3 3579. The EFIs are provided as-is; treat them as a
starting point, not a finished, hardened configuration.

## Reporting a vulnerability

Report security issues privately rather than opening a public issue, especially
when the issue involves boot configuration that could expose identifiers or
credentials.

- Use GitHub's **Report a vulnerability** flow under the Security tab if it is
  enabled for this repository.
- If private reporting is not available, open a regular issue and leave out
  personal logs, SMBIOS identifiers and serial numbers.

Do not publish a working exploit or detailed proof-of-concept against another
user's boot configuration in a public issue.

## Scope

In scope:

- The `config.plist` files and kext/ACPI/driver selections in this repository
- The diagnostic scripts and launchd jobs under `tools/diagnostics/`

Out of scope:

- Upstream projects (OpenCore, Lilu, WhateverGreen, VirtualSMC, VoodooI2C,
  OpenIntelWireless and the rest) — report those to their own repositories
- macOS itself

## Known security limitations

A Hackintosh deliberately relaxes protections a stock Mac provides. Anyone using
these EFIs should be aware of:

- **Secure Boot is disabled** (`SecureBootModel = Disabled`,
  `Vault = Optional`), so firmware does not verify the boot chain.
- **System Integrity Protection is relaxed** (`csr-active-config = 030a0000`) so
  third-party kexts can load and unsupported boot works. This is required for
  OpenCore but reduces the hardening of a stock macOS install.
- **Third-party kexts run at kernel level.** Only use kexts from the upstream
  sources listed in [docs/kext-reference.md](docs/kext-reference.md) and verify
  what you add.
- **The diagnostic scripts run as root.** Install them only during
  troubleshooting and remove them afterwards — see
  [tools/diagnostics/README.md](tools/diagnostics/README.md). They collect
  system state and logs, so review output before sharing it.
- **SMBIOS identity is a sample and must be replaced.** Never publish a personal
  serial, MLB or ROM — see [docs/smbios.md](docs/smbios.md).

## Diagnostic data

The tools under `tools/diagnostics/` capture kernel logs, NVRAM contents, and
USB/Bluetooth state. They do not extract passwords or Apple account credentials,
but `nvram` output can contain identifiers you may not want public. Sanitize any
report before attaching it to an issue.
